import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class ResourcesService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  /// Récupère toutes les filières disponibles
  Future<List<String>> getFilieres() async {
    try {
      final response = await _supabase
          .from('resources_metadata')
          .select('filiere')
          .order('filiere');
      
      final filieres = <String>{};
      for (final row in response) {
        filieres.add(row['filiere'] as String);
      }
      
      return filieres.toList();
    } catch (e) {
      debugPrint('Erreur getFilieres: $e');
      return [];
    }
  }
  
  /// Récupère les semestres d'une filière
  Future<List<String>> getSemestres(String filiere) async {
    try {
      final response = await _supabase
          .from('resources_metadata')
          .select('semestre')
          .eq('filiere', filiere)
          .order('semestre');
      
      final semestres = <String>{};
      for (final row in response) {
        semestres.add(row['semestre'] as String);
      }
      
      return semestres.toList();
    } catch (e) {
      debugPrint('Erreur getSemestres: $e');
      return [];
    }
  }
  
  /// Récupère les matières d'un semestre
  Future<List<String>> getMatieres(String filiere, String semestre) async {
    try {
      final response = await _supabase
          .from('resources_metadata')
          .select('matiere')
          .eq('filiere', filiere)
          .eq('semestre', semestre)
          .order('matiere');
      
      final matieres = <String>{};
      for (final row in response) {
        matieres.add(row['matiere'] as String);
      }
      
      return matieres.toList();
    } catch (e) {
      debugPrint('Erreur getMatieres: $e');
      return [];
    }
  }
  
  /// Récupère les PDFs d'une matière
  Future<List<Map<String, dynamic>>> getPdfs(
    String filiere,
    String semestre,
    String matiere,
  ) async {
    try {
      final response = await _supabase
          .from('resources_metadata')
          .select('filename, file_path, file_size, created_at')
          .eq('filiere', filiere)
          .eq('semestre', semestre)
          .eq('matiere', matiere)
          .order('filename');
      
      final pdfs = <Map<String, dynamic>>[];
      for (final row in response) {
        final filePath = row['file_path'] as String;
        final publicUrl = _supabase.storage
            .from('resources')
            .getPublicUrl(filePath);
        
        pdfs.add({
          'name': row['filename'],
          'url': publicUrl,
          'size': row['file_size'],
          'created_at': row['created_at'],
          'source': 'supabase',
        });
      }
      
      return pdfs;
    } catch (e) {
      debugPrint('Erreur getPdfs: $e');
      return [];
    }
  }
  
  /// Récupère la structure complète des ressources (format manifest)
  Future<Map<String, dynamic>> getFullManifest() async {
    try {
      final response = await _supabase
          .from('resources_metadata')
          .select('*')
          .order('filiere')
          .order('semestre')
          .order('matiere')
          .order('filename');
      
      final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> structure = {};
      
      for (final row in response) {
        final filiere = row['filiere'] as String;
        final semestre = row['semestre'] as String;
        final matiere = row['matiere'] as String;
        final filename = row['filename'] as String;
        final filePath = row['file_path'] as String;
        
        final publicUrl = _supabase.storage
            .from('resources')
            .getPublicUrl(filePath);
        
        structure.putIfAbsent(filiere, () => {});
        structure[filiere]!.putIfAbsent(semestre, () => {});
        structure[filiere]![semestre]!.putIfAbsent(matiere, () => []);
        
        structure[filiere]![semestre]![matiere]!.add({
          'name': filename,
          'url': publicUrl,
          'size': row['file_size'],
          'source': 'supabase',
        });
      }
      
      // Convertir en format manifest
      final filieres = <Map<String, dynamic>>[];
      
      structure.forEach((filiereName, semestres) {
        final semestresList = <Map<String, dynamic>>[];
        
        semestres.forEach((semestreName, matieres) {
          final matieresList = <Map<String, dynamic>>[];
          
          matieres.forEach((matiereName, pdfs) {
            matieresList.add({
              'name': matiereName,
              'pdfs': pdfs,
            });
          });
          
          semestresList.add({
            'name': semestreName,
            'matieres': matieresList,
          });
        });
        
        filieres.add({
          'name': filiereName,
          'semestres': semestresList,
        });
      });
      
      return {'filieres': filieres};
    } catch (e) {
      debugPrint('Erreur getFullManifest: $e');
      return {'filieres': []};
    }
  }
}

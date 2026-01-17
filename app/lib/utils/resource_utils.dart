import 'dart:convert';
import 'package:flutter/services.dart';

class MentionQuery {
  final String fullPath;
  final String currentQuery;
  final List<String> segments;

  MentionQuery({
    required this.fullPath,
    required this.currentQuery,
    required this.segments,
  });
}

class ResourceUtils {
  /// Charge l'arborescence complète des ressources
  static Future<Map<String, dynamic>> getResourceTree() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/resources_manifest_online.json',
      );
      return json.decode(response);
    } catch (e) {
      return {'filieres': []};
    }
  }

  /// Représente un document aplati pour la recherche (legacy support)
  static Future<List<Map<String, String>>> getFlattenedResources() async {
    try {
      final tree = await getResourceTree();
      final List<Map<String, String>> flattened = [];

      for (var filiere in tree['filieres']) {
        String filiereName = filiere['name'] ?? '';
        for (var semestre in filiere['semestres']) {
          String semestreName = semestre['name'] ?? '';
          for (var matiere in semestre['matieres']) {
            String matiereName = matiere['name'] ?? '';
            for (var pdf in matiere['pdfs']) {
              flattened.add({
                'name': pdf['name'] ?? '',
                'url': pdf['url'] ?? '',
                'matiere': matiereName,
                'semestre': semestreName,
                'filiere': filiereName,
              });
            }
          }
        }
      }
      return flattened;
    } catch (e) {
      return [];
    }
  }

  /// Extrait les informations de mention après le dernier @
  static MentionQuery? getMentionQuery(String text, int selectionIndex) {
    if (selectionIndex <= 0) return null;
    
    final textBeforeCursor = text.substring(0, selectionIndex);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');
    
    if (lastAtIndex == -1) return null;
    
    final textAfterAt = textBeforeCursor.substring(lastAtIndex + 1);
    
    // Si la mention contient un espace, ce n'est plus une mention en cours (sauf si on est dans le nom du PDF, mais simplifions)
    // Cependant, le nom des PDF peut contenir des espaces. 
    // Pour les filières et semestres, on attend généralement des identifiants sans espaces (ou gérés par le système).
    // Mais ici on utilise le "/" comme séparateur.
    
    final segments = textAfterAt.split('/');
    final currentQuery = segments.last;
    final pathSegments = segments.take(segments.length - 1).toList();
    
    return MentionQuery(
      fullPath: textAfterAt,
      currentQuery: currentQuery,
      segments: pathSegments,
    );
  }
}

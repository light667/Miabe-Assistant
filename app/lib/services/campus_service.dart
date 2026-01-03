import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer les opérations du Campus Collaboratif
class CampusService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Toggle like sur un post, commentaire ou fiche
  /// Retourne true si liké, false si unlike
  static Future<bool> toggleLike({
    required String userId,
    required String contentType, // 'post', 'comment', 'fiche'
    required String contentId,
  }) async {
    try {
      // Vérifier si l'utilisateur a déjà liké
      final existingLike = await _supabase
          .from('campus_likes')
          .select()
          .eq('user_id', userId)
          .eq('content_type', contentType)
          .eq('content_id', contentId);

      if (existingLike.isNotEmpty) {
        // Unlike: supprimer le like
        await _supabase
            .from('campus_likes')
            .delete()
            .eq('user_id', userId)
            .eq('content_type', contentType)
            .eq('content_id', contentId);
        
        // Décrémenter le compteur
        _decrementLikeCount(contentType, contentId);
        return false;
      } else {
        // Like: insérer
        await _supabase.from('campus_likes').insert({
          'user_id': userId,
          'content_type': contentType,
          'content_id': contentId,
        });
        
        // Incrémenter le compteur
        _incrementLikeCount(contentType, contentId);
        return true;
      }
    } catch (e) {
      debugPrint('❌ Erreur toggle like: $e');
      rethrow;
    }
  }

  /// Incrémenter le compteur de likes
  static Future<void> _incrementLikeCount(String contentType, String contentId) async {
    try {
      final table = _getTableName(contentType);
      await _supabase
          .from(table)
          .update({'likes': 'likes + 1'})
          .eq('id', contentId);
    } catch (e) {
      debugPrint('⚠️ Erreur increment like count: $e');
    }
  }

  /// Décrémenter le compteur de likes
  static Future<void> _decrementLikeCount(String contentType, String contentId) async {
    try {
      final table = _getTableName(contentType);
      await _supabase
          .from(table)
          .update({'likes': 'CASE WHEN likes > 0 THEN likes - 1 ELSE 0 END'})
          .eq('id', contentId);
    } catch (e) {
      debugPrint('⚠️ Erreur decrement like count: $e');
    }
  }

  /// Vérifier si utilisateur a déjà liké
  static Future<bool> hasUserLiked({
    required String userId,
    required String contentType,
    required String contentId,
  }) async {
    try {
      final result = await _supabase
          .from('campus_likes')
          .select()
          .eq('user_id', userId)
          .eq('content_type', contentType)
          .eq('content_id', contentId);
      
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Erreur vérification like: $e');
      return false;
    }
  }

  /// Obtenir le nombre de likes
  static Future<int> getLikeCount({
    required String contentType,
    required String contentId,
  }) async {
    try {
      final table = _getTableName(contentType);
      final result = await _supabase
          .from(table)
          .select('likes')
          .eq('id', contentId);
      
      if (result.isNotEmpty) {
        return result[0]['likes'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('⚠️ Erreur get like count: $e');
      return 0;
    }
  }

  /// Obtenir le nom de la table basé sur le type de contenu
  static String _getTableName(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'post':
        return 'campus_posts';
      case 'comment':
        return 'campus_comments';
      case 'fiche':
        return 'campus_fiches';
      default:
        throw ArgumentError('Type de contenu invalide: $contentType');
    }
  }

  /// Parser l'erreur Supabase en message lisible
  static String parseSupabaseError(dynamic error) {
    if (error is PostgrestException) {
      // Erreurs de sécurité RLS
      if (error.message.contains('row-level security')) {
        return 'Vous n\'avez pas la permission d\'effectuer cette action.';
      }
      // Erreurs de colonne manquante
      if (error.message.contains('column')) {
        return 'Erreur de structure de base de données. Contactez l\'admin.';
      }
      return error.message;
    }
    
    final errorStr = error.toString();
    
    // Erreur 401: Non authentifié
    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return 'Vous devez être connecté pour effectuer cette action.';
    }
    
    // Erreur 400: Mauvaise requête
    if (errorStr.contains('400') || errorStr.contains('Bad Request')) {
      return 'Données invalides. Vérifiez que vous avez rempli tous les champs.';
    }
    
    // Erreur 409: Conflit (doublon)
    if (errorStr.contains('409') || errorStr.contains('Conflict')) {
      return 'Cette action a déjà été effectuée.';
    }
    
    return 'Une erreur s\'est produite. Veuillez réessayer.';
  }
}

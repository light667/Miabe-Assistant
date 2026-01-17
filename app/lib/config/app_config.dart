import 'api_keys.dart';

/// Service de configuration pour gérer les clés API de manière sécurisée
class AppConfig {
  // Initialisation (pour compatibilité avec l'ancien code)
  static Future<void> initialize() async {
    // Pas besoin de charger .env, on utilise directement api_keys.dart
    return Future.value();
  }

  // Récupère la clé API Mistral de manière sécurisée
  static String get mistralApiKey {
    return ApiKeys.mistralApiKey;
  }

  // Mode debug pour vérifier si la configuration est chargée
  static bool get isConfigured {
    return ApiKeys.mistralApiKey.isNotEmpty && 
           ApiKeys.mistralApiKey != 'YOUR_MISTRAL_API_KEY_HERE';
  }
  
  // Optional backend proxy URL used to proxy Mistral requests (optional)
  // Default to empty (use direct API). Set via --dart-define=BACKEND_URL=https://your-backend.com if using backend proxy
  static String get backendUrl {
    const url = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    return url;
  }
}

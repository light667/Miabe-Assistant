/// Configuration des clés API - LES VRAIES CLÉS DOIVENT ÊTRE DANS .env.local
/// Pour le développement, utilisez:
/// flutter run --dart-define=MISTRAL_API_KEY=your_key
/// 
/// Pour la production, utilisez les secrets du CI/CD ou Firebase Remote Config
class ApiKeys {
  // Clé API Mistral AI - définie via --dart-define
  static const String _mistralFromEnv = String.fromEnvironment('MISTRAL_API_KEY');
  
  // Clé API Mistral de production
  // Note: On ne peut pas utiliser .isNotEmpty dans un const, on compare donc directement
  static const String mistralApiKey = _mistralFromEnv != '' 
      ? _mistralFromEnv 
      : 'QITiTDUwozQZ3pzBrc1XtZoWvdXplxlf';
  
  // Valider les clés au démarrage
  static bool isConfigured() => mistralApiKey.isNotEmpty && mistralApiKey != 'YOUR_MISTRAL_API_KEY_HERE';
}

/// Configuration des clés API - LES VRAIES CLÉS DOIVENT ÊTRE DANS .env.local
/// Pour le développement, utilisez:
/// flutter run --dart-define=MISTRAL_API_KEY=your_key
/// 
/// Pour la production, utilisez les secrets du CI/CD ou Firebase Remote Config
class ApiKeys {
  // Clé API Mistral AI - définie via --dart-define
  static const String mistralApiKey = String.fromEnvironment(
    'MISTRAL_API_KEY',
    defaultValue: '',
  );
  
  // Valider les clés au démarrage
  static bool isConfigured() => mistralApiKey.isNotEmpty;
}

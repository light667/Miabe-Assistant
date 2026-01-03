/// Constantes de l'application Miabe Assistant
class AppConstants {
  // Informations de l'application
  static const String appName = 'Miabé ASSISTANT';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Votre succès académique commence ici';
  
  // URLs
  static const String websiteUrl = 'https://miabe.tg'; // À mettre à jour
  static const String privacyPolicyUrl = 'https://miabe.tg/privacy'; // À créer
  static const String termsOfServiceUrl = 'https://miabe.tg/terms'; // À créer
  static const String supportEmail = 'support@miabe.tg'; // À mettre à jour
  
  // Configurations
  static const int splashDuration = 3; // secondes
  static const int onboardingPageCount = 5;
  
  // Clés de stockage local
  static const String keyIsFirstLaunch = 'isFirstLaunch';
  static const String keySelectedDepartment = 'selectedDepartment';
  static const String keyPseudo = 'pseudo';
  static const String keyDarkMode = 'darkMode';
  
  // Départements
  static const List<String> departments = [
    'Sciences et Technologie',
    'Lettres, Langue et Arts',
    'Sciences Agronomiques',
    'Sciences de l\'Education et de la Formation',
    'Sciences Economiques et de Gestion',
    'Sciences de l\'Homme et de la Société',
    'Sciences Juridiques, Politiques et de l\'Administration',
    'Sciences de la Santé',
  ];
  
  // Limites
  static const int maxMessageLength = 500;
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  
  // Délais (millisecondes)
  static const int animationDuration = 300;
  static const int snackbarDuration = 3000;
  static const int loadingTimeout = 30000;
}

// NOTE: This file is NOT committed to git
// It contains YOUR actual API keys - keep it secret!

// Copy from .env.example and fill in your real values:
// cp .env.example .env.local
// Then fill in the actual keys

class ApiKeys {
  // Read from environment - in Flutter web, use dart:io or use build-time constants
  // For now, these are set via build configuration or hardcoded during development
  
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gtnyqqstqfwvncnymptm.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // MUST be set via --dart-define during build
  );
  
  static const String mistralApiKey = String.fromEnvironment(
    'MISTRAL_API_KEY',
    defaultValue: '', // MUST be set via --dart-define during build
  );
  
  // Validate that required keys are present
  static bool hasValidKeys() {
    return supabaseAnonKey.isNotEmpty && mistralApiKey.isNotEmpty;
  }
  
  static String validateKeys() {
    final errors = <String>[];
    
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY is not set');
    }
    if (mistralApiKey.isEmpty) {
      errors.add('MISTRAL_API_KEY is not set');
    }
    
    return errors.isEmpty ? 'OK' : errors.join(', ');
  }
}

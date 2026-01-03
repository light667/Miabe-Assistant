import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Read from environment or use defaults from .env
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gtnyqqstqfwvncnymptm.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bnlxcXN0cWZ3dm5jbnltcHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5ODIzNTAsImV4cCI6MjA4MTU1ODM1MH0.dtMEeeQ5NUIlfFWNVeM7EyzrwptKsMdLh337szg3lFY',
  );
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
// Ensure this matches your project structure

// You can run this script with `dart run scripts/upload_resources.dart`
// Make sure you have the supabase_flutter and dotenv dependencies if needed, 
// or just hardcode keys for this one-off script (but be careful not to commit them if they are secrets).
// For simplicity in this context, we'll ask the user to provide URL/KEY or read from env.

// NOTE: For a dart script outside of Flutter context, we usually use `supabase` package (dart only), 
// but since we are in a Flutter project, we might need to rely on the existing setup or just use standard HTTP if the SDK is too coupled to Flutter.
// However, `supabase_flutter` depends on `supabase` which works in Dart.

void main() async {
  // TODO: Replace with your actual project URL and Anon Key
  const supabaseUrl = 'https://gtnyqqstqfwvncnymptm.supabase.co';
  const supabaseKey = 'YOUR_SUPABASE_ANON_KEY'; // User needs to fill this or we can try to read from a config file

  if (supabaseKey == 'YOUR_SUPABASE_ANON_KEY') {
    print('❌ Error: Please provide your Supabase Anon Key in the script.');
    return;
  }

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  const filePath = '../../resources/competences/FREECAD_Cours.pdf';
  final file = File(filePath);

  if (!file.existsSync()) {
    print('❌ Error: File not found at $filePath');
    // Try absolute path if needed or check relative to where script is run
    print('Current directory: ${Directory.current.path}');
    return;
  }

  try {
    print('🚀 Uploading ${file.path}...');
    const fileName = 'competences/FREECAD_Cours.pdf';
    
    // Read file bytes
    final fileBytes = await file.readAsBytes();

    // Upload to 'resources' bucket
    await supabase.storage.from('resources').uploadBinary(
      fileName,
      fileBytes,
      fileOptions: const FileOptions(upsert: true),
    );

    print('✅ Upload successful!');
    
    // Get Public URL
    final publicUrl = supabase.storage.from('resources').getPublicUrl(fileName);
    print('🌍 Public URL: $publicUrl');
    print('Ensure this URL matches what is in home_page.dart');

  } catch (e) {
    print('❌ Error uploading file: $e');
  }
}

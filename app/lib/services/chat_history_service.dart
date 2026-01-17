import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import for ChatMessage class if needed, or duplicate/move model

// Define ChatMessage model here if it's not exported globally, or move to a model file.
// Assuming ChatMessage is in chat_page.dart, but importing a page file for a model is bad practice.
// I'll check chat_page.dart for the model definition.
// If it's private (_ChatMessage), I'll need to refactor or define a DTO.

class ChatHistoryService {
  static const String _sessionsKey = 'chat_sessions';
  static const String _sessionPrefix = 'chat_session_';

  Future<List<String>> getSessionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_sessionsKey) ?? [];
  }

  Future<void> saveSession(String sessionId, List<Map<String, dynamic>> messages, String title) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save session content
    await prefs.setString('$_sessionPrefix$sessionId', jsonEncode({
      'id': sessionId,
      'title': title,
      'timestamp': DateTime.now().toIso8601String(),
      'messages': messages,
    }));

    // Update session list if new
    final sessions = prefs.getStringList(_sessionsKey) ?? [];
    if (!sessions.contains(sessionId)) {
      sessions.insert(0, sessionId); // Newest first
      await prefs.setStringList(_sessionsKey, sessions);
    }
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_sessionPrefix$sessionId');
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove content
    await prefs.remove('$_sessionPrefix$sessionId');
    
    // Remove from list
    final sessions = prefs.getStringList(_sessionsKey) ?? [];
    sessions.remove(sessionId);
    await prefs.setStringList(_sessionsKey, sessions);
  }
  
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList(_sessionsKey) ?? [];
    for (var id in sessions) {
      await prefs.remove('$_sessionPrefix$id');
    }
    await prefs.remove(_sessionsKey);
  }
}

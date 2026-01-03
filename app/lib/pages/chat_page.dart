import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:miabeassistant/services/mistral_service.dart';
import 'package:miabeassistant/services/chat_history_service.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryService _historyService = ChatHistoryService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showSuggestions = true;
  String _sessionId = const Uuid().v4();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: '👋 Bonjour ! Je suis Miabé ASSISTANT.\n\n'
            'Je peux vous aider à rédiger des rapports, trouver des stages, ou organiser vos révisions.\n'
            "Comment puis-je vous aider aujourd'hui ?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _showSuggestions = false;
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final conversationHistory = _messages
        .where((msg) => msg.text != _messages.first.text)
        .map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();

    try {
      final response = await MistralService.sendMessage(
        text,
        conversationHistory: conversationHistory,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() {
          _messages.add(ChatMessage(text: 'Désolé, une erreur est survenue.', isUser: false, timestamp: DateTime.now()));
          _isLoading = false;
         });
      }
    }

    _scrollToBottom();
    _saveChat();
  }

  Future<void> _saveChat() async {
    if (_messages.isEmpty) return;
    
    // Convert messages to JSON-serializable list
    final messagesJson = _messages.map((m) => {
      'text': m.text,
      'isUser': m.isUser,
      'timestamp': m.timestamp.toIso8601String(),
    }).toList();

    // Determine title
    String title = 'Nouvelle discussion';
    final userMsg = _messages.firstWhere((m) => m.isUser, orElse: () => ChatMessage(text: '', isUser: true, timestamp: DateTime.now()));
    if (userMsg.text.isNotEmpty) {
      title = userMsg.text.length > 30 ? '${userMsg.text.substring(0, 30)}...' : userMsg.text;
    }

    await _historyService.saveSession(_sessionId, messagesJson, title);
  }

  Future<void> _loadSession(String sessionId) async {
    final session = await _historyService.getSession(sessionId);
    if (session == null) return;

    setState(() {
      _sessionId = sessionId;
      _messages.clear();
      final List<dynamic> msgs = session['messages'] ?? [];
      for (var m in msgs) {
        _messages.add(ChatMessage(
          text: m['text'],
          isUser: m['isUser'],
          timestamp: DateTime.parse(m['timestamp']),
        ));
      }
      _showSuggestions = _messages.length <= 1; // Only show if empty or just welcome
    });
    Navigator.pop(context); // Close drawer
  }

  Future<void> _deleteSession(String sessionId) async {
    await _historyService.deleteSession(sessionId);
    if (_sessionId == sessionId) {
       // If current was deleted, clear it
       setState(() {
         _messages.clear();
         _addWelcomeMessage();
         _sessionId = const Uuid().v4();
       });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildHistoryDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            const MiabeLogo(size: 28),
            const SizedBox(width: 12),
            Text(
              'Assistant IA',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Nouvelle conversation',
            onPressed: () {
              setState(() {
                _messages.clear();
                _sessionId = const Uuid().v4();
                _addWelcomeMessage();
                _showSuggestions = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_showSuggestions && _messages.length == 1) _buildSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser 
              ? const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser 
              ? null 
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 24),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser 
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUser 
              ? null 
              : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
        ),
        child: MarkdownBody(
          data: message.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            code: TextStyle(
              backgroundColor: isUser ? Colors.white24 : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
              color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            codeblockDecoration: BoxDecoration(
              color: isUser ? Colors.black12 : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildTypingIndicator() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
             margin: const EdgeInsets.only(bottom: 16, left: 8),
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: AppTheme.softShadow,
             ),
             child: const SizedBox(
                width: 40, 
                height: 20, 
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
             ),
        ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = MistralService.getSuggestions();
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(suggestions[index]),
            labelStyle: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            backgroundColor: Theme.of(context).cardTheme.color,
            elevation: 0,
            side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () => _sendMessage(suggestions[index]),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.softShadow,
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Posez votre question...',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _sendMessage(_messageController.text),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white, size: 30),
                const SizedBox(width: 16),
                Text(
                  'Historique',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _historyService.getSessionIds(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final sessionIds = snapshot.data!;
                if (sessionIds.isEmpty) {
                  return const Center(child: Text('Aucun historique'));
                }
                
                return ListView.separated(
                  itemCount: sessionIds.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final id = sessionIds[index];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _historyService.getSession(id),
                      builder: (context, itemSnapshot) {
                         if (!itemSnapshot.hasData) return const SizedBox.shrink();
                         final session = itemSnapshot.data!;
                         final title = session['title'] ?? 'Discussion sans titre';
                         final date = DateTime.tryParse(session['timestamp'] ?? '');
                         final isSelected = id == _sessionId;

                         return ListTile(
                           title: Text(
                             title, 
                             maxLines: 1, 
                             overflow: TextOverflow.ellipsis,
                             style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                           ),
                           subtitle: date != null ? Text('${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}') : null,
                           selected: isSelected,
                           selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                           onTap: () => _loadSession(id),
                           trailing: IconButton(
                             icon: const Icon(Icons.delete_outline, size: 20),
                             onPressed: () async {
                               await _deleteSession(id);
                               setState(() {}); // Refresh list
                             },
                           ),
                         );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Tout effacer'),
            onTap: () async {
               // Confirm dialog
               final confirm = await showDialog<bool>(
                 context: context,
                 builder: (c) => AlertDialog(
                   title: const Text('Tout effacer ?'),
                   content: const Text('Voulez-vous vraiment supprimer tout l\'historique ?'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')),
                     TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
                   ],
                 ),
               );
               
               if (confirm == true) {
                 await _historyService.clearAll();
                 setState(() {
                   _messages.clear();
                   _addWelcomeMessage();
                   _sessionId = const Uuid().v4();
                 });
                 if (mounted && Navigator.canPop(context)) Navigator.pop(context); // Close drawer
               }
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

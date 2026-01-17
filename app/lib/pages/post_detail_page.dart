import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../widgets/mention_text.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _userPseudo;
  String? _userId;
  RealtimeChannel? _viewsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadComments();
    _incrementViews();
    _subscribeToPostChanges();
    
    // Écouter les changements d'état d'authentification Firebase
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null && mounted && (_userId == null || _userId!.isEmpty)) {
        debugPrint('Firebase Auth state changed, reloading user data');
        _loadUserData();
      }
    });
  }

  @override
  void dispose() {
    _viewsSubscription?.unsubscribe();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    
    debugPrint('=== Loading User Data ===');
    debugPrint('Supabase user: ${supabaseUser?.id}');
    debugPrint('Firebase user: ${firebaseUser?.uid}');
    debugPrint('Firebase email: ${firebaseUser?.email}');
    debugPrint('Prefs email: ${prefs.getString('email')}');
    
    // Si pas d'utilisateur Supabase, créer un UUID valide à partir de l'email Firebase
    String? userId = supabaseUser?.id;
    String? email = prefs.getString('email') ?? firebaseUser?.email;
    String? pseudo = prefs.getString('pseudo') ?? firebaseUser?.displayName;
    
    if (userId == null || userId.isEmpty) {
      if (email != null && email.isNotEmpty) {
        // Générer un UUID v5 valide à partir de l'email
        const uuid = Uuid();
        userId = uuid.v5(Uuid.NAMESPACE_DNS, email);
        debugPrint('Generated UUID v5 from email: $userId');
        
        // Sauvegarder l'email et pseudo si pas déjà fait
        if (prefs.getString('email') == null) {
          await prefs.setString('email', email);
          debugPrint('Saved email to prefs: $email');
        }
        if (prefs.getString('pseudo') == null && pseudo != null) {
          await prefs.setString('pseudo', pseudo);
          debugPrint('Saved pseudo to prefs: $pseudo');
        }
      } else if (firebaseUser != null) {
        // Fallback: utiliser le UID Firebase comme base pour générer un UUID v5
        const uuid = Uuid();
        userId = uuid.v5(Uuid.NAMESPACE_DNS, firebaseUser.uid);
        debugPrint('Generated UUID v5 from Firebase UID: $userId');
      }
    }
    
    setState(() {
      _userPseudo = pseudo ?? 'Étudiant';
      _userId = userId;
    });
    
    debugPrint('Final User ID: $_userId');
    debugPrint('Final Pseudo: $_userPseudo');
  }

  Future<void> _incrementViews() async {
    // Optimistic update locally
    setState(() {
       widget.post['views'] = (widget.post['views'] ?? 0) + 1;
    });

    try {
      await Supabase.instance.client
          .from('campus_posts')
          .update({'views': widget.post['views']})
          .eq('id', widget.post['id']);
    } catch (e) {
      debugPrint('Erreur incrémentation vues: $e');
    }
  }

  void _subscribeToPostChanges() {
    _viewsSubscription = Supabase.instance.client
        .channel('public:campus_posts:${widget.post['id']}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'campus_posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.post['id'],
          ),
          callback: (payload) {
             if (payload.newRecord['views'] != null) {
               if (mounted) {
                 setState(() {
                   widget.post['views'] = payload.newRecord['views'];
                 });
               }
             }
          },
        )
        .subscribe();
  }

  Future<void> _loadComments() async {
    try {
      final response = await Supabase.instance.client
          .from('campus_comments')
          .select()
          .eq('post_id', widget.post['id'])
          .order('created_at', ascending: true);

      setState(() {
        _comments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement commentaires: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un commentaire')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.from('campus_comments').insert({
        'post_id': widget.post['id'],
        'author': _userPseudo,
        'author_id': _userId,
        'content': _commentController.text.trim(),
      });

      // Créer une notification pour l'auteur du post
      if (_userId != widget.post['author_id']) {
        await Supabase.instance.client.from('campus_notifications').insert({
          'user_id': widget.post['author_id'],
          'type': 'comment',
          'title': 'Nouveau commentaire',
          'message': '$_userPseudo a commenté votre publication',
          'post_id': widget.post['id'],
        });
      }

      _commentController.clear();
      _loadComments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commentaire ajouté !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _toggleLike(String contentType, String contentId, int currentLikes) async {
    // Vérifier que l'utilisateur est connecté
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour liker')),
      );
      return;
    }

    try {
      // Vérifier si l'utilisateur a déjà liké
      final existingLike = await Supabase.instance.client
          .from('campus_likes')
          .select()
          .eq('user_id', _userId!)
          .eq('content_type', contentType)
          .eq('content_id', contentId)
          .maybeSingle();

      if (existingLike == null) {
        // Ajouter le like
        await Supabase.instance.client.from('campus_likes').insert({
          'user_id': _userId,
          'content_type': contentType,
          'content_id': contentId,
        });

        // Incrémenter le compteur
        final table = contentType == 'post' ? 'campus_posts' : 'campus_comments';
        await Supabase.instance.client
            .from(table)
            .update({'likes': currentLikes + 1})
            .eq('id', contentId);
      } else {
        // Retirer le like
        await Supabase.instance.client
            .from('campus_likes')
            .delete()
            .eq('id', existingLike['id']);

        // Décrémenter le compteur
        final table = contentType == 'post' ? 'campus_posts' : 'campus_comments';
        await Supabase.instance.client
            .from(table)
            .update({'likes': currentLikes - 1})
            .eq('id', contentId);
      }

      // Recharger les données
      if (contentType == 'post') {
        // Recharger le post depuis la base
        final updatedPost = await Supabase.instance.client
            .from('campus_posts')
            .select()
            .eq('id', contentId)
            .single();
        
        setState(() {
          widget.post['likes'] = updatedPost['likes'];
        });
      } else {
        _loadComments();
      }
    } catch (e) {
      debugPrint('Erreur toggle like: $e');
    }
  }

  Future<void> _reportContent(String contentType, String contentId) async {
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un contenu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pourquoi signalez-vous ce contenu ?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Raison',
                  border: OutlineInputBorder(),
                  hintText: 'Spam, contenu inapproprié, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.from('campus_reports').insert({
                  'content_type': contentType,
                  'content_id': contentId,
                  'reporter_id': _userId,
                  'reporter_pseudo': _userPseudo,
                  'reason': reasonController.text.trim(),
                  'description': descriptionController.text.trim(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signalement envoyé')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsResolved() async {
    try {
      await Supabase.instance.client
          .from('campus_posts')
          .update({'is_resolved': !widget.post['is_resolved']})
          .eq('id', widget.post['id']);

      setState(() {
        widget.post['is_resolved'] = !widget.post['is_resolved'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.post['is_resolved'] 
            ? 'Question marquée comme résolue' 
            : 'Question marquée comme non résolue'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deletePost() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer la publication'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await Supabase.instance.client
            .from('campus_posts')
            .delete()
            .eq('id', widget.post['id']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication supprimée')),
          );
          Navigator.pop(context, true); // Retourner true pour indiquer la suppression
        }
      }
    } catch (e) {
      debugPrint('Erreur suppression post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postType = widget.post['type'];
    final isQuestion = postType == 'question';
    final isResolved = widget.post['is_resolved'] ?? false;
    final isAuthor = _userId == widget.post['author_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        actions: [
          if (isQuestion && isAuthor)
            IconButton(
              icon: Icon(isResolved ? Icons.check_circle : Icons.check_circle_outline),
              onPressed: _markAsResolved,
              tooltip: isResolved ? 'Marquer comme non résolu' : 'Marquer comme résolu',
            ),
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deletePost,
              tooltip: 'Supprimer la publication',
            ),
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _reportContent('post', widget.post['id']),
            tooltip: 'Signaler',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPostHeader(),
                      const SizedBox(height: 16),
                      _buildPostContent(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            '${_comments.length} Commentaire${_comments.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ..._comments.map((comment) => _buildCommentCard(comment)),
                    ],
                  ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    final createdAt = DateTime.parse(widget.post['created_at']);
    final postType = widget.post['type'];
    final isResolved = widget.post['is_resolved'] ?? false;

    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (postType) {
      case 'question':
        typeColor = isResolved ? Colors.green : AppTheme.primary;
        typeIcon = isResolved ? Icons.check_circle : Icons.help;
        typeLabel = isResolved ? 'Résolu' : 'Question';
        break;
      case 'conseil':
        typeColor = Colors.orange;
        typeIcon = Icons.lightbulb;
        typeLabel = 'Conseil';
        break;
      default:
        typeColor = Colors.purple;
        typeIcon = Icons.campaign;
        typeLabel = 'Annonce';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: Icon(typeIcon, size: 16, color: Colors.white),
                  label: Text(typeLabel),
                  backgroundColor: typeColor,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  child: Text(widget.post['author'][0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post['author'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.post['filiere']} • ${widget.post['semestre']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    final hasAttachment = widget.post['attachment_url'] != null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post['title'],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            MentionText(
              text: widget.post['content'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (hasAttachment) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(widget.post['attachment_url']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(widget.post['attachment_type'] ?? ''),
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post['attachment_name'] ?? 'Fichier joint',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Cliquez pour ouvrir',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new, size: 20, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 20),
                  onPressed: () => _toggleLike('post', widget.post['id'], widget.post['likes'] ?? 0),
                ),
                Text('${widget.post['likes'] ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.visibility, size: 20),
                const SizedBox(width: 4),
                Text('${widget.post['views'] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final createdAt = DateTime.parse(comment['created_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment['author'][0].toUpperCase(), style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['author'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy à HH:mm').format(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  onPressed: () => _reportContent('comment', comment['id']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MentionText(text: comment['content']),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  onPressed: () => _toggleLike('comment', comment['id'], comment['likes'] ?? 0),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text('${comment['likes'] ?? 0}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                enabled: !_isSubmitting,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isSubmitting ? null : _addComment,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

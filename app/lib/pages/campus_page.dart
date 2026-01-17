import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:miabeassistant/pages/post_detail_page.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../widgets/document_mention_field.dart';
import '../widgets/mention_text.dart';
import '../constants/app_theme.dart';

/// Page Campus Collaboratif - Apprentissage entre pairs
// Diacritic package removed — using internal sanitization instead.
class CampusPage extends StatefulWidget {
  const CampusPage({super.key});

  @override
  State<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends State<CampusPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _userFiliere;
  String? _userSemestre;
  String? _userPseudo;
  String? _userId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  int _membersCount = 0;
  RealtimeChannel? _membersSubscription;
  List<Map<String, dynamic>> _filteredPosts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    
    // Écouter les changements d'état d'authentification Firebase
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null && mounted && (_userId == null || _userId!.isEmpty)) {
        debugPrint('Firebase Auth state changed in Campus, reloading user profile');
        _loadUserProfile();
      }
    });
  }

  @override
  void dispose() {
    _membersSubscription?.unsubscribe();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    
    // Générer un UUID v5 depuis Firebase si Supabase user est null
    String? userId = supabaseUser?.id;
    if (userId == null || userId.isEmpty) {
      final email = prefs.getString('email') ?? firebaseUser?.email;
      if (email != null && email.isNotEmpty) {
        const uuid = Uuid();
        userId = uuid.v5(Uuid.NAMESPACE_DNS, email);
      }
    }
    
    setState(() {
      _userFiliere = prefs.getString('filiere');
      _userSemestre = prefs.getString('semestre');
      _userPseudo = prefs.getString('pseudo') ?? firebaseUser?.displayName ?? 'Étudiant';
      _userId = userId;
      _isLoading = false;
    });
    
    if (_userFiliere != null && _userSemestre != null) {
      _loadCampusData();
    }
  }

  Future<void> _loadCampusData() async {
    // Charger les posts depuis Supabase
    try {
      final supabase = Supabase.instance.client;

      // Charger les posts de la communauté
      final postsResponse = await supabase
          .from('campus_posts')
          .select()
          .eq('filiere', _userFiliere!)
          .eq('semestre', _userSemestre!)
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(postsResponse as List<dynamic>);
        _filteredPosts = _posts;
      });

      _updateMembership();
      _loadMemberCount();
      _subscribeToMemberChanges();
    } catch (e) {
      debugPrint('Erreur chargement campus: $e');
    }
  }

  Future<void> _updateMembership() async {
    if (_userId == null || _userFiliere == null || _userSemestre == null) return;
    try {
      final backend = AppConfig.backendUrl;
      final payload = {
        'user_id': _userId,
        'pseudo': _userPseudo,
        'filiere': _userFiliere,
        'semestre': _userSemestre,
        'last_active': DateTime.now().toIso8601String(),
      };

      if (backend.isNotEmpty) {
        final resp = await http.post(
          Uri.parse('$backend/api/members'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return;
        } else {
          debugPrint('Backend members upsert failed: ${resp.statusCode} ${resp.body}');
        }
      }

      // Fallback to client-side Supabase upsert if backend not configured
      await Supabase.instance.client.from('campus_members').upsert(payload, onConflict: 'user_id');
    } catch (e) {
      debugPrint('Error updating membership: $e');
    }
  }

  Future<void> _loadMemberCount() async {
    try {
      final count = await Supabase.instance.client
          .from('campus_members')
          .count(CountOption.exact)
          .eq('filiere', _userFiliere!)
          .eq('semestre', _userSemestre!);
      if (mounted) setState(() => _membersCount = count as int? ?? 0);
    } catch (e) {
      debugPrint('Error loading member count: $e');
    }
  }

  void _subscribeToMemberChanges() {
    _membersSubscription?.unsubscribe();
    _membersSubscription = Supabase.instance.client
        .channel('public:campus_members')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'campus_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'filiere',
            value: _userFiliere,
          ),
          callback: (payload) {
            _loadMemberCount();
          },
        )
        .subscribe();
  }

  void _filterContent(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _posts;
      } else {
        _filteredPosts = _posts.where((post) {
          return post['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              post['content'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Vérifier si l'utilisateur est connecté
    if (firebase_auth.FirebaseAuth.instance.currentUser == null) {
      return _buildNotLoggedInView();
    }

    if (_userFiliere == null || _userSemestre == null) {
      return _buildNoProfileView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Collaboratif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _getCampusInfo(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Règles de la communauté',
            onPressed: () => _showRulesDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _showChangeCommunityDialog,
            tooltip: 'Changer de communauté',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCampusData,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterContent('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _filterContent,
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.forum), text: 'Discussions'),
                  Tab(icon: Icon(Icons.people), text: 'Communauté'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscussionsTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Discuter'),
      ),
    );
  }

  String _getCampusInfo() {
    return '$_userFiliere • $_userSemestre';
  }

  String _sanitizePath(String input) {
    // Basic sanitization: remove accents and special chars
    // Since we don't know if 'diacritic' package is available, we do a basic replacement map
    // or just regex to allow word chars.
    // Ideally we want "Génie Mécanique" -> "Genie_Mecanique"
    
    var output = input.toLowerCase();
    output = output.replaceAll(RegExp(r'[éèêë]'), 'e');
    output = output.replaceAll(RegExp(r'[àâ]'), 'a');
    output = output.replaceAll(RegExp(r'[ùû]'), 'u');
    output = output.replaceAll(RegExp(r'[îï]'), 'i');
    output = output.replaceAll(RegExp(r'[ôö]'), 'o');
    output = output.replaceAll(RegExp(r'[ç]'), 'c');
    output = output.replaceAll(RegExp(r'[^a-z0-9\._-]'), '_'); // Replace spaces and other chars with _
    output = output.replaceAll(RegExp(r'_+'), '_'); // Merge multiple underscores
    return output;
  }

  // Dialogue pour changer de communauté
  void _showChangeCommunityDialog() {
    final List<String> filieres = [
      'Licence Fondamentale - Génie Civil',
      'Licence Fondamentale - Génie Électrique',
      'Licence Fondamentale - Génie Mécanique',
      'Licence Fondamentale - Intelligence Artificielle & Big Data',
      'Licence Fondamentale - Informatique et Système',
      'Licence Fondamentale - Logistique et Transport',
      'Licence Professionnelle - Génie Logiciel',
    ];
    
    final List<String> semestres = [
      'Semestre 1',
      'Semestre 2',
      'Semestre 3',
      'Semestre 4',
      'Semestre 5',
      'Semestre 6',
    ];
    
    String selectedFiliere = _userFiliere ?? filieres[0];
    String selectedSemestre = _userSemestre ?? semestres[0];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer de communauté'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sélectionnez la communauté que vous souhaitez rejoindre :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedFiliere,
                decoration: const InputDecoration(
                  labelText: 'Filière',
                  border: OutlineInputBorder(),
                ),
                items: filieres.map((filiere) {
                  return DropdownMenuItem(
                    value: filiere,
                    child: Text(
                      filiere,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedFiliere = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedSemestre,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  border: OutlineInputBorder(),
                ),
                items: semestres.map((semestre) {
                  return DropdownMenuItem(
                    value: semestre,
                    child: Text(semestre),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedSemestre = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'ℹ️ Ceci ne modifiera pas votre profil principal',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _userFiliere = selectedFiliere;
                  _userSemestre = selectedSemestre;
                });
                await _loadCampusData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Communauté changée : $selectedFiliere • $selectedSemestre'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Rejoindre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Collaboratif')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Connexion requise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vous devez être connecté pour accéder au Campus Collaboratif.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login),
                label: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfileView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Collaboratif')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Complétez votre profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Renseignez votre filière et semestre pour rejoindre votre communauté campus.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modifier mon profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Onglet Discussions
  Widget _buildDiscussionsTab() {
    return RefreshIndicator(
      onRefresh: _loadCampusData,
      child: _filteredPosts.isEmpty
          ? _buildEmptyState(
              icon: Icons.forum,
              title: 'Aucune discussion',
              message: _searchController.text.isNotEmpty
                  ? 'Aucun résultat pour votre recherche'
                  : 'Soyez le premier à poser une question ou partager un conseil !',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                final post = _filteredPosts[index];
                return _buildPostCard(post);
              },
            ),
    );
  }

  // Onglet Communauté
  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          icon: Icons.people,
          title: 'Votre Communauté',
          subtitle: _getCampusInfo(),
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatsCard(),
        const SizedBox(height: 16),
        _buildRulesCard(),
      ],
    );
  }

  Future<void> _deletePost(String postId) async {
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
            .eq('id', postId);
        
        _loadCampusData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication supprimée')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur suppression post: $e');
    }
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final createdAt = DateTime.parse(post['created_at'] ?? DateTime.now().toIso8601String());
    final timeAgo = _getTimeAgo(createdAt);
    final isAuthor = _userId == post['author_id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPostDetails(post),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      (post['author'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['author'] ?? 'Anonyme',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (post['type'] != null)
                    Chip(
                      label: Text(
                        post['type'],
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: _getTypeColor(post['type']),
                      padding: EdgeInsets.zero,
                    ),
                  if (isAuthor)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost(post['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post['title'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (post['content'] != null) ...[
                const SizedBox(height: 8),
                MentionText(
                  text: post['content'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              if (post['type'] == 'file_share' && post['attachment_url'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(post['attachment_type'] ?? ''),
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post['attachment_name'] ?? 'Fichier joint',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.download, size: 18, color: AppTheme.primary),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.thumb_up_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${post['likes'] ?? 0}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${post['comments_count'] ?? 0}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques de la communauté',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.forum,
                  label: 'Discussions',
                  value: '${_posts.length}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Membres',
                  value: '$_membersCount', // Display real count
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRulesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Règles de la communauté',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRuleItem('Respectez vos camarades'),
            _buildRuleItem('Partagez du contenu de qualité'),
            _buildRuleItem('Entraidez-vous mutuellement'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔒 Anonymat préservé : Seul votre pseudo est visible dans la communauté. Votre nom, prénom et email restent privés.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Règles de la communauté'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Respectez vos camarades'),
              SizedBox(height: 8),
              Text('Partagez du contenu de qualité'),
              SizedBox(height: 8),
              Text('Entraidez-vous mutuellement'),
              SizedBox(height: 12),
              Text('🔒 Anonymat préservé : Seul votre pseudo est visible dans la communauté.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'question':
        return Colors.blue[100]!;
      case 'conseil':
        return Colors.green[100]!;
      case 'aide':
        return Colors.orange[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Que voulez-vous partager ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez le type de contenu à partager avec votre communauté',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.forum, color: Colors.blue),
                ),
                title: const Text('Poser une question'),
                subtitle: const Text('Demandez de l\'aide à la communauté\n💡 Astuce : Utilisez @ pour mentionner un document'),
                isThreeLine: true,
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePostDialog('question');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.green),
                ),
                title: const Text('Partager un conseil'),
                subtitle: const Text('Aidez vos camarades avec vos astuces'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePostDialog('conseil');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePostDialog(String type) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(type == 'question' ? 'Poser une question' : 'Partager un conseil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                DocumentMentionField(
                  controller: contentController,
                  labelText: type == 'question' ? 'Détails de votre question' : 'Contenu du conseil',
                  hintText: type == 'question'
                      ? 'Expliquez votre problème ici...'
                      : 'Partagez votre astuce avec la communauté...',
                  helperText: '💡 Utilisez @ devant un mot-clé pour référencer un document (ex: @algorithme)',
                  maxLines: 5,
                  maxLength: 500,
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
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez saisir un titre')),
                  );
                  return;
                }

                try {
                  final supabase = Supabase.instance.client;

                  // Insert post directly via Supabase (RLS policies allow public insert)
                  await supabase.from('campus_posts').insert({
                    'filiere': _userFiliere,
                    'semestre': _userSemestre,
                    'author': _userPseudo,
                    'author_id': _userId,
                    'type': type,
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                    'likes': 0,
                    'comments_count': 0,
                  });

                  Navigator.pop(context);
                  _loadCampusData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publication créée avec succès !')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetails(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    ).then((_) => _loadCampusData()); // Recharger après retour
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
}


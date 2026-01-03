import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:miabeassistant/pages/post_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Page Campus Collaboratif - Apprentissage entre pairs
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
  List<Map<String, dynamic>> _fiches = [];
  List<Map<String, dynamic>> _filteredPosts = [];
  List<Map<String, dynamic>> _filteredFiches = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    // Charger les posts et fiches depuis Supabase
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
      
      // Charger les fiches partagées
      final fichesResponse = await supabase
          .from('campus_fiches')
          .select()
          .eq('filiere', _userFiliere!)
          .eq('semestre', _userSemestre!)
          .order('created_at', ascending: false)
          .limit(50);
      
      setState(() {
        _posts = List<Map<String, dynamic>>.from(postsResponse);
        _fiches = List<Map<String, dynamic>>.from(fichesResponse);
        _filteredPosts = _posts;
        _filteredFiches = _fiches;
      });
    } catch (e) {
      debugPrint('Erreur chargement campus: $e');
    }
  }

  void _filterContent(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _posts;
        _filteredFiches = _fiches;
      } else {
        _filteredPosts = _posts.where((post) {
          return post['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
                 post['content'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
        
        _filteredFiches = _fiches.where((fiche) {
          return fiche['titre'].toString().toLowerCase().contains(query.toLowerCase()) ||
                 (fiche['description']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
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
                  Tab(icon: Icon(Icons.description), text: 'Fiches'),
                  Tab(icon: Icon(Icons.people), text: 'Communauté'),
                ],
              ),
            ],
          ),
        ),
        actions: [
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscussionsTab(),
          _buildFichesTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Partager'),
      ),
    );
  }

  String _getCampusInfo() {
    return '$_userFiliere • $_userSemestre';
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

  // Onglet Fiches
  Widget _buildFichesTab() {
    return RefreshIndicator(
      onRefresh: _loadCampusData,
      child: _filteredFiches.isEmpty
          ? _buildEmptyState(
              icon: Icons.description,
              title: 'Aucune fiche partagée',
              message: _searchController.text.isNotEmpty
                  ? 'Aucun résultat pour votre recherche'
                  : 'Partagez vos fiches de révision avec vos camarades !',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFiches.length,
              itemBuilder: (context, index) {
                final fiche = _filteredFiches[index];
                return _buildFicheCard(fiche);
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

  Widget _buildPostCard(Map<String, dynamic> post) {
    final createdAt = DateTime.parse(post['created_at'] ?? DateTime.now().toIso8601String());
    final timeAgo = _getTimeAgo(createdAt);

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
                Text(
                  post['content'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
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

  Widget _buildFicheCard(Map<String, dynamic> fiche) {
    final createdAt = DateTime.parse(fiche['created_at'] ?? DateTime.now().toIso8601String());
    final timeAgo = _getTimeAgo(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFicheDetails(fiche),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fiche['title'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Par ${fiche['author'] ?? 'Anonyme'} • $timeAgo',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (fiche['matiere'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        fiche['matiere'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.download, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${fiche['downloads'] ?? 0}'),
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
                  icon: Icons.description,
                  label: 'Fiches',
                  value: '${_fiches.length}',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Membres',
                  value: '~',
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
            _buildRuleItem('Pas de plagiat ou de triche'),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Que voulez-vous partager ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.forum, color: Colors.blue),
              title: const Text('Poser une question'),
              subtitle: const Text('Demandez de l\'aide à la communauté'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePostDialog('question');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.green),
              title: const Text('Partager un conseil'),
              subtitle: const Text('Aidez vos camarades'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePostDialog('conseil');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.orange),
              title: const Text('Partager une fiche'),
              subtitle: const Text('Partagez vos fiches de révision'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFicheDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(String type) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    PlatformFile? attachedFile;

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
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
                      withData: true,
                    );

                    if (result != null) {
                      setDialogState(() {
                        attachedFile = result.files.first;
                      });
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    attachedFile == null 
                        ? 'Joindre un fichier (optionnel)' 
                        : attachedFile!.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (attachedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${(attachedFile!.size / 1024).toStringAsFixed(1)} KB',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setDialogState(() {
                              attachedFile = null;
                            });
                          },
                        ),
                      ],
                    ),
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
                String? attachmentUrl;
                String? attachmentName;
                String? attachmentType;

                // Upload du fichier joint si présent
                if (attachedFile != null) {
                  if (_userFiliere == null || _userSemestre == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complétez votre profil (filière et semestre) avant de partager un fichier')),
                    );
                    return;
                  }

                  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${attachedFile!.name}';
                  final storagePath = 'campus_attachments/$_userFiliere/$_userSemestre/$fileName';

                  if (kIsWeb) {
                    if (attachedFile!.bytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aucun contenu trouvé pour ce fichier (web)')),
                      );
                      return;
                    }
                    await supabase.storage
                        .from('campus_files')
                        .uploadBinary(storagePath, attachedFile!.bytes!);
                  } else {
                    final filePathOnDisk = attachedFile!.path;
                    if (filePathOnDisk == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chemin de fichier introuvable')),
                      );
                      return;
                    }
                    final file = File(filePathOnDisk);
                    await supabase.storage
                        .from('campus_files')
                        .upload(storagePath, file);
                  }

                  attachmentUrl = supabase.storage
                      .from('campus_files')
                      .getPublicUrl(storagePath);
                  
                  attachmentName = attachedFile!.name;
                  attachmentType = attachedFile!.extension ?? 'unknown';
                }

                await supabase.from('campus_posts').insert({
                  'filiere': _userFiliere,
                  'semestre': _userSemestre,
                  'author': _userPseudo,
                  'author_id': _userId,
                  'type': type,
                  'title': titleController.text.trim(),
                  'content': contentController.text.trim(),
                  'attachment_url': attachmentUrl,
                  'attachment_name': attachmentName,
                  'attachment_type': attachmentType,
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

  void _showFicheDetails(Map<String, dynamic> fiche) async {
    try {
      // Incrémenter le compteur de téléchargements
      await Supabase.instance.client
          .from('campus_fiches')
          .update({'downloads': (fiche['downloads'] ?? 0) + 1})
          .eq('id', fiche['id']);

      // Ouvrir le fichier
      final url = Uri.parse(fiche['file_url']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showCreateFicheDialog() async {
    final titreController = TextEditingController();
    final matiereController = TextEditingController();
    final descriptionController = TextEditingController();
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Partager une fiche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titreController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: matiereController,
                  decoration: const InputDecoration(
                    labelText: 'Matière',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                      withData: true,
                    );

                    if (result != null) {
                      setDialogState(() {
                        selectedFile = result.files.first;
                      });
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(selectedFile == null 
                      ? 'Sélectionner un fichier' 
                      : selectedFile!.name),
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
                if (titreController.text.trim().isEmpty || 
                    matiereController.text.trim().isEmpty ||
                    selectedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                try {
                  // Upload du fichier vers Supabase Storage
                  if (_userFiliere == null || _userSemestre == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complétez votre profil (filière et semestre) avant de partager une fiche')),
                    );
                    return;
                  }

                  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}';
                  final storagePath = 'campus_fiches/$_userFiliere/$_userSemestre/$fileName';

                  if (kIsWeb) {
                    if (selectedFile!.bytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aucun contenu trouvé pour ce fichier (web)')),
                      );
                      return;
                    }
                    await Supabase.instance.client.storage
                        .from('campus_files')
                        .uploadBinary(storagePath, selectedFile!.bytes!);
                  } else {
                    final filePathOnDisk = selectedFile!.path;
                    if (filePathOnDisk == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chemin de fichier introuvable')),
                      );
                      return;
                    }
                    final file = File(filePathOnDisk);
                    await Supabase.instance.client.storage
                        .from('campus_files')
                        .upload(storagePath, file);
                  }

                  final fileUrl = Supabase.instance.client.storage
                      .from('campus_files')
                      .getPublicUrl(storagePath);

                  // Enregistrer dans la base de données
                  await Supabase.instance.client.from('campus_fiches').insert({
                    'filiere': _userFiliere,
                    'semestre': _userSemestre,
                    'matiere': matiereController.text.trim(),
                    'titre': titreController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'author': _userPseudo,
                    'author_id': _userId,
                    'file_url': fileUrl,
                    'file_name': selectedFile!.name,
                    'file_type': selectedFile!.extension ?? 'unknown',
                    'file_size': selectedFile!.size,
                  });

                  Navigator.pop(context);
                  _loadCampusData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fiche partagée avec succès !')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
              child: const Text('Partager'),
            ),
          ],
        ),
      ),
    );
  }
}

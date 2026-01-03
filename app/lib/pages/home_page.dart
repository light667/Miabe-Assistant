import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miabeassistant/pages/chat_page.dart';
import 'package:miabeassistant/pages/resources_page.dart';
import 'package:miabeassistant/pages/campus_page.dart';
import 'package:miabeassistant/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _pseudo = 'Utilisateur';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final firebasePseudo = user?.displayName;
      final prefs = await SharedPreferences.getInstance();
      final storedPseudo = prefs.getString('pseudo');

      if (mounted) {
        setState(() {
          _pseudo = firebasePseudo ?? storedPseudo ?? 'Utilisateur';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeContent(pseudo: _pseudo);
      case 1:
        return const ChatPage(title: 'Assistant');
      case 2:
        return const ResourcesPage();
      case 3:
        return const CampusPage();
      case 4:
        return const SettingsPage(title: 'Paramètres');
      default:
        return HomeContent(pseudo: _pseudo);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _buildPage(_selectedIndex).animate().fadeIn(duration: 400.ms),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                     return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary);
                }
                return TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Theme.of(context).hintColor);
              }),
            ),
            child: NavigationBar(
              height: 65,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
              destinations: const [
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.house, size: 20, color: AppTheme.primary), label: 'Accueil'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.robot, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.robot, size: 20, color: AppTheme.primary), label: 'Assistant'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.bookOpen, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.bookOpen, size: 20, color: AppTheme.primary), label: 'Cours'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.users, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.users, size: 20, color: AppTheme.primary), label: 'Campus'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.gear, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.gear, size: 20, color: AppTheme.primary), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String pseudo;
  const HomeContent({super.key, required this.pseudo});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedSkillCategory = 'Tout';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 180.0,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          forceElevated: false,
          flexibleSpace: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
              background: ClipRect(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark 
                           ? [AppTheme.primaryDark.withValues(alpha: 0.2), Theme.of(context).scaffoldBackgroundColor]
                           : [const Color(0xFFF1F5F9), Theme.of(context).scaffoldBackgroundColor],
                      ),
                    ),
                    child: Stack(
                      children: [
                         Positioned(
                          right: -20,
                          top: -20,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
                          ),
                         ),
                         Padding(
                           padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Text(
                                "Bonjour, ${widget.pseudo}",
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                               ).animate().fadeIn().moveX(begin: -10, end: 0),
                               const SizedBox(height: 8),
                               Text(
                                "Prêt à exceller aujourd'hui ?",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 16,
                                ),
                               ).animate().fadeIn(delay: 100.ms),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Quick Actions
                 Text("Accès Rapide", style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 16),
                 Row(
                   children: [
                     Expanded(child: _buildQuickActionCard(context, "Mes Cours", FontAwesomeIcons.bookOpen, AppTheme.primary, () => Navigator.pushNamed(context, '/resources'))),
                     const SizedBox(width: 16),
                     Expanded(child: _buildQuickActionCard(context, "Mon Assistant", FontAwesomeIcons.robot, AppTheme.secondary, () => Navigator.pushNamed(context, '/chat'))),
                   ],
                 ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                 
                 const SizedBox(height: 32),
                 
                 // Skills Section
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("Compétences", style: Theme.of(context).textTheme.titleLarge),
                     IconButton(icon: const Icon(Icons.tune, size: 20), onPressed: () {}),
                   ],
                 ),
                 
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Row(
                     children: [
                       _buildCategoryChip('Tout'),
                       _buildCategoryChip('Général'),
                       _buildCategoryChip('Programmation'),
                       _buildCategoryChip('Génie Civil'),
                       _buildCategoryChip('Langues'),
                     ],
                   ),
                 ),
                 const SizedBox(height: 16),
                 
                 ..._getSkillsByCategory(context, _selectedSkillCategory),
                 
                 const SizedBox(height: 32),
                 
                 // Platforms
                 Text("Plateformes d'apprentissage en ligne", style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 8),
                 Text(
                   "Découvrez les meilleures plateformes pour renforcer vos compétences techniques.",
                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                 ),
                 const SizedBox(height: 16),
                 _buildLearningPlatformCard(context, title: "DataCamp", description: "Apprenez la science des données et l'analyse avec Python, R et SQL.", icon: FontAwesomeIcons.chartLine, url: "https://www.datacamp.com/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "Moodle", description: "Plateforme d'apprentissage open source utilisée par les universités.", icon: FontAwesomeIcons.graduationCap, url: "https://moodle.org/?lang=fr"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "SoloLearn", description: "Apprenez à coder sur mobile avec des cours interactifs.", icon: FontAwesomeIcons.mobile, url: "https://www.sololearn.com/en/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "Coursera", description: "Cours en ligne des meilleures universités mondiales.", icon: FontAwesomeIcons.buildingColumns, url: "https://www.coursera.org/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "freeCodeCamp", description: "Apprenez le développement web gratuitement avec des projets pratiques.", icon: FontAwesomeIcons.code, url: "https://www.freecodecamp.org/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "HackerRank", description: "Améliorez vos compétences en programmation grâce à des défis codés.", icon: FontAwesomeIcons.laptopCode, url: "https://www.hackerrank.com/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "OpenClassrooms", description: "Formations en ligne avec mentorat pour obtenir des diplômes reconnus.", icon: FontAwesomeIcons.desktop, url: "https://openclassrooms.com/fr/"),
                 const SizedBox(height: 12),
                 _buildLearningPlatformCard(context, title: "Simplilearn", description: "Formations certifiantes en digital skills et technologies émergentes.", icon: FontAwesomeIcons.rocket, url: "https://www.simplilearn.com/"),
                 
                 const SizedBox(height: 24),
                 
                 Center(
                   child: Text(
                     'Explorez et réussissez avec Miabe Assistant !',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                       fontStyle: FontStyle.italic,
                     ),
                   ).animate().fadeIn(duration: 2400.ms).slideY(),
                 ),
                 
                 // Bottom spacing for nav bar
                 const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, color: color, size: 20),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedSkillCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() => _selectedSkillCategory = label);
        },
        selectedColor: AppTheme.primary.withValues(alpha: 0.1),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
           side: BorderSide(color: isSelected ? AppTheme.primary : Theme.of(context).dividerColor),
        ),
        backgroundColor: Colors.transparent,
        showCheckmark: false,
      ),
    );
  }

  List<Widget> _getSkillsByCategory(BuildContext context, String category) {
    if (category == 'Tout') {
      // Afficher toutes les compétences
      return [
        // Général
        _buildSkillCard(context, "Test d'anglais", "Passez un test EF SET et obtenez un certificat reconnu internationalement.", FontAwesomeIcons.language, "https://www.efset.org/english-certificate/"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Test de QI", "Évaluez votre intelligence avec le test BMI Certified IQ.", FontAwesomeIcons.brain, "https://www.test-iq.org/take-the-iq-test-now/"),
        const SizedBox(height: 10),
        // Programmation
        _buildSkillCard(context, "Apprendre le développement web", "Créez votre site web avec HTML5 & CSS3", FontAwesomeIcons.html5, "https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Programmation Python", "Apprendre les bases du langage Python", FontAwesomeIcons.python, "https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Développement mobile avec Flutter", "Suivez une formation complète sur Flutter pour créer des apps Android/iOS.", FontAwesomeIcons.flutter, "https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Maîtriser Git & Github", "Gérez du code avec Git et Github", FontAwesomeIcons.git, "https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Linux", "Initiez-vous à Linux", FontAwesomeIcons.linux, "https://openclassrooms.com/fr/courses/7170491-initiez-vous-a-linux"),
        const SizedBox(height: 10),
        // Génie Civil
        _buildSkillCard(context, "Génie Civil - Introduction", "Découvrez les bases du génie civil et des structures", FontAwesomeIcons.hammer, "https://www.edx.org/learn/civil-engineering"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Mécanique - Fondamentaux", "Apprenez les principes de la mécanique appliquée", FontAwesomeIcons.gears, "https://www.coursera.org/learn/mechanical-engineering"),
      ];
    } else if (category == 'Général') {
      return [
        _buildSkillCard(context, "Test d'anglais", "Passez un test EF SET et obtenez un certificat reconnu internationalement.", FontAwesomeIcons.language, "https://www.efset.org/english-certificate/"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Test de QI", "Évaluez votre intelligence avec le test BMI Certified IQ.", FontAwesomeIcons.brain, "https://www.test-iq.org/take-the-iq-test-now/"),
      ];
    } else if (category == 'Programmation') {
      return [
        _buildSkillCard(context, "Apprendre le développement web", "Créez votre site web avec HTML5 & CSS3", FontAwesomeIcons.html5, "https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Apprendre à programmer avec JavaScript", "Maîtriser les bases et la logique de la programmation JavaScript", FontAwesomeIcons.js, "https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Programmation Python", "Apprendre les bases du langage Python", FontAwesomeIcons.python, "https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Programmation C", "Apprendre les bases du langage C", FontAwesomeIcons.c, "https://openclassrooms.com/fr/courses/19980-apprenez-a-programmer-en-c"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Développement mobile avec Flutter", "Suivez une formation complète sur Flutter pour créer des apps Android/iOS.", FontAwesomeIcons.flutter, "https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Maîtriser Git & Github", "Gérez du code avec Git et Github", FontAwesomeIcons.git, "https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Linux", "Initiez-vous à Linux", FontAwesomeIcons.linux, "https://openclassrooms.com/fr/courses/7170491-initiez-vous-a-linux"),
      ];
    } else if (category == 'Génie Civil') {
      return [
        _buildSkillCard(context, "Génie Civil - Introduction", "Découvrez les bases du génie civil et des structures", FontAwesomeIcons.hammer, "https://www.edx.org/learn/civil-engineering"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Mécanique - Fondamentaux", "Apprenez les principes de la mécanique appliquée", FontAwesomeIcons.gears, "https://www.coursera.org/learn/mechanical-engineering"),
      ];
    } else if (category == 'Langues') {
      return [
        _buildSkillCard(context, "Anglais Technique", "TOEIC/TOEFL", FontAwesomeIcons.language, "https://ets.org"),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Test d'anglais EF SET", "Certificat reconnu internationalement", FontAwesomeIcons.language, "https://www.efset.org/english-certificate/"),
      ];
    }
    return [
       _buildSkillCard(context, "Gestion de Projet", "Agile & Scrum", FontAwesomeIcons.listCheck, "https://scrum.org"),
       const SizedBox(height: 10),
       _buildSkillCard(context, "Test d'anglais", "TOEIC/TOEFL", FontAwesomeIcons.language, "https://ets.org"),
    ];
  }

  Widget _buildSkillCard(BuildContext context, String title, String subtitle, IconData icon, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).hintColor),
        onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
  
  Widget _buildLearningPlatformCard(BuildContext context, {required String title, required String description, required IconData icon, required String url}) {
    return _buildSkillCard(context, title, description, icon, url);
  }
}

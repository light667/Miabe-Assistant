import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miabeassistant/pages/chat_page.dart';
import 'package:miabeassistant/pages/resources_page.dart';
import 'package:miabeassistant/pages/campus_page.dart';
import 'package:miabeassistant/pages/competences_page.dart';
import 'package:miabeassistant/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
        return const CompetencesPage();
      case 5:
        return const SettingsPage(title: 'Paramètres');
      default:
        return HomeContent(pseudo: _pseudo);
    }
  }

  void onItemTapped(int index) {
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
              onDestinationSelected: onItemTapped,
              indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
              destinations: const [
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.house, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.house, size: 20, color: AppTheme.primary), label: 'Accueil'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.robot, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.robot, size: 20, color: AppTheme.primary), label: 'Assistant'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.bookOpen, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.bookOpen, size: 20, color: AppTheme.primary), label: 'Cours'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.users, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.users, size: 20, color: AppTheme.primary), label: 'Campus'),
                NavigationDestination(icon: FaIcon(FontAwesomeIcons.lightbulb, size: 20), selectedIcon: FaIcon(FontAwesomeIcons.lightbulb, size: 20, color: AppTheme.primary), label: 'Skills'),
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
                                'Hi, ${widget.pseudo}',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                               ).animate().fadeIn().moveX(begin: -10, end: 0),
                               const SizedBox(height: 8),
                               Text(
                                'Miabé ASSISTANT - Votre compagnon pour réussir en Sciences et Technologies',
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
              icon: const FaIcon(FontAwesomeIcons.circleUser, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage(title: 'Paramètres')),
                );
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
        
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double horizontalPadding = 24.0;
              const double maxContentWidth = 920.0;
              final double availableWidth = constraints.maxWidth;
              final double contentWidth = availableWidth <= (maxContentWidth + horizontalPadding * 2)
                  ? availableWidth - horizontalPadding * 2
                  : maxContentWidth;

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                 // Quick Actions - Main Features
                 Text('Fonctionnalités Principales', style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 16),
                 
                 _buildFeatureCard(
                   context,
                   'Assistant IA',
                   'Posez vos questions et obtenez des réponses instantanées pour vous aider dans votre parcours académique',
                   FontAwesomeIcons.robot,
                   AppTheme.primary,
                   1,
                 ),
                 const SizedBox(height: 12),
                 
                 _buildFeatureCard(
                   context,
                   'Ressources Pédagogiques',
                   'Accédez à tous vos cours, TD et TP organisés par filière et semestre',
                   FontAwesomeIcons.bookOpen,
                   const Color(0xFF10B981),
                   2,
                 ),
                 const SizedBox(height: 12),
                 
                 _buildFeatureCard(
                   context,
                   'Campus Collaboratif',
                   'Échangez avec vos camarades, partagez des fiches et collaborez',
                   FontAwesomeIcons.users,
                   const Color(0xFF8B5CF6),
                   3,
                 ),
                 const SizedBox(height: 12),
                 
                 _buildFeatureCard(
                   context,
                   'Développement de Compétences',
                   'Découvrez des formations et plateformes pour renforcer vos compétences',
                   FontAwesomeIcons.lightbulb,
                   AppTheme.secondary,
                   4,
                 ),
                 
                 const SizedBox(height: 32),
                 
                 // Call to Action
                 Center(
                   child: Column(
                     children: [
                       Container(
                         width: double.infinity,
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: AppTheme.primary.withValues(alpha: 0.05),
                           borderRadius: BorderRadius.circular(24),
                           border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5),
                           boxShadow: [
                             BoxShadow(
                               color: AppTheme.primary.withValues(alpha: 0.1),
                               blurRadius: 20,
                               offset: const Offset(0, 10),
                             ),
                           ],
                         ),
                         child: Column(
                           children: [
                             const Icon(Icons.rocket_launch_rounded, size: 48, color: AppTheme.primary),
                             const SizedBox(height: 16),
                             Text(
                               'Prêt à exceller ?',
                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: AppTheme.primary,
                               ),
                               textAlign: TextAlign.center,
                             ),
                             const SizedBox(height: 12),
                             Text(
                               'Explorez toutes les fonctionnalités et atteignez vos objectifs académiques',
                               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                 color: Theme.of(context).hintColor,
                               ),
                               textAlign: TextAlign.center,
                             ),
                           ],
                         ),
                       ).animate().fadeIn(delay: 500.ms).scale(),
                       
                       const SizedBox(height: 24),
                       
                       Text(
                         'Naviguez entre les onglets pour découvrir toutes les fonctionnalités',
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                           fontStyle: FontStyle.italic,
                         ),
                         textAlign: TextAlign.center,
                       ).animate().fadeIn(duration: 2400.ms).slideY(),
                     ],
                   ),
                 ),
                 
                 // Bottom spacing for nav bar
                 const SizedBox(height: 100),
              ],
            ),
          ),
        )
              );
              
      },
    ),
        ),
      ],
    );
  }


  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    int targetIndex,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to the corresponding tab
        final homePageState = context.findAncestorStateOfType<HomePageState>();
        homePageState?.onItemTapped(targetIndex);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

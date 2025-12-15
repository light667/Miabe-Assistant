import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miabeassistant/pages/chat_page.dart';
import 'package:miabeassistant/pages/resources_page.dart';
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

  final List<Widget> _pages = const <Widget>[
    HomeContent(),
    ChatPage(title: 'Chat'),
    ResourcesPage(),
    SettingsPage(title: 'Paramètres'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pseudo = prefs.getString('pseudo');
      final filiere = prefs.getString('filiere');
      final semestre = prefs.getString('semestre');

      debugPrint(
        'SharedPreferences - pseudo: $pseudo, filiere: $filiere, semestre: $semestre',
      );

      if (mounted) {
        setState(() {
          _pseudo = pseudo ?? 'Utilisateur';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du chargement des données utilisateur : $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erreur dans _loadUserData: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Science de l\'Ingénieur - Miabe',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Department switcher button
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'Changer de département',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/department_selection');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF121212), const Color(0xFF1E3A8A)]
                : [const Color(0xFFF3F4F6), const Color(0xFFBBDEFB)],
          ),
        ),
        child: _pages[_selectedIndex].animate().fadeIn(duration: 400.ms),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Accueil',
            tooltip: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message),
            label: 'ChatBot',
            tooltip: 'ChatBot',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.book),
            label: 'Ressources',
            tooltip: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: 'Paramètres',
            tooltip: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        elevation: 8,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Voir le profil',
        child: const FaIcon(FontAwesomeIcons.user, color: Colors.black),
      ).animate().scale(delay: 1000.ms, duration: 300.ms),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    final pseudo = state?._pseudo ?? 'Utilisateur';

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bienvenue, cher $pseudo !',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideY(),
                  ),                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Votre assistant pour réussir vos études à l\'Ecole Polytechnique de Lomé',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 1000.ms).slideY(),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ressources suggérées',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().fadeIn(duration: 1200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez des cours adaptés à votre filiere et semestre.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 1400.ms),
                      const SizedBox(height: 16),
                      Animate(
                        effects: [
                          FadeEffect(duration: 1600.ms),
                          ScaleEffect(),
                        ],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickActionButton(
                              context,
                              icon: FontAwesomeIcons.book,
                              label: 'Cours',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/resources'),
                            ),
                            _buildQuickActionButton(
                              context,
                              icon: FontAwesomeIcons.message,
                              label: 'Chat',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/chat'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Développez vos compétences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().fadeIn(duration: 1800.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Explorez des opportunités pour améliorer vos compétences académiques et professionnelles.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 2000.ms),
                      const SizedBox(height: 16),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.language,
                        title: 'Test d\'anglais',
                        description:
                            'Passez un test EF SET et obtenez un certificat reconnu internationalement.',
                        url: 'https://www.efset.org/english-certificate/',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.brain,
                        title: 'Test de QI',
                        description:
                            'Évaluez votre intelligence avec le test BMI Certified IQ.',
                        url: 'https://www.test-iq.org/take-the-iq-test-now/',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.html5,
                        title: 'Apprendre le développement web',
                        description: 'Créez votre site web avec HTML5 & CSS3',
                        url:
                            'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.js,
                        title: 'Apprendre a programmer avec JavaScript',
                        description:
                            'Maitriser les bases et la logique de la programmation JavaScript',
                        url:
                            'https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.git,
                        title: 'Maitriser Git & Github',
                        description: 'Gérez du code avec Git et Github',
                        url:
                            'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3',
                      ),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.flutter,
                        title: 'Apprendre le développement mobile avec Flutter',
                        description:
                            'Suivez une formation complète sur Flutter pour créer des apps Android/iOS.',
                        url:
                            'https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.python,
                        title: 'Formation Python + Certificat: Anglais',
                        description: 'Python for beginners',
                        url:
                            'https://www.simplilearn.com/learn-python-basics-free-course-skillup?tag=python',
                      ),
                      const SizedBox(height: 16),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.python,
                        title: 'Programation Python : Français',
                        description: 'Apprendre les bases du langage Python',
                        url:
                            'https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python',
                      ),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.c,
                        title: 'Programation C ',
                        description: 'Apprendre les bases du langage C',
                        url:
                            'https://openclassrooms.com/fr/courses/19980-apprenez-a-programmer-en-c',
                      ),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.linux,
                        title: 'Linux',
                        description: 'Initiez-vous à Linux',
                        url:
                            'https://openclassrooms.com/fr/courses/7170491-initiez-vous-a-linux',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 2200.ms).slideY(),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plateformes d\'apprentissage en ligne',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().fadeIn(duration: 2400.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez les meilleures plateformes pour renforcer vos compétences techniques.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 2600.ms),
                      const SizedBox(height: 16),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.chartLine,
                        title: 'DataCamp',
                        description:
                            'Apprenez la science des données et l\'analyse avec Python, R et SQL.',
                        url: 'https://www.datacamp.com/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.graduationCap,
                        title: 'Moodle',
                        description:
                            'Plateforme d\'apprentissage open source utilisée par les universités.',
                        url: 'https://moodle.org/?lang=fr',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.mobile,
                        title: 'SoloLearn',
                        description:
                            'Apprenez à coder sur mobile avec des cours interactifs.',
                        url: 'https://www.sololearn.com/en/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.buildingColumns,
                        title: 'Coursera',
                        description:
                            'Cours en ligne des meilleures universités mondiales.',
                        url: 'https://www.coursera.org/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.code,
                        title: 'freeCodeCamp',
                        description:
                            'Apprenez le développement web gratuitement avec des projets pratiques.',
                        url: 'https://www.freecodecamp.org/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.laptopCode,
                        title: 'HackerRank',
                        description:
                            'Améliorez vos compétences en programmation grâce à des défis codés.',
                        url: 'https://www.hackerrank.com/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.desktop,
                        title: 'OpenClassrooms',
                        description:
                            'Formations en ligne avec mentorat pour obtenir des diplômes reconnus.',
                        url: 'https://openclassrooms.com/fr/',
                      ),
                      const SizedBox(height: 12),
                      _buildLearningPlatformCard(
                        context,
                        icon: FontAwesomeIcons.rocket,
                        title: 'Simplilearn',
                        description:
                            'Formations certifiantes en digital skills et technologies émergentes.',
                        url: 'https://www.simplilearn.com/',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 2800.ms).slideY(),
              Center(
                child: Text(
                  'Explorez et réussissez avec Miabe Assistant !',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(duration: 2400.ms).slideY(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.2),
      highlightColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeInOut);
  }

  Widget _buildSkillCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ouverture de : $title'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Impossible d\'ouvrir le lien : $url'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'ouverture du lien : $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.2),
      highlightColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(curve: Curves.easeInOut);
  }

  Widget _buildLearningPlatformCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ouverture de : $title'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Impossible d\'ouvrir le lien : $url'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'ouverture du lien : $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(
        context,
      ).colorScheme.secondary.withAlpha((0.2 * 255).round()),
      highlightColor: Theme.of(
        context,
      ).colorScheme.primary.withAlpha((0.1 * 255).round()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primary.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withAlpha((0.2 * 255).round()),
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(curve: Curves.easeInOut);
  }
}

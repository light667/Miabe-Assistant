import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CompetencesPage extends StatefulWidget {
  const CompetencesPage({super.key});

  @override
  State<CompetencesPage> createState() => _CompetencesPageState();
}

class _CompetencesPageState extends State<CompetencesPage> {
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

    return Scaffold(
      body: CustomScrollView(
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
                              backgroundColor: AppTheme.secondary.withValues(alpha: 0.05),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.lightbulb,
                                        color: AppTheme.secondary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Compétences',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ).animate().fadeIn().moveX(begin: -10, end: 0),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Développez vos compétences techniques',
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
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Compétences Recommandées', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(icon: const Icon(Icons.tune, size: 20), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorez et développez vos compétences dans différents domaines',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('Tout'),
                        _buildCategoryChip('Général'),
                        _buildCategoryChip('Programmation'),
                        _buildCategoryChip('Génie Mécanique'),
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
                    'Découvrez les meilleures plateformes pour renforcer vos compétences techniques.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16),
                  _buildLearningPlatformCard(context, title: 'DataCamp', description: "Apprenez la science des données et l'analyse avec Python, R et SQL.", icon: FontAwesomeIcons.chartLine, url: 'https://www.datacamp.com/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'Moodle', description: "Plateforme d'apprentissage open source utilisée par les universités.", icon: FontAwesomeIcons.graduationCap, url: 'https://moodle.org/?lang=fr'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'SoloLearn', description: 'Apprenez à coder sur mobile avec des cours interactifs.', icon: FontAwesomeIcons.mobile, url: 'https://www.sololearn.com/en/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'Coursera', description: 'Cours en ligne des meilleures universités mondiales.', icon: FontAwesomeIcons.buildingColumns, url: 'https://www.coursera.org/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'freeCodeCamp', description: 'Apprenez le développement web gratuitement avec des projets pratiques.', icon: FontAwesomeIcons.code, url: 'https://www.freecodecamp.org/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'HackerRank', description: 'Améliorez vos compétences en programmation grâce à des défis codés.', icon: FontAwesomeIcons.laptopCode, url: 'https://www.hackerrank.com/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'OpenClassrooms', description: 'Formations en ligne avec mentorat pour obtenir des diplômes reconnus.', icon: FontAwesomeIcons.desktop, url: 'https://openclassrooms.com/fr/'),
                  const SizedBox(height: 12),
                  _buildLearningPlatformCard(context, title: 'Simplilearn', description: 'Formations certifiantes en digital skills et technologies émergentes.', icon: FontAwesomeIcons.rocket, url: 'https://www.simplilearn.com/'),
                  
                  const SizedBox(height: 24),
                  
                  Center(
                    child: Text(
                      '💡 Continuez à apprendre et progresser !',
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
        selectedColor: AppTheme.secondary.withValues(alpha: 0.1),
        checkmarkColor: AppTheme.secondary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.secondary : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
           side: BorderSide(color: isSelected ? AppTheme.secondary : Theme.of(context).dividerColor),
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
        _buildSkillCard(context, "Test d'anglais", 'Passez un test EF SET et obtenez un certificat reconnu internationalement.', FontAwesomeIcons.language, 'https://www.efset.org/english-certificate/'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Test de QI', 'Évaluez votre intelligence avec le test BMI Certified IQ.', FontAwesomeIcons.brain, 'https://www.test-iq.org/take-the-iq-test-now/'),
        const SizedBox(height: 10),
        // Programmation
        _buildSkillCard(context, 'Apprendre le développement web', 'Créez votre site web avec HTML5 & CSS3', FontAwesomeIcons.html5, 'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Programmation Python', 'Apprendre les bases du langage Python', FontAwesomeIcons.python, 'https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Développement mobile avec Flutter', 'Suivez une formation complète sur Flutter pour créer des apps Android/iOS.', FontAwesomeIcons.flutter, 'https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Machine Learning Pour Débutant', 'Formation complète pour débuter en Machine Learning', FontAwesomeIcons.robot, 'https://youtu.be/82KLS2C_gNQ?si=rU0b1FEmGeFJ7XCb'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Maîtriser Git & Github', 'Gérez du code avec Git et Github', FontAwesomeIcons.github, 'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Linux', 'Initiez-vous à Linux', FontAwesomeIcons.linux, 'https://openclassrooms.com/fr/courses/7170491-initiez-vous-a-linux'),
        const SizedBox(height: 10),
        // Génie Mécanique
        _buildSkillCard(context, 'Apprendre à utiliser FreeCAD', 'Maîtrisez la modélisation 3D open-source.', FontAwesomeIcons.cube, 'https://gtnyqqstqfwvncnymptm.supabase.co/storage/v1/object/public/resources/competences/FREECAD_Cours.pdf'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Simulations Mécaniques', 'Expérimentez avec des simulations interactives Phet.', FontAwesomeIcons.gears, 'https://phet.colorado.edu/fr/simulations/filter?subjects=physics&type=html,prototype'),
      ];
    } else if (category == 'Général') {
      return [
        _buildSkillCard(context, "Test d'anglais", 'Passez un test EF SET et obtenez un certificat reconnu internationalement.', FontAwesomeIcons.language, 'https://www.efset.org/english-certificate/'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Test de QI', 'Évaluez votre intelligence avec le test BMI Certified IQ.', FontAwesomeIcons.brain, 'https://www.test-iq.org/take-the-iq-test-now/'),
      ];
    } else if (category == 'Programmation') {
      return [
        _buildSkillCard(context, 'Apprendre le développement web', 'Créez votre site web avec HTML5 & CSS3', FontAwesomeIcons.html5, 'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Apprendre à programmer avec JavaScript', 'Maîtriser les bases et la logique de la programmation JavaScript', FontAwesomeIcons.js, 'https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Programmation Python', 'Apprendre les bases du langage Python', FontAwesomeIcons.python, 'https://openclassrooms.com/fr/courses/7168871-apprenez-les-bases-du-langage-python'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Programmation C', 'Apprendre les bases du langage C', FontAwesomeIcons.c, 'https://openclassrooms.com/fr/courses/19980-apprenez-a-programmer-en-c'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Développement mobile avec Flutter', 'Suivez une formation complète sur Flutter pour créer des apps Android/iOS.', FontAwesomeIcons.flutter, 'https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Machine Learning Pour Débutant', 'Formation complète pour débuter en Machine Learning', FontAwesomeIcons.robot, 'https://youtu.be/82KLS2C_gNQ?si=rU0b1FEmGeFJ7XCb'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Maîtriser Git & Github', 'Gérez du code avec Git et Github', FontAwesomeIcons.github, 'https://openclassrooms.com/fr/courses/1603881-creez-votre-site-web-avec-html5-et-css3'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Linux', 'Initiez-vous à Linux', FontAwesomeIcons.linux, 'https://openclassrooms.com/fr/courses/7170491-initiez-vous-a-linux'),
      ];
    } else if (category == 'Génie Mécanique') {
      return [
        _buildSkillCard(context, 'Apprendre à utiliser FreeCAD', 'Maîtrisez la modélisation 3D open-source.', FontAwesomeIcons.cube, 'https://gtnyqqstqfwvncnymptm.supabase.co/storage/v1/object/public/resources/competences/FREECAD_Cours.pdf'),
        const SizedBox(height: 10),
        _buildSkillCard(context, 'Simulations Mécaniques', 'Expérimentez avec des simulations interactives Phet.', FontAwesomeIcons.gears, 'https://phet.colorado.edu/fr/simulations/filter?subjects=physics&type=html,prototype'),
      ];
    } else if (category == 'Langues') {
      return [
        _buildSkillCard(context, 'Anglais Technique', 'TOEIC/TOEFL', FontAwesomeIcons.language, 'https://ets.org'),
        const SizedBox(height: 10),
        _buildSkillCard(context, "Test d'anglais EF SET", 'Certificat reconnu internationalement', FontAwesomeIcons.language, 'https://www.efset.org/english-certificate/'),
      ];
    }
    return [
       _buildSkillCard(context, 'Gestion de Projet', 'Agile & Scrum', FontAwesomeIcons.listCheck, 'https://scrum.org'),
       const SizedBox(height: 10),
       _buildSkillCard(context, "Test d'anglais", 'TOEIC/TOEFL', FontAwesomeIcons.language, 'https://ets.org'),
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
          child: FaIcon(icon, color: AppTheme.secondary, size: 20),
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

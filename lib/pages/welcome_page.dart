import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer.withValues(alpha: 0.9),
              colorScheme.primaryContainer.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal animé
                Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cercle de fond animé
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ).animate().scale(
                        delay: 200.ms,
                        duration: 1000.ms,
                        curve: Curves.elasticOut,
                      ),

                      // Icône du chapeau de diplôme
                      Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.secondary,
                                  colorScheme.secondary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              FontAwesomeIcons.graduationCap,
                              size: 70,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .scale(
                            delay: 300.ms,
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .rotate(
                            begin: -0.05,
                            end: 0.05,
                            delay: 1200.ms,
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),

                // Titre principal
                 Text(
                      'Miabe Assistant',
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 42,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                // Sous-titre
                 Text(
                      'Votre compagnon de réussite académique pour tous les étudiants du Togo',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: 60),

                // Bouton Commencer (connexion)
                ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                            arguments: {'forLogin': true},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          minimumSize: const Size.fromHeight(70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: colorScheme.secondary.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Commencer maintenant',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 800.ms)
                    .scale(curve: Curves.easeOutBack),

                const SizedBox(height: 20),

                // Bouton Créer un compte (inscription)
                ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                            arguments: {'forLogin': false},
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(70),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Créer un compte',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 800.ms)
                    .scale(curve: Curves.easeOutBack),

                const SizedBox(height: 50),

                // Section fonctionnalités
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Titre section
                      Text(
                        'Tout ce dont vous avez besoin',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Fonctionnalités
                      _buildFeatureItem(
                        context,
                        Icons.school_rounded,
                        'Cours complets',
                        'Accédez à tous vos cours et supports pédagogiques',
                        delay: 800.ms,
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureItem(
                        context,
                        Icons.assignment_rounded,
                        'Exercices pratiques',
                        'Entraînez-vous avec des exercices corrigés',
                        delay: 900.ms,
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureItem(
                        context,
                        Icons.analytics_rounded,
                        'Suivi de progression',
                        'Visualisez votre évolution et vos résultats',
                        delay: 1000.ms,
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureItem(
                        context,
                        Icons.group_rounded,
                        'Communauté étudiante',
                        'Échangez avec vos camarades de promotion',
                        delay: 1100.ms,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Footer
                Text(
                  'Rejoignez des milliers d\'étudiants et boostez votre réussite !',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description, {
    Duration delay = Duration.zero,
  }) {
    return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .slideX(begin: 0.2, curve: Curves.easeOutCubic);
  }
}

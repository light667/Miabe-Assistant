import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Bienvenue sur\nMiabé ASSISTANT',
      'subtitle': "La plateforme d'excellence pour\nles futurs ingénieurs.",
    },
    {
      'title': 'Ressources\nIllimitées',
      'subtitle': 'Accédez à des milliers de cours,\nTDs et examens corrigés.',
    },
    {
      'title': 'Communauté\nActive',
      'subtitle': 'Échangez avec les meilleurs\net boostez vos résultats.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Determine gradient based on theme mode? Let's keep it clean slate for now.
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Decor (Subtle blobs)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
                backgroundBlendMode: BlendMode.srcOver,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(duration: 5.seconds, begin: 0, end: 50),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                
                // Logo & Branding Area
                const MiabeLogo(size: 100, isAnimated: true)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(curve: Curves.elasticOut, duration: 800.ms),
                
                const SizedBox(height: 40),

                // PageView Content
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _currentPage = value),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) => _buildPageContent(
                      title: _onboardingData[index]['title']!,
                      subtitle: _onboardingData[index]['subtitle']!,
                      index: index,
                    ),
                  ),
                ),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primary
                            : (isDark ? Colors.grey[700] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.pushNamed(
                                context,
                                '/login',
                                arguments: {'forLogin': false}, // Go to Signup
                              );
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 8,
                            shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                          ),
                          child: const Text('Créer un compte'),
                        ),
                      ).animate()
                       .fadeIn(delay: 500.ms)
                       .moveY(begin: 20, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                            arguments: {'forLogin': true},
                          );
                        },
                        child: Text(
                          "J'ai déjà un compte",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isDark ? Colors.white70 : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ).animate()
                       .fadeIn(delay: 700.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({required String title, required String subtitle, required int index}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              height: 1.1,
            ),
          ).animate(target: _currentPage == index ? 1 : 0)
           .fadeIn(duration: 500.ms)
           .moveY(begin: 20, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ).animate(target: _currentPage == index ? 1 : 0)
           .fadeIn(delay: 200.ms, duration: 500.ms)
           .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}

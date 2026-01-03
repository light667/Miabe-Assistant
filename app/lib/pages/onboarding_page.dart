import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      icon: Icons.school_rounded,
      title: 'Cours complets',
      description: 'Accédez à tous vos cours et supports pédagogiques',
      gradient: [Color(0xFF5B8DEF), Color(0xFF4A7AC9)],
    ),
    const OnboardingSlide(
      icon: Icons.assignment_rounded,
      title: 'Exercices pratiques',
      description: 'Entraînez-vous avec des exercices corrigés',
      gradient: [Color(0xFF4A7AC9), Color(0xFF6B9FF7)],
    ),
    const OnboardingSlide(
      icon: Icons.analytics_rounded,
      title: 'Suivi de progression',
      description: 'Visualisez votre évolution et vos résultats',
      gradient: [Color(0xFF6B9FF7), Color(0xFF89B4FA)],
    ),
    const OnboardingSlide(
      icon: Icons.group_rounded,
      title: 'Communauté étudiante',
      description: 'Échangez avec vos camarades de promotion',
      gradient: [Color(0xFF89B4FA), Color(0xFFA8C7FB)],
    ),
    const OnboardingSlide(
      icon: Icons.rocket_launch_rounded,
      title: 'Prêt à décoller ?',
      description: 'Rejoignez des milliers d\'étudiants et boostez votre réussite !',
      gradient: [Color(0xFF5B8DEF), Color(0xFFFBBF24)],
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() async {
    await _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() async {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index], index);
            },
          ),

          // Skip button (not shown on last page)
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (index) => _buildDot(index),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navigation button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _currentPage == _slides.length - 1
                            ? _finishOnboarding
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0444F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'Commencer'
                              : 'Suivant',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: slide.gradient,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Subtle background circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Icon with elegant design
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          slide.icon,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    )
                        .animate(key: ValueKey(index))
                        .scale(
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 500.ms),
                  ),

                  const SizedBox(height: 60),

                  // Title
                  Center(
                    child: Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate(key: ValueKey('title_$index'))
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOut),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        slide.description,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate(key: ValueKey('desc_$index'))
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOut),
                  ),

                  const Spacer(),
                  const SizedBox(height: 120), // Space for bottom navigation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final bool isLast;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    this.isLast = false,
  });
}

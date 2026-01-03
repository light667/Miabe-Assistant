import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2.5 seconds (slightly faster)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      // Navigate to initial route
      Navigator.pushReplacementNamed(context, '/initial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo with Animation
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const MiabeLogo(
                  size: 150, 
                  isAnimated: true,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 48),

              // App Name
              Text(
                'Miabé ASSISTANT',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondary,
                      letterSpacing: 1.0,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutCubic),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'L\'excellence à portée de main',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),

              const Spacer(flex: 2),

              // Loader
               const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

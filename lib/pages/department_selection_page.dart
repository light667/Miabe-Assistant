import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:miabeassistant/providers/department_provider.dart';

class DepartmentSelectionPage extends StatelessWidget {
  const DepartmentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0444F4).withValues(alpha: 0.1),
              const Color(0xFFF3F4F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/miabe_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Choisissez votre département',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0444F4),
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Sélectionnez votre domaine d\'études',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms),
                  ],
                ),
              ),

              // Department Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildDepartmentCard(
                        context,
                        department: Department.engineering,
                        icon: FontAwesomeIcons.laptop,
                        name: 'Science de\nl\'Ingénieur',
                        color: const Color(0xFF0444F4),
                        isAvailable: true,
                        delay: 600.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.law,
                        icon: FontAwesomeIcons.scaleBalanced,
                        name: 'Droit',
                        color: const Color(0xFF8B0000),
                        isAvailable: false,
                        delay: 700.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.health,
                        icon: FontAwesomeIcons.heartPulse,
                        name: 'Santé',
                        color: const Color(0xFFDC143C),
                        isAvailable: false,
                        delay: 800.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.language,
                        icon: FontAwesomeIcons.language,
                        name: 'Langue',
                        color: const Color(0xFF10B981),
                        isAvailable: false,
                        delay: 900.ms,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'D\'autres départements seront bientôt disponibles',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(
    BuildContext context, {
    required Department department,
    required IconData icon,
    required String name,
    required Color color,
    required bool isAvailable,
    Duration delay = Duration.zero,
  }) {
    return InkWell(
      onTap: () => _handleDepartmentSelection(context, department, isAvailable),
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Department Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // "Bientôt disponible" overlay
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bientôt\ndisponible',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .scale(delay: delay, curve: Curves.easeOutBack);
  }

  void _handleDepartmentSelection(
    BuildContext context,
    Department department,
    bool isAvailable,
  ) async {
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ce département sera bientôt disponible !',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFBBF24),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Save department selection
    final departmentProvider = Provider.of<DepartmentProvider>(
      context,
      listen: false,
    );
    await departmentProvider.setDepartment(department);

    // Navigate to appropriate page based on department
    if (context.mounted) {
      switch (department) {
        case Department.engineering:
          // Navigate to the existing PolyAssistant home page
          Navigator.pushReplacementNamed(context, '/home');
          break;
        default:
          // Show coming soon message for other departments
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ce département sera bientôt disponible !'),
            ),
          );
      }
    }
  }
}

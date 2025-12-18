import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:miabeassistant/providers/department_provider.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';

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
                    const MiabeLogo(size: 80)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesTechnologie,
                        name: 'Sciences et\nTechnologie',
                        isAvailable: true,
                        delay: 500.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.lettresLangueArts,
                        name: 'Lettres, Langue\net Arts',
                        isAvailable: true,
                        delay: 600.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesAgronomiques,
                        name: 'Sciences\nAgronomiques',
                        isAvailable: true,
                        delay: 700.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesEducationFormation,
                        name: 'Sciences de\nl\'Education',
                        isAvailable: true,
                        delay: 800.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesEconomiqueGestion,
                        name: 'Sciences Eco.\net de Gestion',
                        isAvailable: true,
                        delay: 900.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesHommeSociete,
                        name: 'Sciences de\nl\'Homme',
                        isAvailable: true,
                        delay: 1000.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesJuridiquePolitique,
                        name: 'Sciences\nJuridiques',
                        isAvailable: true,
                        delay: 1100.ms,
                      ),
                      _buildDepartmentCard(
                        context,
                        department: Department.sciencesSante,
                        name: 'Sciences de\nla Santé',
                        isAvailable: true,
                        delay: 1200.ms,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Choisissez votre domaine d\'études',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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
    required String name,
    required bool isAvailable,
    Duration delay = Duration.zero,
  }) {
    final departmentProvider = Provider.of<DepartmentProvider>(context, listen: false);
    final color = departmentProvider.getDepartmentColor(department);
    final icon = departmentProvider.getDepartmentIcon(department);
    
    return Animate(
      effects: [
        FadeEffect(delay: delay, duration: 600.ms),
        ScaleEffect(delay: delay, curve: Curves.easeOutBack),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleDepartmentSelection(context, department, isAvailable),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.85),
                  color.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                
                // Main content - centered
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon with background
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Department Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                  // "Bientôt disponible" overlay
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 36,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Bientôt\ndisponible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
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
            ),
          ),
        ),
      );
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
        case Department.sciencesTechnologie:
          // Navigate to the existing Miabe Assistant home page
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

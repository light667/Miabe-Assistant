import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:miabeassistant/services/resources_service.dart';
import 'package:miabeassistant/constants/app_theme.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  late List<dynamic> filieres = [];
  Map<String, dynamic>? selectedFiliere;
  Map<String, dynamic>? selectedSemestre;
  Map<String, dynamic>? selectedMatiere;
  
  final ResourcesService _resourcesService = ResourcesService();
  bool _isLoadingFromSupabase = false;

  // Mapping des noms techniques vers noms affichables
  String _getFiliereDisplayName(String technicalName) {
    const Map<String, String> displayNames = {
      'lf_genie_civil': 'Licence Fondamentale - Génie Civil',
      'lf_genie_electrique': 'Licence Fondamentale - Génie Électrique',
      'lf_genie_mecanique': 'Licence Fondamentale - Génie Mécanique',
      'lf_iabigdata': 'Licence Fondamentale - Intelligence Artificielle & Big Data',
      'lf_informatiquesysteme': 'Licence Fondamentale - Informatique et Système',
      'lf_logistiquetransport': 'Licence Fondamentale - Logistique et Transport',
      'lpro_genie_logiciel': 'Licence Professionnelle - Génie Logiciel',
    };
    return displayNames[technicalName] ?? technicalName.replaceAll('lf_', '').replaceAll('lpro_', '').replaceAll('_', ' ');
  }

  @override
  void initState() {
    super.initState();
    _loadManifest();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadManifest() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingFromSupabase = true;
    });
    
    try {
      final String response = await rootBundle.loadString(
        'assets/resources_manifest_online.json',
      );
      final data = json.decode(response);
      
      if (mounted) {
        setState(() {
          filieres = data["filieres"];
          _isLoadingFromSupabase = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement local: $e');
      if (mounted) {
        setState(() {
          _isLoadingFromSupabase = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des ressources')),
        );
      }
    }
  }

  Future<void> _openPdf(String url) async {
    if (!mounted) return;
    final Uri pdfUri = Uri.parse(url);
    if (!await launchUrl(
      pdfUri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: "_blank",
    )) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le PDF")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ressources Pédagogiques",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: filieres.isEmpty
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
          child: child,
        ));
      },
      child: KeyedSubtree(
        key: ValueKey(selectedFiliere?.toString() ?? 'root' + (selectedSemestre?.toString() ?? '') + (selectedMatiere?.toString() ?? '')),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (selectedFiliere == null) {
      return _buildFiliereSelection();
    } else if (selectedSemestre == null) {
      return _buildSemestreSelection();
    } else if (selectedMatiere == null) {
      return _buildMatiereSelection();
    } else {
      return _buildPdfSelection();
    }
  }

  Widget _buildFiliereSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filieres.length,
      itemBuilder: (context, index) {
        final filiere = filieres[index];
        return _buildCard(
          title: _getFiliereDisplayName(filiere["name"]),
          subtitle: "${filiere["semestres"].length} semestres",
          icon: Icons.school_outlined,
          onTap: () {
            setState(() {
              selectedFiliere = filiere;
              selectedSemestre = null;
              selectedMatiere = null;
            });
          },
          delay: index * 50,
        );
      },
    );
  }

  Widget _buildSemestreSelection() {
    return Column(
      children: [
        _buildHeader("Choisissez un semestre", () => setState(() => selectedFiliere = null)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedFiliere!["semestres"].length,
            itemBuilder: (context, index) {
              final semestre = selectedFiliere!["semestres"][index];
              return _buildCard(
                title: semestre["name"],
                icon: Icons.calendar_today_outlined,
                onTap: () {
                  setState(() {
                    selectedSemestre = semestre;
                    selectedMatiere = null;
                  });
                },
                delay: index * 50,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatiereSelection() {
    return Column(
      children: [
        _buildHeader("Choisissez une matière", () => setState(() => selectedSemestre = null)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedSemestre!["matieres"].length,
            itemBuilder: (context, index) {
              final matiere = selectedSemestre!["matieres"][index];
              return _buildCard(
                title: matiere["name"].toUpperCase(),
                icon: Icons.book_outlined,
                onTap: () {
                  setState(() {
                    selectedMatiere = matiere;
                  });
                },
                delay: index * 50,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPdfSelection() {
    return Column(
      children: [
        _buildHeader("Ressources disponibles", () => setState(() => selectedMatiere = null)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Filière : ${selectedFiliere!["name"].toUpperCase()}",
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                Text(
                  "Semestre : ${selectedSemestre!["name"]}",
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  "Matière : ${selectedMatiere!["name"].toUpperCase()}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedMatiere!["pdfs"].length,
            itemBuilder: (context, index) {
              final pdf = selectedMatiere!["pdfs"][index];
              return _buildCard(
                title: pdf["name"],
                icon: Icons.picture_as_pdf_outlined,
                isPdf: true,
                onTap: () => _openPdf(pdf["url"]),
                delay: index * 50,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onBack) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPdf = false,
    int delay = 0,
  }) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
            color: isPdf 
                ? AppTheme.secondary.withValues(alpha: 0.3) 
                : Theme.of(context).dividerColor.withValues(alpha: 0.1)
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPdf 
                        ? Colors.red.withValues(alpha: 0.1) 
                        : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon, 
                    color: isPdf ? Colors.red : AppTheme.primary,
                    size: 24
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.1, end: 0);
  }
}

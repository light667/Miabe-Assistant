import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import '../services/resources_service.dart';

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

  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color cardBackground = Color(0xFFF5F6F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

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
      // Essayer de charger depuis Supabase
      final manifest = await _resourcesService.getFullManifest();
      
      if (mounted && manifest['filieres'].isNotEmpty) {
        setState(() {
          filieres = manifest['filieres'];
          _isLoadingFromSupabase = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur Supabase, fallback sur le manifest local: $e');
    }
    
    // Fallback sur le manifest local
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
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ressources Pédagogiques",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 2,
      ),
      body: filieres.isEmpty
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentStep(),
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
        return _buildFiliereCard(filiere);
      },
    );
  }

  Widget _buildFiliereCard(Map<String, dynamic> filiere) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(Icons.school, color: primaryBlue, size: 24),
        title: Text(
          filiere["name"].toUpperCase(),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "${filiere["semestres"].length} semestres",
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              selectedFiliere = filiere;
              selectedSemestre = null;
              selectedMatiere = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildSemestreSelection() {
    return Column(
      children: [
        _buildBackButton(() => setState(() => selectedFiliere = null)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedFiliere!["semestres"].length,
            itemBuilder: (context, index) {
              final semestre = selectedFiliere!["semestres"][index];
              return _buildSemestreCard(semestre);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSemestreCard(Map<String, dynamic> semestre) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Text(
          semestre["name"],
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              selectedSemestre = semestre;
              selectedMatiere = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildMatiereSelection() {
    return Column(
      children: [
        _buildBackButton(() => setState(() => selectedSemestre = null)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Sélectionnez une matière pour accéder aux ressources.",
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedSemestre!["matieres"].length,
            itemBuilder: (context, index) {
              final matiere = selectedSemestre!["matieres"][index];
              return _buildMatiereCard(matiere);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatiereCard(Map<String, dynamic> matiere) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(Icons.book, color: primaryBlue, size: 24),
        title: Text(
          matiere["name"].toUpperCase(),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              selectedMatiere = matiere;
            });
          }
        },
      ),
    );
  }

  Widget _buildPdfSelection() {
    return Column(
      children: [
        _buildBackButton(() => setState(() => selectedMatiere = null)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filière : ${selectedFiliere!["name"].toUpperCase()}",
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              Text(
                "Semestre : ${selectedSemestre!["name"]}",
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
              Text(
                "Matière : ${selectedMatiere!["name"].toUpperCase()}",
                style: TextStyle(fontSize: 14, color: textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: selectedMatiere!["pdfs"].length,
            itemBuilder: (context, index) {
              final pdf = selectedMatiere!["pdfs"][index];
              return _buildPdfCard(pdf);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPdfCard(Map<String, dynamic> pdf) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardBackground,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(Icons.picture_as_pdf, color: primaryBlue, size: 24),
        title: Text(
          pdf["name"],
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: () => _openPdf(pdf["url"]),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (mounted) onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: cardBackground,
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_back, size: 16),
            SizedBox(width: 4),
            Text("Retour", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

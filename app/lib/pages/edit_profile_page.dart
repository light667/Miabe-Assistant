import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String _selectedFiliere = 'Licence Fondamentale - Génie Mécanique';
  String _selectedSemester = 'Semestre 1';
  String _email = '';

  final List<String> _filieres = [
    'Licence Fondamentale - Génie Civil',
    'Licence Fondamentale - Génie Électrique',
    'Licence Fondamentale - Génie Mécanique',
    'Licence Fondamentale - Intelligence Artificielle & Big Data',
    'Licence Fondamentale - Informatique et Système',
    'Licence Fondamentale - Logistique et Transport',
    'Licence Professionnelle - Génie Logiciel',
  ];

  final List<String> _semesters = [
    'Semestre 1',
    'Semestre 2',
    'Semestre 3',
    'Semestre 4',
    'Semestre 5',
    'Semestre 6',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _usernameController.text =
            prefs.getString('pseudo') ?? user?.displayName ?? '';
        _email = user?.email ?? prefs.getString('email') ?? 'Non défini';
        _selectedFiliere = prefs.getString('filiere') ?? 'Licence Fondamentale - Génie Mécanique';
        _selectedSemester = prefs.getString('semestre') ?? 'Semestre 1';
      });
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    await prefs.setString('pseudo', _usernameController.text);
    await prefs.setString('filiere', _selectedFiliere);
    await prefs.setString('semestre', _selectedSemester);
    if (user != null) {
      await user.updateDisplayName(_usernameController.text);
      await user.reload();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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
        title: const Text('Modifier le Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier vos informations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Pseudo',
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.user,
                    color: Color(0xFF1E3A8A),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le pseudo est requis';
                  } else if (value.length < 3) {
                    return 'Le pseudo doit faire au moins 3 caractères';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 800.ms).slideY(),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.envelope,
                    color: Color(0xFF1E3A8A),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                enabled: false,
              ).animate().fadeIn(duration: 1000.ms).slideY(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedFiliere,
                decoration: InputDecoration(
                  labelText: 'Filière',
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.graduationCap,
                    color: Color(0xFF1E3A8A),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _filieres.map<DropdownMenuItem<String>>((filiere) {
                  return DropdownMenuItem<String>(
                    value: filiere,
                    child: Text(filiere),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFiliere = value!;
                  });
                },
              ).animate().fadeIn(duration: 1200.ms).slideY(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semestre',
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.calendar,
                    color: Color(0xFF1E3A8A),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _semesters.map<DropdownMenuItem<String>>((semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value!;
                  });
                },
              ).animate().fadeIn(duration: 1400.ms).slideY(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveUserData();
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil mis à jour avec succès ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      }
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.floppyDisk,
                    color: Colors.black,
                  ),
                  label: const Text('Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ).animate().fadeIn(duration: 1600.ms).scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

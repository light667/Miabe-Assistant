import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miabeassistant/services/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _pseudo = 'Chargement...';
  String _email = 'Chargement...';
  String _filiere = 'Chargement...';
  String _semestre = 'Chargement...';
  bool _shouldRedirect = false;

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
        _pseudo =
            prefs.getString('pseudo') ?? user?.displayName ?? 'Non défini';
        _email = prefs.getString('email') ?? user?.email ?? 'Non défini';
        _filiere = prefs.getString('filiere') ?? 'Non défini';
        _semestre = prefs.getString('semestre') ?? 'Non défini';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Auth().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _shouldRedirect),
        ),
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Profil',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.user,
                        color: Color(0xFF1E3A8A),
                      ),
                      title: const Text('Pseudo'),
                      subtitle: Text(_pseudo),
                    ).animate().fadeIn(duration: 800.ms).slideY(),
                    const Divider(),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.envelope,
                        color: Color(0xFF1E3A8A),
                      ),
                      title: const Text('Email'),
                      subtitle: Text(_email),
                    ).animate().fadeIn(duration: 1000.ms).slideY(),
                    const Divider(),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.graduationCap,
                        color: Color(0xFF1E3A8A),
                      ),
                      title: const Text('Filière'),
                      subtitle: Text(_filiere),
                    ).animate().fadeIn(duration: 1200.ms).slideY(),
                    const Divider(),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.calendar,
                        color: Color(0xFF1E3A8A),
                      ),
                      title: const Text('Semestre'),
                      subtitle: Text(_semestre),
                    ).animate().fadeIn(duration: 1400.ms).slideY(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile').then((result) {
                    _loadUserData();
                    if (result == true) {
                      setState(() {
                        _shouldRedirect = true;
                      });
                    }
                  });
                },
                icon: const FaIcon(
                  FontAwesomeIcons.penToSquare,
                  color: Colors.black,
                ),
                label: const Text('Modifier le profil'),
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
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const FaIcon(
                  FontAwesomeIcons.rightFromBracket,
                  color: Colors.red,
                ),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate().fadeIn(duration: 1800.ms).scale(),
            ),
          ],
        ),
      ),
    );
  }
}

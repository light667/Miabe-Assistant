import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miabeassistant/services/firebase/auth.dart';
import 'package:provider/provider.dart';
import 'package:miabeassistant/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.title});
  final String title;

  Future<void> _sendFeedback(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final pseudo = prefs.getString('pseudo') ?? 'Utilisateur anonyme';
    final filiere = prefs.getString('filiere') ?? 'Non défini';
    final semestre = prefs.getString('semestre') ?? 'Non défini';

    final subject = 'Feedback Miabe Assistant - $pseudo';
    final body =
        'Bonjour,\n\nJe suis $pseudo ($filiere, $semestre).\n\nMes idées/suggestions/appreciations :\n\n';
    final uri = Uri(
      scheme: 'mailto',
      path: 'nethaniahdjossou@gmail.com',
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email de feedback ouvert !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Impossible d\'ouvrir l\'email. Utilisez votre app de messagerie.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Paramètres',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.user,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ).animate().fadeIn(duration: 800.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.bell,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ).animate().fadeIn(duration: 1000.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.moon,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Mode sombre'),
            trailing: Switch(
              value: themeProvider.darkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              activeThumbColor: const Color(0xFFFBBF24),
            ),
            onTap: () {
              themeProvider.toggleTheme(!themeProvider.darkMode);
            },
          ).animate().fadeIn(duration: 1200.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.message,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Envoyer un Feedback'),
            subtitle: const Text(
              'Partagez vos idées, suggestions et appréciations',
            ),
            onTap: () async {
              await _sendFeedback(context);
            },
          ).animate().fadeIn(duration: 1400.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.circleInfo,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('À propos'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Miabe Assistant',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.school,
                  color: Color(0xFF1E3A8A),
                  size: 40,
                ),
              );
            },
          ).animate().fadeIn(duration: 1600.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Déconnexion'),
            onTap: () async {
              await Auth().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ).animate().fadeIn(duration: 1800.ms).slideY(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.phone,
              color: Color(0xFF1E3A8A),
            ),
            title: const Text('Nous contacter'),
            subtitle: const Text('LinkedIn et WhatsApp'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Nous contacter'),
                    content: const Text('Choisissez comment nous contacter :'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final url =
                              'https://www.linkedin.com/in/kokou-light-djossou-90216233b';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.linkedin,
                              color: Color(0xFF0077B5),
                            ),
                            SizedBox(width: 8),
                            Text('LinkedIn'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final url = 'https://wa.link/hhk3di';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Color(0xFF25D366),
                            ),
                            SizedBox(width: 8),
                            Text('WhatsApp'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ).animate().fadeIn(duration: 1800.ms).slideY(),
        ],
      ),
    );
  }
}

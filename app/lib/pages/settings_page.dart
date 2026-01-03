import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miabeassistant/services/firebase/auth.dart';
import 'package:provider/provider.dart';
import 'package:miabeassistant/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miabeassistant/constants/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Préférences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 16),
          
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.user,
            title: 'Mon Profil',
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.bell,
            title: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(FontAwesomeIcons.moon, color: AppTheme.primary, size: 20),
              ),
              title: const Text("Mode Sombre", style: TextStyle(fontWeight: FontWeight.w600)),
              value: themeProvider.darkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
              activeColor: AppTheme.secondary,
            ),
          ).animate().fadeIn().slideX(),

          const SizedBox(height: 24),
          
          Text(
            'Support',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),

          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.message,
            title: 'Envoyer un Feedback',
            subtitle: "Partagez vos idées",
            onTap: () => _sendFeedback(context),
          ),
          
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.circleInfo,
            title: 'À propos',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Miabé ASSISTANT',
              applicationVersion: '2.0.0',
              applicationIcon: const Icon(Icons.school, size: 40, color: AppTheme.primary),
            ),
          ),

           const SizedBox(height: 24),

           _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.rightFromBracket,
            title: 'Déconnexion',
            isDestructive: true,
            onTap: () async {
              await Auth().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    final color = isDestructive ? AppTheme.error : AppTheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.error : null,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    ).animate().fadeIn().slideX();
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final pseudo = prefs.getString('pseudo') ?? 'Anonyme';
    final uri = Uri(
      scheme: 'mailto',
      path: 'nethaniahdjossou@gmail.com',
      queryParameters: {'subject': 'Feedback Miabé ASSISTANT - $pseudo'},
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

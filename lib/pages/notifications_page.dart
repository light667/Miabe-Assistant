import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Nouvelle ressource disponible',
        'description':
            'Cours de Mécanique du point mis à jour pour Semestre 1.',
        'date': '15 dec. 2025',
      },
      {
        'title': 'Mise à jour de l\'app',
        'description': 'Version 1.1 avec mode sombre ajouté.',
        'date': '13 dec. 2025',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
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
              'Notifications récentes',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.bell,
                        color: Color(0xFFFBBF24),
                      ),
                      title: Text(
                        notification['title']!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(notification['description']!),
                      trailing: Text(
                        notification['date']!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notification "${notification['title']}" marquée comme lue',
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

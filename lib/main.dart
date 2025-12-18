import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:miabeassistant/pages/login_page.dart';
import 'package:miabeassistant/pages/home_page.dart';
import 'package:miabeassistant/pages/chat_page.dart';
import 'package:miabeassistant/pages/resources_page.dart';
import 'package:miabeassistant/pages/settings_page.dart';
import 'package:miabeassistant/pages/welcome_page.dart';
import 'package:miabeassistant/pages/redirection_page.dart';
import 'package:miabeassistant/pages/profile_page.dart';
import 'package:miabeassistant/pages/edit_profile_page.dart';
import 'package:miabeassistant/pages/splash_screen_page.dart';
import 'package:miabeassistant/pages/onboarding_page.dart';
import 'package:miabeassistant/pages/department_selection_page.dart';
import 'package:miabeassistant/providers/theme_provider.dart';
import 'package:miabeassistant/providers/department_provider.dart';
import 'package:miabeassistant/pages/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/config/app_config.dart';
import 'package:miabeassistant/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialiser Supabase
  await SupabaseConfig.initialize();
  
  // Initialiser la configuration (clés API, etc.)
  try {
    await AppConfig.initialize();
    debugPrint('✅ Configuration chargée avec succès');
  } catch (e) {
    debugPrint('⚠️ Erreur de chargement de la configuration: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miabe Assistant',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreenPage(),
      routes: {
        '/splash': (context) => const SplashScreenPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/department_selection': (context) => const DepartmentSelectionPage(),
        '/login': (context) => const LoginPage(title: 'Connexion'),
        '/redirection': (context) => const RedirectionPage(),
        '/home': (context) => const HomePage(title: 'Accueil'),
        '/chat': (context) => const ChatPage(title: 'Chat'),
        '/resources': (context) => const ResourcesPage(),
        '/settings': (context) => const SettingsPage(title: 'Paramètres'),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/welcome': (context) => const WelcomePage(title: 'Accueil'),
      },
      onGenerateRoute: (settings) {
        // Handle the special route that decides between onboarding, login, and department selection
        if (settings.name == '/onboarding_or_department') {
          return MaterialPageRoute(
            builder: (context) {
              final departmentProvider = Provider.of<DepartmentProvider>(context, listen: false);
              final user = FirebaseAuth.instance.currentUser;
              
              // If first launch, show onboarding
              if (departmentProvider.isFirstLaunch) {
                return const OnboardingPage();
              } 
              // If not first launch but user not authenticated, show login
              else if (user == null) {
                return const LoginPage(title: 'Connexion');
              } 
              // If user is authenticated, show department selection
              else {
                return const DepartmentSelectionPage();
              }
            },
          );
        }
        return null;
      },
    );
  }
}

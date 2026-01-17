import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:miabeassistant/services/firebase/auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:miabeassistant/constants/app_theme.dart';
import 'package:miabeassistant/widgets/miabe_logo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _appVersion = '';
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _pseudoController = TextEditingController();
  
  // State
  bool _isLoading = false;
  bool _forLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['forLogin'] != null) {
        setState(() {
          _forLogin = args['forLogin'];
        });
      }
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _pseudoController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() => _forLogin = !_forLogin);
  }

  void _performAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_forLogin) {
          await Auth().loginWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          await Auth().createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
            _nomController.text.trim(),
            _prenomController.text.trim(),
            _pseudoController.text.trim(),
          );
        }
        if (mounted && context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted && context.mounted) {
          _showErrorSnackBar(e.message ?? 'Une erreur est survenue');
        }
      } finally {
        if (mounted && context.mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A), const Color(0xFF020617)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC), Colors.white],
                ),
              ),
            ),
          ),
          
          // 2. Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut).fadeIn(),
          ),
           Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withValues(alpha: 0.15),
              ),
            ).animate().scale(duration: 2500.ms, delay: 500.ms, curve: Curves.easeInOut).fadeIn(),
          ),

          // 3. Main Content Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      const MiabeLogo(size: 80, isAnimated: true),
                      const SizedBox(height: 24),
                      
                      Text(
                        _forLogin ? 'Bon retour !' : 'Créer un compte',
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().moveY(begin: 10, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _forLogin 
                          ? 'Accédez à votre espace étudiant premium.' 
                          : 'Rejoignez l\'élite académique.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 40),

                      // Glassmorphic Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color!.withValues(alpha: isDark ? 0.7 : 0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (!_forLogin) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _nomController,
                                            label: 'Nom',
                                            icon: Icons.person_outline,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _prenomController,
                                            label: 'Prénom',
                                            icon: Icons.person_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      controller: _pseudoController,
                                      label: 'Pseudo',
                                      icon: Icons.alternate_email,
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.school_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    showPassword: _obscurePassword,
                                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  
                                  if (!_forLogin) ...[
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      controller: _passwordConfirmationController,
                                      label: 'Confirmer',
                                      icon: Icons.lock_reset,
                                      isPassword: true,
                                      showPassword: _obscurePassword,
                                    ),
                                  ],

                                  if (_forLogin) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _showPasswordResetDialog,
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.primary,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        child: const Text('Mot de passe oublié ?'),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 32),
                                  
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _performAuth,
                                    child: _isLoading 
                                        ? const SizedBox(
                                            height: 24, 
                                            width: 24, 
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                          )
                                        : Text(_forLogin ? 'Se Connecter' : 'Commencer'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).moveY(begin: 30, end: 0),

                      const SizedBox(height: 32),

                      // Toggle Login/Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _forLogin ? 'Nouveau ici ? ' : 'Déjà membre ? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: _toggleForm,
                            child: Text(
                              _forLogin ? 'Créer un compte' : 'Se connecter',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Continuer avec', style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Social Buttons (GitHub disabled) — center Google button
                      Center(
                        child: SizedBox(
                          width: 260,
                          child: _buildSocialButtonWithImage(
                            imagePath: 'assets/images/google.png',
                            label: 'Google',
                            onTap: () async {
                              setState(() => _isLoading = true);
                              try {
                                final user = await Auth().signInWithGoogle();
                                if (user != null && mounted) Navigator.pushReplacementNamed(context, '/redirection');
                              } catch (e) {
                                if (mounted) _showErrorSnackBar('Erreur Google: $e');
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      Text('v$_appVersion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword, // Corrected logic here
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requis';
        if (label.contains('Email') && !value.contains('@')) return 'Email invalide';
        if (label.contains('Passe') && value.length < 6) return 'Min 6 caractères';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility, size: 22),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }
  
  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
     return OutlinedButton.icon(
        onPressed: _isLoading ? null : onTap,
        icon: FaIcon(icon, size: 20, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
           backgroundColor: Theme.of(context).cardTheme.color?.withValues(alpha: 0.5),
        )
      );
  }

  Widget _buildSocialButtonWithImage({required String imagePath, required String label, required VoidCallback onTap}) {
     return OutlinedButton(
        onPressed: _isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
           backgroundColor: Theme.of(context).cardTheme.color?.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      );
  }

  void _showPasswordResetDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre email pour recevoir le lien.'),
            const SizedBox(height: 16),
            TextField(
              controller: resetController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Auth().sendPasswordResetEmail(resetController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email envoyé')));
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

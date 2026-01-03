import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Configuration spécifique pour le web
    clientId: kIsWeb
        ? 'YOUR_GOOGLE_SIGNIN_CLIENT_ID'
        : null,
  );

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Sauvegarder l'email dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String nom,
    String prenom,
    String pseudo,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Mise à jour du profil avec le pseudo comme displayName
    await userCredential.user!.updateDisplayName(pseudo);
    
    // Sauvegarder les données dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('pseudo', pseudo);
    
    // Note: Pour stocker nom et prénom, vous devrez utiliser Firestore
    // Exemple: await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
    //   'nom': nom,
    //   'prenom': prenom,
    //   'pseudo': pseudo,
    //   'email': email,
    // });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Méthode spécifique pour le web
        return await _signInWithGoogleWeb();
      } else {
        // Méthode pour mobile
        return await _signInWithGoogleMobile();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur Google Sign-In: $e');
      }
      rethrow;
    }
  }

  Future<UserCredential> _signInWithGoogleMobile() async {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Connexion Google annulée par l\'utilisateur',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    // Sauvegarder les données dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (userCredential.user?.email != null) {
      await prefs.setString('email', userCredential.user!.email!);
    }
    if (userCredential.user?.displayName != null) {
      await prefs.setString('pseudo', userCredential.user!.displayName!);
    }
    
    return userCredential;
  }

  Future<UserCredential> _signInWithGoogleWeb() async {
    // Pour le web, utilise la méthode native de Firebase Auth
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
    
    // Sauvegarder les données dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (userCredential.user?.email != null) {
      await prefs.setString('email', userCredential.user!.email!);
    }
    if (userCredential.user?.displayName != null) {
      await prefs.setString('pseudo', userCredential.user!.displayName!);
    }
    
    return userCredential;
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      // IMPORTANT: Ne jamais exposer le client secret dans le code
      // Le client secret doit être stocké de manière sécurisée sur un backend
      // Pour l'instant, cette fonctionnalité est désactivée pour des raisons de sécurité
      throw FirebaseAuthException(
        code: 'ERROR_NOT_IMPLEMENTED',
        message: 'La connexion GitHub nécessite une configuration backend sécurisée',
      );

      // TODO: Implémenter un backend sécurisé pour gérer l'authentification GitHub
      /*
      const clientId = 'Ov23lisp9CxpO1uOAY7H';
      final result = await FlutterWebAuth.authenticate(
        url:
            'https://github.com/login/oauth/authorize?client_id=$clientId&scope=read:user%20user:email',
        callbackUrlScheme: 'https',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Code GitHub non reçu');
      }

      // Le client secret doit être utilisé côté serveur uniquement
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret, // À faire côté serveur
          'code': code,
        },
      );

      final responseBody = json.decode(response.body);
      if (responseBody['access_token'] == null) {
        throw Exception('Access token GitHub non reçu');
      }

      final accessToken = responseBody['access_token'];
      final githubAuthCredential = GithubAuthProvider.credential(accessToken);
      return await _firebaseAuth.signInWithCredential(githubAuthCredential);
      */
    } catch (e) {
      if (kDebugMode) {
        print('Erreur GitHub Sign-In: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}

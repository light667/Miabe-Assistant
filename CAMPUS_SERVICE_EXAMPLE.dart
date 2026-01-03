// Exemple d'utilisation du service Campus

import 'package:miabeassistant/services/campus_service.dart';

// ============================================
// EXEMPLE 1: Toggle Like
// ============================================

Future<void> toggleLikeExample() async {
  try {
    final isNowLiked = await CampusService.toggleLike(
      userId: '2c188471-d6d2-56ae-aa5c-c05908809176',  // Firebase UUID
      contentType: 'post',  // ou 'comment', 'fiche'
      contentId: 'uuid-du-post-ou-commentaire',
    );
    
    print(isNowLiked ? '❤️ Liké!' : '💔 Unlike');
  } catch (e) {
    // Erreur bien parsée:
    final errorMsg = CampusService.parseSupabaseError(e);
    showErrorSnackBar(errorMsg);
  }
}

// ============================================
// EXEMPLE 2: Vérifier si utilisateur a liké
// ============================================

Future<void> checkUserLiked() async {
  final hasLiked = await CampusService.hasUserLiked(
    userId: userId,
    contentType: 'post',
    contentId: postId,
  );
  
  setState(() {
    _isLiked = hasLiked;
  });
}

// ============================================
// EXEMPLE 3: Obtenir le nombre de likes
// ============================================

Future<void> getLikes() async {
  final count = await CampusService.getLikeCount(
    contentType: 'post',
    contentId: postId,
  );
  
  setState(() {
    _likeCount = count;
  });
}

// ============================================
// UTILISATION DANS UN WIDGET
// ============================================

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String userId;
  
  const PostCard({required this.post, required this.userId});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final isLiked = await CampusService.hasUserLiked(
      userId: widget.userId,
      contentType: 'post',
      contentId: widget.post['id'],
    );
    
    final count = await CampusService.getLikeCount(
      contentType: 'post',
      contentId: widget.post['id'],
    );
    
    setState(() {
      _isLiked = isLiked;
      _likeCount = count;
    });
  }

  Future<void> _toggleLike() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final isNowLiked = await CampusService.toggleLike(
        userId: widget.userId,
        contentType: 'post',
        contentId: widget.post['id'],
      );
      
      setState(() {
        _isLiked = isNowLiked;
        _likeCount += isNowLiked ? 1 : -1;
      });
      
      // Feedback utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNowLiked ? '❤️ Liké!' : '💔 Unlike'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      final errorMsg = CampusService.parseSupabaseError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $errorMsg'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... Contenu du post ...
            
            SizedBox(height: 16),
            
            // Bouton Like
            GestureDetector(
              onTap: _isLoading ? null : _toggleLike,
              child: Row(
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$_likeCount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// GESTION D'ERREURS RECOMMANDÉE
// ============================================

void showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('❌ $message'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Retour',
        onPressed: () {},
      ),
    ),
  );
}

// ============================================
// TYPES D'ERREURS GÉRÉES
// ============================================

/*
CampusService.parseSupabaseError() retourne:

1. RLS Error:
   "Vous n'avez pas la permission d'effectuer cette action."

2. DB Structure Error:
   "Erreur de structure de base de données. Contactez l'admin."

3. Auth Error:
   "Vous devez être connecté pour effectuer cette action."

4. Bad Request:
   "Données invalides. Vérifiez que vous avez rempli tous les champs."

5. Conflict:
   "Cette action a déjà été effectuée."

6. Generic:
   "Une erreur s'est produite. Veuillez réessayer."
*/

-- ============================================
-- SCRIPT SQL POUR LA PARTIE CAMPUS COLLABORATIF
-- ============================================

-- Table des posts/discussions de la communauté
CREATE TABLE IF NOT EXISTS campus_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  filiere TEXT NOT NULL,
  semestre TEXT NOT NULL,
  author TEXT NOT NULL,
  author_id UUID,
  type TEXT NOT NULL CHECK (type IN ('question', 'conseil', 'annonce')),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  is_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des commentaires sur les posts
CREATE TABLE IF NOT EXISTS campus_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES campus_posts(id) ON DELETE CASCADE,
  author TEXT NOT NULL,
  author_id UUID,
  content TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  is_answer BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des fiches partagées
CREATE TABLE IF NOT EXISTS campus_fiches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  filiere TEXT NOT NULL,
  semestre TEXT NOT NULL,
  matiere TEXT NOT NULL,
  titre TEXT NOT NULL,
  description TEXT,
  author TEXT NOT NULL,
  author_id UUID,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER,
  downloads INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des membres actifs de la communauté
CREATE TABLE IF NOT EXISTS campus_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID UNIQUE,
  pseudo TEXT NOT NULL,
  filiere TEXT NOT NULL,
  semestre TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  posts_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  fiches_count INTEGER DEFAULT 0,
  reputation INTEGER DEFAULT 0,
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des signalements (modération)
CREATE TABLE IF NOT EXISTS campus_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'comment', 'fiche')),
  content_id UUID NOT NULL,
  reporter_id UUID,
  reporter_pseudo TEXT NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Table des notifications
CREATE TABLE IF NOT EXISTS campus_notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('comment', 'like', 'answer', 'mention')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  post_id UUID,
  comment_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des likes (pour éviter les duplications)
CREATE TABLE IF NOT EXISTS campus_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'comment', 'fiche')),
  content_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, content_type, content_id)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_posts_filiere_semestre ON campus_posts(filiere, semestre);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON campus_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON campus_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_fiches_filiere_semestre ON campus_fiches(filiere, semestre);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON campus_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON campus_notifications(is_read);

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour updated_at
DROP TRIGGER IF EXISTS update_campus_posts_updated_at ON campus_posts;
CREATE TRIGGER update_campus_posts_updated_at
    BEFORE UPDATE ON campus_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_campus_comments_updated_at ON campus_comments;
CREATE TRIGGER update_campus_comments_updated_at
    BEFORE UPDATE ON campus_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_campus_fiches_updated_at ON campus_fiches;
CREATE TRIGGER update_campus_fiches_updated_at
    BEFORE UPDATE ON campus_fiches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour incrémenter automatiquement comments_count
CREATE OR REPLACE FUNCTION increment_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE campus_posts
    SET comments_count = comments_count + 1
    WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour incrémenter comments_count
DROP TRIGGER IF EXISTS increment_comments_count_trigger ON campus_comments;
CREATE TRIGGER increment_comments_count_trigger
    AFTER INSERT ON campus_comments
    FOR EACH ROW
    EXECUTE FUNCTION increment_comments_count();

-- Fonction pour décrémenter comments_count
CREATE OR REPLACE FUNCTION decrement_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE campus_posts
    SET comments_count = comments_count - 1
    WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ language 'plpgsql';

-- Trigger pour décrémenter comments_count
DROP TRIGGER IF EXISTS decrement_comments_count_trigger ON campus_comments;
CREATE TRIGGER decrement_comments_count_trigger
    AFTER DELETE ON campus_comments
    FOR EACH ROW
    EXECUTE FUNCTION decrement_comments_count();

-- ============================================
-- RLS (Row Level Security) - Sécurisé et Fonctionnel
-- ============================================
-- IMPORTANT: Tous les appels doivent avoir Firebase UID en tant que user_id
-- 
-- Architecture:
-- - Utilisateurs anon + Firebase Auth
-- - Vérification user_id passé par le client (confiance conditionnelle)
-- - Modération possible avec flag/delete

ALTER TABLE campus_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_fiches ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_likes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CAMPUS POSTS - Politiques
-- ============================================
-- SELECT: Tout le monde peut lire les posts publics
CREATE POLICY "campus_posts_select_all" ON campus_posts
  FOR SELECT USING (true);

-- INSERT: Tout le monde peut créer (confiance au user_id du client)
CREATE POLICY "campus_posts_insert_all" ON campus_posts
  FOR INSERT WITH CHECK (true);

-- UPDATE: Seul l'auteur peut modifier
CREATE POLICY "campus_posts_update_author" ON campus_posts
  FOR UPDATE USING (author_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (author_id = auth.uid() OR auth.role() = 'service_role');

-- DELETE: Seul l'auteur peut supprimer
CREATE POLICY "campus_posts_delete_author" ON campus_posts
  FOR DELETE USING (author_id = auth.uid() OR auth.role() = 'service_role');

-- ============================================
-- CAMPUS COMMENTS - Politiques
-- ============================================
CREATE POLICY "campus_comments_select_all" ON campus_comments
  FOR SELECT USING (true);

CREATE POLICY "campus_comments_insert_all" ON campus_comments
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_comments_update_author" ON campus_comments
  FOR UPDATE USING (author_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (author_id = auth.uid() OR auth.role() = 'service_role');

CREATE POLICY "campus_comments_delete_author" ON campus_comments
  FOR DELETE USING (author_id = auth.uid() OR auth.role() = 'service_role');

-- ============================================
-- CAMPUS FICHES - Politiques
-- ============================================
CREATE POLICY "campus_fiches_select_all" ON campus_fiches
  FOR SELECT USING (true);

CREATE POLICY "campus_fiches_insert_all" ON campus_fiches
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_fiches_update_author" ON campus_fiches
  FOR UPDATE USING (author_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (author_id = auth.uid() OR auth.role() = 'service_role');

CREATE POLICY "campus_fiches_delete_author" ON campus_fiches
  FOR DELETE USING (author_id = auth.uid() OR auth.role() = 'service_role');

-- ============================================
-- CAMPUS LIKES - Politiques (CRUCIAL)
-- ============================================
-- Les likes doivent pouvoir être insert/delete par n'importe qui
-- car nous n'utilisons pas Supabase Auth, mais Firebase Auth
CREATE POLICY "campus_likes_select_all" ON campus_likes
  FOR SELECT USING (true);

CREATE POLICY "campus_likes_insert_all" ON campus_likes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_likes_delete_all" ON campus_likes
  FOR DELETE USING (true);

-- ============================================
-- CAMPUS MEMBERS - Politiques
-- ============================================
CREATE POLICY "campus_members_select_all" ON campus_members
  FOR SELECT USING (true);

CREATE POLICY "campus_members_insert_all" ON campus_members
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_members_update_user" ON campus_members
  FOR UPDATE USING (user_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (user_id = auth.uid() OR auth.role() = 'service_role');

CREATE POLICY "campus_members_delete_user" ON campus_members
  FOR DELETE USING (user_id = auth.uid() OR auth.role() = 'service_role');

-- ============================================
-- CAMPUS REPORTS - Politiques
-- ============================================
CREATE POLICY "campus_reports_insert_all" ON campus_reports
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_reports_select_service_role" ON campus_reports
  FOR SELECT USING (auth.role() = 'service_role' OR reporter_id = auth.uid());

-- ============================================
-- CAMPUS NOTIFICATIONS - Politiques
-- ============================================
CREATE POLICY "campus_notifications_select_owner" ON campus_notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "campus_notifications_insert_service_role" ON campus_notifications
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "campus_notifications_update_owner" ON campus_notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

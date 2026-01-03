-- ============================================
-- MIGRATION: Fixer les permissions Storage
-- ============================================
-- Date: 2025-01-03
-- Description: Corriger les RLS pour campus_files et configurer les uploads

-- 1. Créer bucket 'campus_files' s'il n'existe pas
-- (À faire manuellement dans Supabase Dashboard)
-- Nom: campus_files
-- Public: false (contrôle via RLS)
-- Allowed MIME types: image/*, application/pdf, application/msword, etc.

-- 2. Configurer les RLS pour le bucket 'campus_files'
-- Dans Supabase Dashboard:
-- Policies > Storage > campus_files > New Policy

-- RLS Policy: "Allow authenticated users to upload files"
-- Role: authenticated
-- Operation: INSERT, SELECT
-- POSTGRES_ROLE: authenticated
-- Using expression: true
-- With check expression: true

-- RLS Policy: "Allow public to download files"
-- Role: public (anon)
-- Operation: SELECT
-- Using expression: true

-- 3. Ajouter contrainte de taille de fichier
-- (Faire via Firebase Rules ou application logic)
-- Limite recommandée: 10MB par fichier

-- 4. Ajouter bucket 'campus_fiches' pour les fiches partagées
-- (Même configuration que campus_files)

-- ============================================
-- Vérification des tables et RLS
-- ============================================

-- Vérifier que campus_likes a les bonnes RLS
ALTER TABLE campus_likes ENABLE ROW LEVEL SECURITY;

-- Supprimer les vieilles policies (si présentes)
DROP POLICY IF EXISTS "Enable read access for all users" ON campus_likes;
DROP POLICY IF EXISTS "Enable insert for all users" ON campus_likes;
DROP POLICY IF EXISTS "Enable delete for all users" ON campus_likes;

-- Créer les bonnes policies
CREATE POLICY "campus_likes_select_all" ON campus_likes
  FOR SELECT USING (true);

CREATE POLICY "campus_likes_insert_all" ON campus_likes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "campus_likes_delete_all" ON campus_likes
  FOR DELETE USING (true);

-- ============================================
-- Notes importantes
-- ============================================
-- 
-- 1. Authentification mixte:
--    - Firebase Auth pour utilisateurs
--    - Supabase Auth pour authentification (optionnel)
--    - Stockage UUID v5 depuis email Firebase
--
-- 2. Uploads fichiers:
--    - Bucket: campus_files
--    - Chemin: campus_fiches/FILIERE/SEMESTRE/FILENAME
--    - Attention: Caractères spéciaux (accents) → sanitization
--
-- 3. Sécurité Storage:
--    - Vérifier les permissions du bucket
--    - Logs d'upload (audit trail)
--    - Limiter taille des fichiers
--
-- ============================================

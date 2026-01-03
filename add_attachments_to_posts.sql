-- Ajout de colonnes pour les pièces jointes dans les posts
-- Exécuter ce script si la table campus_posts existe déjà

ALTER TABLE campus_posts 
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name TEXT,
ADD COLUMN IF NOT EXISTS attachment_type TEXT;

-- Commentaires pour documenter les nouvelles colonnes
COMMENT ON COLUMN campus_posts.attachment_url IS 'URL du fichier joint (PDF, image, doc)';
COMMENT ON COLUMN campus_posts.attachment_name IS 'Nom original du fichier joint';
COMMENT ON COLUMN campus_posts.attachment_type IS 'Extension du fichier (pdf, jpg, png, doc, docx)';

-- SQL script to create Campus Collaboratif tables in Supabase

-- Table for campus posts (discussions, questions, conseils)
CREATE TABLE IF NOT EXISTS campus_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    filiere TEXT NOT NULL,
    semestre INTEGER NOT NULL,
    author TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('question', 'conseil', 'discussion')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for filtering by filiere and semestre
CREATE INDEX IF NOT EXISTS idx_campus_posts_filiere_semestre 
ON campus_posts(filiere, semestre);

-- Index for sorting by creation date
CREATE INDEX IF NOT EXISTS idx_campus_posts_created_at 
ON campus_posts(created_at DESC);

-- Table for shared fiches (study materials)
CREATE TABLE IF NOT EXISTS campus_fiches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    filiere TEXT NOT NULL,
    semestre INTEGER NOT NULL,
    author TEXT NOT NULL,
    title TEXT NOT NULL,
    matiere TEXT NOT NULL,
    file_url TEXT NOT NULL,
    downloads INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for filtering by filiere and semestre
CREATE INDEX IF NOT EXISTS idx_campus_fiches_filiere_semestre 
ON campus_fiches(filiere, semestre);

-- Index for sorting by downloads
CREATE INDEX IF NOT EXISTS idx_campus_fiches_downloads 
ON campus_fiches(downloads DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE campus_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_fiches ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Anyone can read posts
CREATE POLICY "Anyone can read campus posts"
ON campus_posts FOR SELECT
USING (true);

-- RLS Policy: Authenticated users can insert posts
CREATE POLICY "Authenticated users can insert campus posts"
ON campus_posts FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Users can update their own posts
CREATE POLICY "Users can update their own campus posts"
ON campus_posts FOR UPDATE
USING (auth.uid()::text = author);

-- RLS Policy: Anyone can read fiches
CREATE POLICY "Anyone can read campus fiches"
ON campus_fiches FOR SELECT
USING (true);

-- RLS Policy: Authenticated users can insert fiches
CREATE POLICY "Authenticated users can insert campus fiches"
ON campus_fiches FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Users can update their own fiches
CREATE POLICY "Users can update their own campus fiches"
ON campus_fiches FOR UPDATE
USING (auth.uid()::text = author);

-- Grant permissions
GRANT ALL ON campus_posts TO authenticated;
GRANT ALL ON campus_fiches TO authenticated;
GRANT SELECT ON campus_posts TO anon;
GRANT SELECT ON campus_fiches TO anon;

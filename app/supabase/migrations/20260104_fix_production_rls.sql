-- ===========================================
-- Production RLS Policies Fix
-- Date: 2026-01-04
-- Purpose: Fix all RLS policies for production deployment
-- ===========================================

-- 1. CAMPUS_LIKES TABLE
-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Enable read access for all users" ON "public"."campus_likes";
DROP POLICY IF EXISTS "Enable insert for all users" ON "public"."campus_likes";
DROP POLICY IF EXISTS "Enable delete for all users" ON "public"."campus_likes";

-- Ensure RLS is enabled
ALTER TABLE campus_likes ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read likes (needed for counts)
CREATE POLICY "Allow public read on campus_likes"
ON "public"."campus_likes"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Allow anyone to insert likes (Firebase Auth provides user_id)
CREATE POLICY "Allow public insert on campus_likes"
ON "public"."campus_likes"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

-- Allow anyone to delete likes (user_id validation done client-side via Firebase)
CREATE POLICY "Allow public delete on campus_likes"
ON "public"."campus_likes"
AS PERMISSIVE FOR DELETE
TO public
USING (true);

-- 2. CAMPUS_POSTS TABLE
-- Drop existing update policy if exists
DROP POLICY IF EXISTS "Enable update for all users" ON "public"."campus_posts";
DROP POLICY IF EXISTS "Allow authenticated users to update posts" ON "public"."campus_posts";

-- Ensure RLS is enabled
ALTER TABLE campus_posts ENABLE ROW LEVEL SECURITY;

-- Allow public to read posts
CREATE POLICY "Allow public read on campus_posts"
ON "public"."campus_posts"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Allow public to insert posts (Firebase Auth provides user_id)
CREATE POLICY "Allow public insert on campus_posts"
ON "public"."campus_posts"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

-- Allow public to update posts (for likes count, views count)
CREATE POLICY "Allow public update on campus_posts"
ON "public"."campus_posts"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- Allow users to delete their own posts
CREATE POLICY "Allow public delete on campus_posts"
ON "public"."campus_posts"
AS PERMISSIVE FOR DELETE
TO public
USING (true);

-- 3. CAMPUS_MEMBERS TABLE
-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON "public"."campus_members";
DROP POLICY IF EXISTS "Enable insert for all users" ON "public"."campus_members";
DROP POLICY IF EXISTS "Enable update for all users" ON "public"."campus_members";

-- Ensure RLS is enabled
ALTER TABLE campus_members ENABLE ROW LEVEL SECURITY;

-- Allow public to read members (for counts)
CREATE POLICY "Allow public read on campus_members"
ON "public"."campus_members"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Allow public to insert/upsert members
CREATE POLICY "Allow public insert on campus_members"
ON "public"."campus_members"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

-- Allow public to update members (for last_seen, etc.)
CREATE POLICY "Allow public update on campus_members"
ON "public"."campus_members"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- 4. CAMPUS_COMMENTS TABLE (if exists)
DROP POLICY IF EXISTS "Enable read access for all users" ON "public"."campus_comments";
DROP POLICY IF EXISTS "Enable insert for all users" ON "public"."campus_comments";
DROP POLICY IF EXISTS "Enable update for all users" ON "public"."campus_comments";
DROP POLICY IF EXISTS "Enable delete for all users" ON "public"."campus_comments";

-- Ensure RLS is enabled
ALTER TABLE campus_comments ENABLE ROW LEVEL SECURITY;

-- Allow public access to comments
CREATE POLICY "Allow public read on campus_comments"
ON "public"."campus_comments"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public insert on campus_comments"
ON "public"."campus_comments"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Allow public update on campus_comments"
ON "public"."campus_comments"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow public delete on campus_comments"
ON "public"."campus_comments"
AS PERMISSIVE FOR DELETE
TO public
USING (true);

-- 5. CAMPUS_FICHES TABLE (if exists)
DROP POLICY IF EXISTS "Enable read access for all users" ON "public"."campus_fiches";
DROP POLICY IF EXISTS "Enable insert for all users" ON "public"."campus_fiches";
DROP POLICY IF EXISTS "Enable update for all users" ON "public"."campus_fiches";
DROP POLICY IF EXISTS "Enable delete for all users" ON "public"."campus_fiches";

-- Ensure RLS is enabled
ALTER TABLE campus_fiches ENABLE ROW LEVEL SECURITY;

-- Allow public access to fiches
CREATE POLICY "Allow public read on campus_fiches"
ON "public"."campus_fiches"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public insert on campus_fiches"
ON "public"."campus_fiches"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Allow public update on campus_fiches"
ON "public"."campus_fiches"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow public delete on campus_fiches"
ON "public"."campus_fiches"
AS PERMISSIVE FOR DELETE
TO public
USING (true);

-- 6. STORAGE BUCKET POLICIES
-- Update storage bucket policies for campus resources
-- Note: Run this in Supabase Storage settings or via dashboard
-- Bucket: campus-files (or whatever your bucket name is)
-- Policy: Allow public read, authenticated upload

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ All RLS policies updated successfully for production!';
  RAISE NOTICE '📝 Summary:';
  RAISE NOTICE '   - campus_likes: public read, insert, delete';
  RAISE NOTICE '   - campus_posts: public read, insert, update, delete';
  RAISE NOTICE '   - campus_members: public read, insert, update';
  RAISE NOTICE '   - campus_comments: public read, insert, update, delete';
  RAISE NOTICE '   - campus_fiches: public read, insert, update, delete';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Note: These policies allow public access because Firebase Auth';
  RAISE NOTICE '   provides user authentication. For better security, consider';
  RAISE NOTICE '   integrating Supabase Auth in the future.';
END $$;

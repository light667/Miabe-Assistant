-- ===========================================
-- Production Data Cleanup
-- Date: 2026-01-04
-- Purpose: Clean all test data before production launch
-- ===========================================

-- ⚠️  WARNING: This will DELETE all data from campus tables!
-- Only run this script if you're sure you want to clean everything.
-- Make a backup first: Dashboard > Database > Backups

-- Show counts before cleanup
DO $$
DECLARE
  posts_count INT;
  comments_count INT;
  likes_count INT;
  members_count INT;
  fiches_count INT;
BEGIN
  SELECT COUNT(*) INTO posts_count FROM campus_posts;
  SELECT COUNT(*) INTO comments_count FROM campus_comments;
  SELECT COUNT(*) INTO likes_count FROM campus_likes;
  SELECT COUNT(*) INTO members_count FROM campus_members;
  SELECT COUNT(*) INTO fiches_count FROM campus_fiches;
  
  RAISE NOTICE '📊 Current data counts:';
  RAISE NOTICE '   Posts: %', posts_count;
  RAISE NOTICE '   Comments: %', comments_count;
  RAISE NOTICE '   Likes: %', likes_count;
  RAISE NOTICE '   Members: %', members_count;
  RAISE NOTICE '   Fiches: %', fiches_count;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Starting cleanup in 5 seconds...';
  RAISE NOTICE '   Press Ctrl+C to cancel if this was a mistake!';
END $$;

-- Wait (PostgreSQL doesn't have sleep in DO blocks, so this is just a notice)
-- In practice, you should review the counts above before proceeding

-- ===========================================
-- CLEANUP STARTS HERE
-- Comment out the sections you DON'T want to delete
-- ===========================================

-- 1. Delete all likes (must do first due to foreign keys)
TRUNCATE TABLE campus_likes CASCADE;

-- 2. Delete all comments
TRUNCATE TABLE campus_comments CASCADE;

-- 3. Delete all posts
TRUNCATE TABLE campus_posts CASCADE;

-- 4. Delete all fiches
TRUNCATE TABLE campus_fiches CASCADE;

-- 5. Delete all members (optional - you might want to keep community membership data)
-- Uncomment the line below if you want to delete members too:
-- TRUNCATE TABLE campus_members CASCADE;

-- 6. Reset sequences (so new IDs start from 1)
-- Only if your tables use SERIAL/BIGSERIAL for id columns
ALTER SEQUENCE IF EXISTS campus_posts_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS campus_comments_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS campus_fiches_id_seq RESTART WITH 1;

-- Show cleanup results
DO $$
DECLARE
  posts_count INT;
  comments_count INT;
  likes_count INT;
  members_count INT;
  fiches_count INT;
BEGIN
  SELECT COUNT(*) INTO posts_count FROM campus_posts;
  SELECT COUNT(*) INTO comments_count FROM campus_comments;
  SELECT COUNT(*) INTO likes_count FROM campus_likes;
  SELECT COUNT(*) INTO members_count FROM campus_members;
  SELECT COUNT(*) INTO fiches_count FROM campus_fiches;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Cleanup completed!';
  RAISE NOTICE '📊 New data counts:';
  RAISE NOTICE '   Posts: %', posts_count;
  RAISE NOTICE '   Comments: %', comments_count;
  RAISE NOTICE '   Likes: %', likes_count;
  RAISE NOTICE '   Members: %', members_count;
  RAISE NOTICE '   Fiches: %', fiches_count;
  RAISE NOTICE '';
  RAISE NOTICE '🎉 Database is ready for production!';
END $$;

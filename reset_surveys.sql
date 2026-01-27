-- ============================================================================
-- RESET SURVEY DATA
-- ============================================================================
-- Run this script to DELETE ALL survey responses but KEEP your configuration 
-- (Programs, Animals, etc.) safe.
-- ============================================================================

-- 1. Wipe all survey responses (RESTART IDENTITY resets the ID counter if it was serial)
TRUNCATE TABLE surveyresponses CASCADE;

-- 2. Verify it's empty
SELECT COUNT(*) as remaining_surveys FROM surveyresponses;

-- ============================================================================
-- OPTIONAL: NUCLEAR OPTION (Delete EVERYTHING)
-- ============================================================================
-- Uncomment the lines below ONLY if you want to wipe the ENTIRE database
-- and start completely fresh with schema.sql + seed_data.sql

-- TRUNCATE TABLE surveyresponses, experiences, constituentprofiles, constituents, animals, farmzones, programcatalog CASCADE;

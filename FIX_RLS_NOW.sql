-- ============================================================================
-- 🚨 EMERGENCY RLS FIX - COPY THIS ENTIRE FILE INTO SUPABASE SQL EDITOR
-- ============================================================================
-- Run this ONCE to fix the "row violates row-level security policy" error
-- ============================================================================

-- STEP 1: Add missing column if it doesn't exist
ALTER TABLE surveyresponses 
ADD COLUMN IF NOT EXISTS is_returning_visitor BOOLEAN DEFAULT FALSE;

-- STEP 2: Enable RLS (no harm if already enabled)
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- STEP 3: Drop existing policies to recreate cleanly
DROP POLICY IF EXISTS "Allow public survey submissions" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can view surveys" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can update" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can delete" ON surveyresponses;
DROP POLICY IF EXISTS "anon_insert" ON surveyresponses;
DROP POLICY IF EXISTS "Enable insert for anon" ON surveyresponses;

-- STEP 4: Create policies
CREATE POLICY "Allow public survey submissions" ON surveyresponses
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

CREATE POLICY "Only authenticated can view surveys" ON surveyresponses
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Only authenticated can update" ON surveyresponses
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "Only authenticated can delete" ON surveyresponses
    FOR DELETE TO authenticated
    USING (true);

-- STEP 5: ⚠️ CRITICAL - GRANT TABLE-LEVEL PERMISSIONS
-- This is what was MISSING! RLS policies are not enough - roles need GRANT too
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT INSERT ON surveyresponses TO anon;
GRANT INSERT, SELECT, UPDATE, DELETE ON surveyresponses TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- STEP 6: Verify it worked
SELECT 
    policyname, 
    cmd, 
    roles 
FROM pg_policies 
WHERE tablename = 'surveyresponses';

-- ============================================================================
-- ✅ DONE! Test your survey form now.
-- ============================================================================

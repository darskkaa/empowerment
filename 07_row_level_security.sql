-- ============================================
-- ROW LEVEL SECURITY (RLS) FOR DASHBOARD
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable RLS on SurveyResponses table
ALTER TABLE "SurveyResponses" ENABLE ROW LEVEL SECURITY;

-- Policy 1: Allow ANYONE to INSERT (for public survey submissions)
CREATE POLICY "Allow public inserts" ON "SurveyResponses"
FOR INSERT
TO public
WITH CHECK (true);

-- Policy 2: Only AUTHENTICATED users can SELECT (read data)
CREATE POLICY "Only authenticated users can read" ON "SurveyResponses"
FOR SELECT
TO authenticated
USING (true);

-- Policy 3: Only AUTHENTICATED users can UPDATE
CREATE POLICY "Only authenticated users can update" ON "SurveyResponses"
FOR UPDATE
TO authenticated
USING (true);

-- Policy 4: Only AUTHENTICATED users can DELETE
CREATE POLICY "Only authenticated users can delete" ON "SurveyResponses"
FOR DELETE
TO authenticated
USING (true);

-- ============================================
-- VERIFICATION
-- ============================================
-- After running this, test by:
-- 1. Opening the survey (index.html) - submissions should still work
-- 2. Opening dashboard.html WITHOUT logging in - should see no data
-- 3. Logging in with Tiffany's email - should see all data

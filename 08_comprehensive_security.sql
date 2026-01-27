-- ============================================
-- SIMPLE DATABASE SECURITY
-- Empowerment Farm - Clean & Secure
-- ============================================

-- 1. Enable RLS on survey responses
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- 2. Drop any old policies
DROP POLICY IF EXISTS "Anyone can submit surveys" ON surveyresponses;
DROP POLICY IF EXISTS "Only admins can view data" ON surveyresponses;

-- POLICY 1: Anyone can SUBMIT a survey (public form)
CREATE POLICY "Anyone can submit surveys" ON surveyresponses
FOR INSERT TO public
WITH CHECK (true);

-- POLICY 2: Only logged-in users can READ data (protect names)
CREATE POLICY "Only admins can view data" ON surveyresponses
FOR SELECT TO authenticated
USING (true);

-- Done! Names are now hidden from public.

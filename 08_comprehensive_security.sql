-- ============================================
-- STRICT ACCESS CONTROL
-- Whitelist specific emails only
-- ============================================

-- 1. Enable RLS (just in case)
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- 2. Drop old policies
DROP POLICY IF EXISTS "Anyone can submit surveys" ON surveyresponses;
DROP POLICY IF EXISTS "Only admins can view data" ON surveyresponses;
DROP POLICY IF EXISTS "Only specific admins can view" ON surveyresponses;

-- POLICY 1: Public can submit (No change)
CREATE POLICY "Anyone can submit surveys" ON surveyresponses
FOR INSERT TO public
WITH CHECK (true);

-- POLICY 2: STRICT WHITELIST for Admins
-- Only these specific emails can see data
CREATE POLICY "Only specific admins can view" ON surveyresponses
FOR SELECT TO authenticated
USING (
  lower(auth.email()) IN (
    'tiffany@empowermentfarm.org',
    'ashleigh@empowermentfarm.org',
    'adilzaben@gmail.com'
  )
);

-- ============================================
-- OPTIONAL: Lock down other tables too
-- ============================================
-- If you want to restrict audit logs too:
-- ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Admins only audit" ON audit_log FOR SELECT TO authenticated 
-- USING (lower(auth.email()) IN ('tiffany@empowermentfarm.org', 'ashleigh@empowermentfarm.org', 'adilzaben@gmail.com'));

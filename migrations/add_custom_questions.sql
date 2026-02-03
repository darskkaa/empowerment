-- ============================================================================
-- DYNAMIC SURVEY QUESTIONS MIGRATION
-- Run this SQL in your Supabase SQL Editor to enable custom questions
-- ============================================================================

-- 1. Create custom_questions table
CREATE TABLE IF NOT EXISTS custom_questions (
    question_id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text  VARCHAR(300) NOT NULL,
    emoji          VARCHAR(10) DEFAULT '✨',
    display_order  INT DEFAULT 0,
    is_active      BOOLEAN DEFAULT TRUE,
    created_by     UUID,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE custom_questions IS 'Client-defined survey questions manageable from dashboard';

-- 2. RLS for custom_questions
ALTER TABLE custom_questions ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view active questions (for survey form)
DROP POLICY IF EXISTS "Anyone can view active questions" ON custom_questions;
CREATE POLICY "Anyone can view active questions" ON custom_questions 
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);

-- Policy: Authenticated users can manage questions (for dashboard)
DROP POLICY IF EXISTS "Authenticated can manage questions" ON custom_questions;
CREATE POLICY "Authenticated can manage questions" ON custom_questions 
    FOR ALL TO authenticated USING (true);

-- 3. Grant permissions
GRANT SELECT ON custom_questions TO anon, authenticated;
GRANT ALL ON custom_questions TO authenticated;

-- 4. Add custom_responses JSONB column to surveyresponses
ALTER TABLE surveyresponses ADD COLUMN IF NOT EXISTS custom_responses JSONB DEFAULT '{}'::jsonb;
COMMENT ON COLUMN surveyresponses.custom_responses IS 'Stores responses to custom questions as {question_uuid: score(1-3)}';

-- 5. Create index for performance
CREATE INDEX IF NOT EXISTS idx_custom_questions_active ON custom_questions(is_active, display_order);

-- ============================================================================
-- ✅ DONE! Now you can add questions from the dashboard.
-- ============================================================================

-- ============================================================================
-- TEAM-7-DDL ALIGNMENT MIGRATION
-- Run this only if your database was created from Team-7-DDL.sql and you need
-- to align with schema.sql (e.g. custom_responses as JSONB, custom_questions UUID).
-- If you used schema.sql from the start, you do not need this.
-- ============================================================================

-- 1. surveyresponses.custom_responses: ensure JSONB
-- If the column exists as varchar(1000), migrate to JSONB. If it doesn't exist, add it.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'surveyresponses' AND column_name = 'custom_responses'
    ) THEN
        -- Column exists: alter type to JSONB (safe for empty or valid JSON strings)
        BEGIN
            ALTER TABLE surveyresponses
                ALTER COLUMN custom_responses TYPE JSONB
                USING (CASE
                    WHEN custom_responses IS NULL OR trim(custom_responses) = '' THEN '{}'::jsonb
                    ELSE custom_responses::jsonb
                END);
        EXCEPTION WHEN OTHERS THEN
            -- If alter fails (e.g. invalid data), add new column and copy what we can
            ALTER TABLE surveyresponses ADD COLUMN IF NOT EXISTS custom_responses_jsonb JSONB DEFAULT '{}'::jsonb;
            UPDATE surveyresponses SET custom_responses_jsonb = COALESCE(custom_responses::jsonb, '{}'::jsonb)
                WHERE custom_responses IS NOT NULL AND custom_responses <> '';
            ALTER TABLE surveyresponses DROP COLUMN IF EXISTS custom_responses;
            ALTER TABLE surveyresponses RENAME COLUMN custom_responses_jsonb TO custom_responses;
        END;
    ELSE
        ALTER TABLE surveyresponses ADD COLUMN IF NOT EXISTS custom_responses JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

COMMENT ON COLUMN surveyresponses.custom_responses IS 'Stores responses to custom questions as {question_uuid: score(1-3)}';

-- 2. custom_questions.question_id: ensure UUID if currently varchar
-- Only run if custom_questions exists and question_id is not already uuid.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'custom_questions') THEN
        IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = 'custom_questions' AND column_name = 'question_id'
                AND data_type = 'character varying'
        ) THEN
            ALTER TABLE custom_questions
                ALTER COLUMN question_id TYPE UUID USING question_id::uuid;
        END IF;
    END IF;
END $$;

-- 3. Index for custom questions (if not exists)
CREATE INDEX IF NOT EXISTS idx_custom_questions_active ON custom_questions(is_active, display_order);

-- ============================================================================
-- Done. Your DB is aligned with schema.sql for custom_questions and custom_responses.
-- ============================================================================

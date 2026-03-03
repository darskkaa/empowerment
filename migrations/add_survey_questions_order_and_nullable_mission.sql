-- ============================================================================
-- UNIFIED SURVEY QUESTION ORDER + TRUE SKIP (NULL) FOR MISSION QUESTIONS
-- Run in Supabase SQL Editor (or as migration).
-- ============================================================================

-- 1) Allow NULL mission scores so "Skip" is truly skipped
ALTER TABLE IF EXISTS surveyresponses
    ALTER COLUMN is_present_engaged DROP NOT NULL,
    ALTER COLUMN connection_others_score DROP NOT NULL,
    ALTER COLUMN connection_nature_score DROP NOT NULL,
    ALTER COLUMN calmness_score DROP NOT NULL,
    ALTER COLUMN learning_intent_score DROP NOT NULL,
    ALTER COLUMN community_benefit_score DROP NOT NULL;

-- 2) Unified ordering for core + custom questions (combined / interleavable)
CREATE TABLE IF NOT EXISTS survey_questions_order (
    order_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_type TEXT NOT NULL CHECK (question_type IN ('core', 'custom')),
    core_id       UUID REFERENCES core_questions_config(core_id) ON DELETE CASCADE,
    question_id   UUID REFERENCES custom_questions(question_id) ON DELETE CASCADE,
    display_order INT NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT survey_questions_order_one_ref_chk CHECK (
        (question_type = 'core' AND core_id IS NOT NULL AND question_id IS NULL)
        OR
        (question_type = 'custom' AND question_id IS NOT NULL AND core_id IS NULL)
    )
);

COMMENT ON TABLE survey_questions_order IS 'Unified, interleavable order for survey questions (core + custom). Dashboard manages; public survey reads active order.';

-- Indexes / uniqueness for active order
CREATE INDEX IF NOT EXISTS idx_survey_questions_order_active_order ON survey_questions_order(is_active, display_order);
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_display_order
    ON survey_questions_order(display_order)
    WHERE is_active = TRUE;
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_core
    ON survey_questions_order(core_id)
    WHERE is_active = TRUE AND question_type = 'core';
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_custom
    ON survey_questions_order(question_id)
    WHERE is_active = TRUE AND question_type = 'custom';

-- RLS
ALTER TABLE survey_questions_order ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active survey question order" ON survey_questions_order;
CREATE POLICY "Anyone can view active survey question order" ON survey_questions_order
    FOR SELECT TO anon, authenticated
    USING (is_active = TRUE);

DROP POLICY IF EXISTS "Authenticated can manage survey question order" ON survey_questions_order;
CREATE POLICY "Authenticated can manage survey question order" ON survey_questions_order
    FOR ALL TO authenticated
    USING (true);

GRANT SELECT ON survey_questions_order TO anon, authenticated;
GRANT ALL ON survey_questions_order TO authenticated;

-- Seed order (idempotent): core (active, by core display_order) then custom (active, by custom display_order)
INSERT INTO survey_questions_order (question_type, core_id, question_id, display_order, is_active)
SELECT * FROM (
    WITH core AS (
        SELECT
            core_id,
            ROW_NUMBER() OVER (ORDER BY display_order, created_at) - 1 AS ord
        FROM core_questions_config
        WHERE is_active = TRUE
    ),
    core_count AS (
        SELECT COUNT(*)::INT AS n FROM core
    ),
    custom AS (
        SELECT
            question_id,
            ROW_NUMBER() OVER (ORDER BY display_order, created_at) - 1 AS ord
        FROM custom_questions
        WHERE is_active = TRUE
    )
    SELECT
        'core'::TEXT AS question_type,
        core.core_id AS core_id,
        NULL::UUID AS question_id,
        core.ord::INT AS display_order,
        TRUE AS is_active
    FROM core
    UNION ALL
    SELECT
        'custom'::TEXT AS question_type,
        NULL::UUID AS core_id,
        custom.question_id AS question_id,
        (custom.ord + (SELECT n FROM core_count))::INT AS display_order,
        TRUE AS is_active
    FROM custom
) seeded
WHERE NOT EXISTS (SELECT 1 FROM survey_questions_order);


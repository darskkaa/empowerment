-- ============================================================================
-- CORE QUESTIONS CONFIG (reorder, remove, edit text for mission block)
-- Run in Supabase SQL Editor. No change to surveyresponses columns.
-- ============================================================================

-- 1. Create core_questions_config table
CREATE TABLE IF NOT EXISTS core_questions_config (
    core_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code            TEXT NOT NULL UNIQUE,
    default_text    TEXT NOT NULL,
    current_text    TEXT,
    emoji           VARCHAR(10) DEFAULT '✨',
    display_order   INT DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE core_questions_config IS 'Configurable text and order for core mission questions; code maps to surveyresponses columns';

-- 2. RLS
ALTER TABLE core_questions_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active core questions" ON core_questions_config;
CREATE POLICY "Anyone can view active core questions" ON core_questions_config
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);

DROP POLICY IF EXISTS "Authenticated can manage core questions" ON core_questions_config;
CREATE POLICY "Authenticated can manage core questions" ON core_questions_config
    FOR ALL TO authenticated USING (true);

-- 3. Grants
GRANT SELECT ON core_questions_config TO anon, authenticated;
GRANT ALL ON core_questions_config TO authenticated;

-- 4. Index for ordering
CREATE INDEX IF NOT EXISTS idx_core_questions_config_active_order ON core_questions_config(is_active, display_order);

-- 5. Seed: one row per core mission question (code = key in survey data; maps to surveyresponses column in app)
INSERT INTO core_questions_config (code, default_text, current_text, emoji, display_order, is_active) VALUES
    ('present_engaged', 'Did you feel present and engaged?', NULL, '✨', 0, TRUE),
    ('connection_others', 'Feel more connected to others?', NULL, '👥', 1, TRUE),
    ('connection_nature', 'Feel more connected to nature?', NULL, '🌿', 2, TRUE),
    ('calmness', 'Feel calmer or more grounded?', NULL, '🧘', 3, TRUE),
    ('learning_intent', 'Will you use what you learned?', NULL, '🧠', 4, TRUE),
    ('community_benefit', 'Should we have more of this?', NULL, '🏛️', 5, TRUE)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- Done. Dashboard and survey will use this table for core question text and order.
-- ============================================================================

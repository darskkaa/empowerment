-- ============================================================================
-- MIGRATION: ADD RETURNING VISITOR FLAG
-- ============================================================================
-- Purpose: Explicitly track if a visitor has been to the farm before.
-- This replaces implicit tracking by email, which is unreliable for anon users.
-- ============================================================================

ALTER TABLE surveyresponses 
ADD COLUMN IF NOT EXISTS is_returning_visitor BOOLEAN DEFAULT FALSE;

-- Comment for documentation
COMMENT ON COLUMN surveyresponses.is_returning_visitor IS 'True if the user self-identifies as a returning visitor';

-- Update RLS if necessary (usually not needed for new columns if policy is on table)
-- But ensuring public can insert:
GRANT INSERT ON surveyresponses TO anon, authenticated;

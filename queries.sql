-- ============================================================================
-- EMPOWERMENT FARM - BUSINESS INTELLIGENCE QUERIES (AUDIT-ALIGNED)
-- ============================================================================
-- 10 Complex SQL queries matching JotForm survey structure
-- Scale: 3=Yes, 2=Somewhat, 1=No
-- ============================================================================

-- ============================================================================
-- QUERY 1: Correlation Analysis - People Connection vs Nature Connection
-- ============================================================================
-- Purpose: Do experiences with animals/nature help people connect with people?
-- Insight: High nature scores correlating with high people scores proves mission
-- ============================================================================
SELECT 
    experience_type,
    COUNT(*) AS responses,
    ROUND(AVG(connection_nature_score), 2) AS avg_nature_connection,
    ROUND(AVG(connection_others_score), 2) AS avg_people_connection,
    ROUND(AVG(connection_nature_score), 2) - ROUND(AVG(connection_others_score), 2) AS nature_vs_people_gap,
    CASE 
        WHEN AVG(connection_nature_score) > 2.5 AND AVG(connection_others_score) > 2.5 
        THEN 'High Both - Mission Success!'
        WHEN AVG(connection_nature_score) > 2.5 
        THEN 'Nature Strong, People Needs Work'
        ELSE 'Focus Area'
    END AS correlation_insight
FROM surveyresponses
GROUP BY experience_type
HAVING COUNT(*) >= 2
ORDER BY avg_nature_connection DESC;

-- ============================================================================
-- QUERY 2: Marketing Attribution
-- ============================================================================
-- Purpose: Which referral sources drive the most participants?
-- Use Case: Marketing budget allocation, partnership prioritization
-- ============================================================================
SELECT 
    referral_source,
    COUNT(*) AS total_responses,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM surveyresponses) * 100, 1) AS percentage,
    ROUND(AVG(calmness_score), 2) AS avg_calmness,
    ROUND(AVG(
        (is_present_engaged + connection_others_score + connection_nature_score + calmness_score)::NUMERIC / 4
    ), 2) AS avg_impact_score,
    COUNT(CASE WHEN would_recommend = TRUE THEN 1 END) AS would_recommend_count
FROM surveyresponses
WHERE referral_source IS NOT NULL AND referral_source != ''
GROUP BY referral_source
ORDER BY total_responses DESC;

-- ============================================================================
-- QUERY 3: Demographics - Age Range Distribution
-- ============================================================================
-- Purpose: Which age groups are we reaching?
-- Audit: Uses age_range_bracket from SurveyResponses (supports anonymous users)
-- ============================================================================
SELECT 
    age_range_bracket,
    COUNT(*) AS participant_count,
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM surveyresponses) * 100, 1) AS percentage,
    ROUND(AVG(calmness_score), 2) AS avg_calmness,
    ROUND(AVG(connection_nature_score), 2) AS avg_nature_connection,
    COUNT(CASE WHEN learning_intent_score = 3 THEN 1 END) AS will_apply_learnings,
    COUNT(photo_url) AS photos_submitted
FROM surveyresponses
GROUP BY age_range_bracket
ORDER BY 
    CASE age_range_bracket 
        WHEN '0-17' THEN 1 
        WHEN '18-25' THEN 2 
        WHEN '26-40' THEN 3 
        WHEN '41-60' THEN 4 
        WHEN '61+' THEN 5 
    END;

-- ============================================================================
-- QUERY 4: Visual Impact Report - Responses with Photos
-- ============================================================================
-- Purpose: Showcase "moments" participants captured for grants/marketing
-- ============================================================================
SELECT 
    experience_type,
    participant_name,
    age_range_bracket,
    standout_moment,
    calmness_score,
    connection_nature_score,
    photo_url,
    submitted_at::DATE AS visit_date
FROM surveyresponses
WHERE photo_url IS NOT NULL
ORDER BY submitted_at DESC;

-- ============================================================================
-- QUERY 5: Intentionality - Learning Application Rate
-- ============================================================================
-- Purpose: What % answered "Yes" to "Will you use something you learned?"
-- ============================================================================
SELECT 
    experience_type,
    COUNT(*) AS total_responses,
    COUNT(CASE WHEN learning_intent_score = 3 THEN 1 END) AS yes_count,
    COUNT(CASE WHEN learning_intent_score = 2 THEN 1 END) AS somewhat_count,
    COUNT(CASE WHEN learning_intent_score = 1 THEN 1 END) AS no_count,
    ROUND(
        COUNT(CASE WHEN learning_intent_score = 3 THEN 1 END)::NUMERIC / COUNT(*) * 100, 1
    ) AS yes_percentage,
    ROUND(
        COUNT(CASE WHEN learning_intent_score >= 2 THEN 1 END)::NUMERIC / COUNT(*) * 100, 1
    ) AS positive_percentage
FROM surveyresponses
GROUP BY experience_type
ORDER BY yes_percentage DESC;

-- ============================================================================
-- QUERY 6: Program Effectiveness - "The Zen Factor"
-- ============================================================================
-- Purpose: Which programs yield the highest calmness scores?
-- Board Question: Where should we invest more resources?
-- ============================================================================
SELECT 
    experience_type,
    COUNT(*) AS responses,
    ROUND(AVG(calmness_score), 2) AS avg_calmness,
    ROUND(AVG(is_present_engaged), 2) AS avg_presence,
    ROUND(AVG(community_benefit_score), 2) AS perceived_community_value,
    -- Compute overall impact score
    ROUND(AVG(
        (is_present_engaged + connection_others_score + connection_nature_score + calmness_score)::NUMERIC / 4
    ), 2) AS impact_score,
    RANK() OVER (ORDER BY AVG(calmness_score) DESC) AS calmness_rank
FROM surveyresponses
GROUP BY experience_type
HAVING COUNT(*) >= 2
ORDER BY avg_calmness DESC;

-- ============================================================================
-- QUERY 7: Monthly Trend Analysis (Window Functions)
-- ============================================================================
-- Purpose: How are scores trending over time?
-- Insight: Shows growth trajectory for grant reporting
-- ============================================================================
SELECT 
    TO_CHAR(submitted_at, 'YYYY-MM') AS month,
    COUNT(*) AS responses,
    ROUND(AVG(calmness_score), 2) AS avg_calmness,
    ROUND(AVG(connection_nature_score), 2) AS avg_nature,
    ROUND(AVG(connection_others_score), 2) AS avg_people,
    -- Month-over-month change
    ROUND(AVG(calmness_score), 2) - LAG(ROUND(AVG(calmness_score), 2)) 
        OVER (ORDER BY TO_CHAR(submitted_at, 'YYYY-MM')) AS calmness_change,
    COUNT(photo_url) AS photos_captured,
    COUNT(CASE WHEN would_recommend = TRUE THEN 1 END) AS would_recommend
FROM surveyresponses
GROUP BY TO_CHAR(submitted_at, 'YYYY-MM')
ORDER BY month;

-- ============================================================================
-- QUERY 8: Recurring Participant Progress
-- ============================================================================
-- Purpose: Track improvement for participants with multiple visits
-- Evidence: Proves long-term therapeutic impact
-- ============================================================================
SELECT 
    participant_name,
    COUNT(*) AS visit_count,
    MIN(submitted_at)::DATE AS first_visit,
    MAX(submitted_at)::DATE AS last_visit,
    -- First vs Last visit scores (using window functions)
    ROUND(AVG(connection_nature_score), 2) AS avg_nature_score,
    MIN(connection_nature_score) AS first_nature_score,
    MAX(connection_nature_score) AS latest_nature_score,
    MAX(connection_nature_score) - MIN(connection_nature_score) AS improvement,
    CASE 
        WHEN MAX(connection_nature_score) > MIN(connection_nature_score) THEN '📈 Improving'
        WHEN MAX(connection_nature_score) = MIN(connection_nature_score) THEN '➡️ Stable'
        ELSE '📉 Needs Attention'
    END AS trend
FROM surveyresponses
WHERE participant_name IS NOT NULL
GROUP BY participant_name
HAVING COUNT(*) >= 2
ORDER BY improvement DESC, visit_count DESC;

-- ============================================================================
-- QUERY 9: Community Benefit Perception
-- ============================================================================
-- Purpose: Do participants believe community would benefit from more programs?
-- Use Case: Grant applications, expansion justification
-- ============================================================================
SELECT 
    experience_type,
    COUNT(*) AS responses,
    ROUND(AVG(community_benefit_score), 2) AS avg_community_benefit,
    COUNT(CASE WHEN community_benefit_score = 3 THEN 1 END) AS believe_yes,
    COUNT(CASE WHEN community_benefit_score = 2 THEN 1 END) AS believe_somewhat,
    COUNT(CASE WHEN community_benefit_score = 1 THEN 1 END) AS believe_no,
    ROUND(
        COUNT(CASE WHEN community_benefit_score = 3 THEN 1 END)::NUMERIC / COUNT(*) * 100, 1
    ) AS strong_advocate_pct
FROM surveyresponses
GROUP BY experience_type
ORDER BY avg_community_benefit DESC;

-- ============================================================================
-- QUERY 10: Recommendation Rate & Standout Moments
-- ============================================================================
-- Purpose: NPS-style analysis + qualitative feedback extraction
-- ============================================================================
SELECT 
    experience_type,
    COUNT(*) AS responses,
    COUNT(CASE WHEN would_recommend = TRUE THEN 1 END) AS would_recommend,
    ROUND(
        COUNT(CASE WHEN would_recommend = TRUE THEN 1 END)::NUMERIC / COUNT(*) * 100, 1
    ) AS recommend_rate,
    COUNT(standout_moment) AS has_standout_moment,
    -- Sample standout moments for each program
    (SELECT standout_moment 
     FROM surveyresponses sr2 
     WHERE sr2.experience_type = SurveyResponses.experience_type 
       AND sr2.standout_moment IS NOT NULL 
     LIMIT 1) AS sample_moment
FROM surveyresponses
GROUP BY experience_type
ORDER BY recommend_rate DESC, responses DESC;

-- ============================================================================
-- BONUS: Impact Score Dashboard View
-- ============================================================================
-- Purpose: Single view for Board of Directors dashboard
-- ============================================================================
CREATE OR REPLACE VIEW vw_impact_dashboard AS
SELECT 
    experience_type,
    COUNT(*) AS total_surveys,
    ROUND(AVG(is_present_engaged), 2) AS presence_score,
    ROUND(AVG(connection_others_score), 2) AS people_score,
    ROUND(AVG(connection_nature_score), 2) AS nature_score,
    ROUND(AVG(calmness_score), 2) AS calm_score,
    ROUND(AVG(learning_intent_score), 2) AS intent_score,
    ROUND(AVG(community_benefit_score), 2) AS community_score,
    -- Overall Impact Score (0-3 scale)
    ROUND(AVG(
        (is_present_engaged + connection_others_score + connection_nature_score + 
         calmness_score + learning_intent_score + community_benefit_score)::NUMERIC / 6
    ), 2) AS overall_impact,
    ROUND(
        COUNT(CASE WHEN would_recommend = TRUE THEN 1 END)::NUMERIC / COUNT(*) * 100, 1
    ) AS recommend_pct
FROM surveyresponses
GROUP BY experience_type;

-- ============================================================================
-- END OF BUSINESS QUERIES
-- ============================================================================

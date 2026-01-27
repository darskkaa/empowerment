# Empowerment Farm - Data Dictionary (Audit-Compliant)

> **Mission:** "Labels Stop at the Gate" – Track therapeutic outcomes without requiring diagnostic labels.  
> **Audit:** Schema maps 1:1 to JotForm survey questions using Yes(3)/Somewhat(2)/No(1) scale.

---

## Schema Overview

## Schema Overview

| Table | Purpose | Access Level |
|-------|---------|--------------|
| `programcatalog` | Actual programs from website (Cow Yoga, Tuesday Tuck-In, etc.) | Public |
| `farmzones` | Physical farm areas (Barnyard, Pollinator Garden, etc.) | Public |
| `animals` | Therapy animal registry | Public |
| `constituents` | Basic participant identity (no sensitive data) | Public |
| `constituentprofiles` | 🔒 Sensitive PII for grant reporting | Restricted |
| `experiences` | Session attendance records | Staff |
| `surveyresponses` | **Single Source of Truth** for all survey feedback | Staff |
| `audit_log` | Database change tracking | Admin |

> [!NOTE]
> **Streamlined Architecture:** The `survey_v2` table has been deprecated. All data now flows into `surveyresponses`.

---

## Table: `surveyresponses` (JotForm-Aligned)

> [!IMPORTANT]
> **Audit Compliance:** Every column maps directly to a JotForm question.  
> **Scale:** `3 = Yes`, `2 = Somewhat`, `1 = No`

| Column | Type | Nullable | JotForm Question |
|--------|------|----------|------------------|
| `response_id` | UUID | NO | Auto-generated |
| `experience_id` | UUID | YES | FK to Experiences (optional) |
| `constituent_id` | UUID | YES | FK to Constituents (optional) |
| `experience_type` | VARCHAR(150) | NO | Q1: "What was your most recent experience?" |
| `is_present_engaged` | INT (1-3) | NO | Q2a: "Did you feel present and engaged?" |
| `connection_others_score` | INT (1-3) | NO | Q2b: "Feel more connected to others?" |
| `connection_nature_score` | INT (1-3) | NO | Q2c: "Feel more connected to nature/animals?" |
| `calmness_score` | INT (1-3) | NO | Q2d: "Feel calmer or less stressed?" |
| `learning_intent_score` | INT (1-3) | NO | Q2e: "Will you use something learned?" |
| `community_benefit_score` | INT (1-3) | NO | Q2f: "Community would benefit from more?" |
| `referral_source` | TEXT | YES | Q4: "How did you hear about us?" |
| `standout_moment` | TEXT | YES | Q8: "One moment that stood out?" |
| `would_recommend` | BOOLEAN | NO | Q9: "Would you recommend us?" |
| `additional_feedback` | TEXT | YES | Q10: Additional feedback |
| `age_range_bracket` | VARCHAR(20) | NO | "Age Range" (required for demographics) |
| `participant_name` | VARCHAR(200) | YES | "Name (Optional)" |
| `participant_email` | VARCHAR(255) | YES | "E-mail (Optional)" |
| `photo_url` | TEXT | YES | Optional photo upload |
| `willing_to_review` | BOOLEAN | NO | "Willing to leave Google review?" |
| `submitted_at` | TIMESTAMPTZ | NO | Auto-timestamp |

---

## Why `age_range_bracket` Exists in TWO Tables

> [!NOTE]
> **Audit Design Decision:** Age range appears in both `surveyresponses` AND `constituentprofiles` for different purposes.

| Location | Purpose | Use Case |
|----------|---------|----------|
| `surveyresponses.age_range_bracket` | **Anonymous Demographics** | Walk-in visitors who complete survey without creating account. Essential for grant reporting on one-time participants. |
| `constituentprofiles.age_range` | **Known User Demographics** | Registered constituents with profiles. Used for longitudinal tracking of known participants. |

This dual-storage approach ensures:
1. **100% demographic coverage** even for anonymous walk-ins
2. **Privacy compliance** – no account required for survey
3. **Grant reporting accuracy** – can report on ALL participants

---

## Table: `programcatalog`

| Column | Type | Description |
|--------|------|-------------|
| `program_id` | UUID | Primary key |
| `program_name` | VARCHAR(150) | Actual program name from website |
| `program_category` | VARCHAR(100) | Category (Yoga, Workshop, Group, etc.) |
| `description` | TEXT | Program description |
| `schedule_notes` | VARCHAR(255) | When it typically runs |
| `cost_notes` | VARCHAR(100) | Pricing information |
| `is_active` | BOOLEAN | Currently offered? |

**Pre-populated Programs:**
- Open Farm (Second Saturdays)
- Cow Yoga
- Yoga with the Animals
- Tuesday Night Tuck-In
- Paint & Pollinators
- Seedlings for Spring
- JusTeenys Greenies
- Educational Field Trips
- Group & Partner Programs

---

## Table: `constituentprofiles` (🔒 Restricted)

> [!CAUTION]
> This table requires elevated permissions. Supports "Labels Stop at the Gate" by separating sensitive data from daily operations.

| Column | Type | Description |
|--------|------|-------------|
| `profile_id` | UUID | Primary key |
| `constituent_id` | UUID | FK to Constituents |
| `date_of_birth` | DATE | Full DOB for known users |
| `age_range` | VARCHAR(20) | Age bracket for grant reporting |
| `emergency_contact` | VARCHAR(255) | Emergency contact name |
| `emergency_phone` | VARCHAR(20) | Emergency phone |
| `referral_source` | VARCHAR(255) | Who referred them |
| `notes` | TEXT | Private notes |

---

## Security: Row Level Security (RLS)

```sql
-- Public can INSERT surveys (anonymous submissions allowed)
CREATE POLICY "Allow public survey submissions" ON surveyresponses
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Only authenticated staff can VIEW responses
CREATE POLICY "Only authenticated can view surveys" ON surveyresponses
    FOR SELECT TO authenticated
    USING (true);
```

---

## ERD Reference

See [ERD.mermaid](file:///d:/DownloadsD/EMPOWEREMNET_FARM_DB/ERD.mermaid) for visual diagram.

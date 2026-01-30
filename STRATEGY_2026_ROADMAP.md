# Empowerment Farm: Digital Impact & Reporting Strategy (2026 Roadmap)

**Prepared For:** Empowerment Farm Leadership & Board of Directors  
**Date:** January 29, 2026  
**Subject:** Upgrading Data Infrastructure for Grant Compliance & Operational Clarity

---

## 1. Executive Summary

**The Philosophy:** Empowerment Farm was built on the premise that **"Labels Stop at the Gate."** We provide therapeutic outcomes—resilience, connection, and calm—without requiring participants to carry the burden of a clinical diagnosis.

**The Challenge:** While our therapeutic model avoids labels, our funding model requires proof. Grantors (e.g., Naples Garden Club, Leadership Collier) require rigorous, audit-compliant data to justify continued support.

**The Solution:** This document outlines the **"Audit-Ready Dashboard,"** a digital upgrade that transforms anecdotal success into quantitative evidence. By leveraging our existing Supabase architecture, we will visualize the link between farm activities (e.g., Cow Yoga, Tuesday Tuck-In) and human outcomes (Stress Reduction, Community Connection).

---

## 2. Strategic Alignment: From "Feel Good" to "Proven Good"

We are moving from **Phase 1 (Startup/Dream)** to **Phase 2 (Institution/Scale)**. To support the Capital Campaign and future expansion (e.g., the Equine Education Center), our data must answer three core questions for donors:

1. **Who are we serving?** (Demographics without intrusion)
2. **Does it work?** (Evidence of stress reduction/engagement)
3. **Is it efficient?** (Program-level ROI)

### The "Labels Stop at the Gate" Data Policy

| We DO Track | We DO NOT Track |
|-------------|-----------------|
| Experience | HIPAA-sensitive diagnoses |
| Emotion | Medication history |
| Engagement | Clinical labels |
| Growth | |

**Result:** A dataset that is **100% safe** for public grant reporting and **0% invasive** to our families.

---

## 3. Dashboard Specification: The "Impact Center"

The new dashboard (`dashboard.html`) will be restructured into three specific views to serve different stakeholders.

### View A: The "Tiffany" View (Operational Pulse)
*Designed for the Executive Director to check daily.*

| Metric | Description |
|--------|-------------|
| **Real-Time Engagement** | Total Headcount (Rolling 30 Days). Breakdown: Walk-ins (Open Farm) vs. Registered Programs (Tuck-In). |
| **The "Yoda" Index** | Which farm zones are seeing the most traffic? (e.g., "Pollinator Garden" vs. "Barnyard"). Helps staff rotate animals or prep zones before heavy traffic days. |
| **NPS (Net Promoter Score)** | % of `would_recommend = TRUE`. Goal: Maintain >95%. |

### View B: The "Grant Winner" View (Outcome Evidence)
*Designed for Grant Writers and Board Reports.*

| Metric | Description |
|--------|-------------|
| **Therapeutic Outcomes Matrix** | Heatmap visualizing: "Which programs drive which feelings?" Example: "Cow Yoga drives Calmness (98%), while Tuesday Tuck-In drives Social Connection (92%)." |
| **Longitudinal Impact ("The Regulars")** | Filters data to show outcomes for participants who have attended >3 sessions. Proves we are building long-term resilience, not just one-off entertainment. |
| **Demographic Reach (Anonymous)** | Pie charts showing Age Brackets. Critical for county grants targeting specific vulnerable populations (Youth Mental Health, Senior Isolation). |

### View C: The "Wall of Love" (Qualitative Data)
*Designed for Social Media & Donor Newsletters.*

| Metric | Description |
|--------|-------------|
| **The "Standout Moment" Feed** | A scrolling feed of text responses from the survey question: "One moment that stood out?" Auto-tagged by Program (e.g., #JusTeenysGreenies). |
| **Usage** | Instant content for newsletters and "Thank You" cards to donors. |

---

## 4. Data Dictionary & Audit Compliance

To ensure we pass any external audit, the system enforces the following schema rules:

### 1. The "Single Source of Truth" Rule
- All feedback flows into the `surveyresponses` table.
- **Audit Trail:** Every record has a UUID and a `submitted_at` timestamp. Records are never deleted, only "archived."

### 2. The 1-3 Therapeutic Scale
We standardize all emotional metrics on a simplified Likert scale:

| Score | Meaning |
|-------|---------|
| **3 (Yes)** | "I felt this strongly." |
| **2 (Somewhat)** | "I felt this a little." |
| **1 (No)** | "I did not feel this." |

### 3. Privacy by Design (RLS)
- **Row Level Security:** Staff can see aggregates and anonymous feedback.
- Only the Executive Director/Admin can unlock PII in `constituentprofiles`.

---

## 5. Technical Implementation Roadmap

**Current Stack:** Supabase (Backend) + Netlify (Hosting) + Vanilla JS (Frontend)  
**Status:** Robust, Low Cost, Maintenance Free.

### Q1 2026 Priorities
- [ ] **Migrate Historical Data:** Digitize paper surveys/spreadsheets into `surveyresponses`.
- [ ] **Deploy "Admin Dashboard v2":** Implement the Charts.js visualizations described above.
- [ ] **"Farms Without Fences" Integration:** Add location tag to track impact for off-site mobile programs.

### Q2 2026 Priorities
- [ ] **Automated PDF Reports:** "Generate Board Report" button for branded monthly summaries.
- [ ] **Donor Portal:** Simplified read-only view for major donors to see the "Impact Counter."

---

## Closing Thought

By upgrading this dashboard, Empowerment Farm isn't just "counting heads." We are **quantifying joy**, **measuring resilience**, and **proving connection**. This is the data that wins grants, but more importantly, it helps us serve our community better.

> **"Labels stop at the gate. Impact starts at the data."**

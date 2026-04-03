# HealthTrack Project — Claude Context Brief
## Paste this at the start of any new Claude chat to continue the project

---

## Who I am

I am Sagrika Mishra. I am currently:
- A marketing data science student building a portfolio for job applications (targeting marketing DS roles at companies like Spotify, Booking.com, Revolut, and eventually FAANG)
- A business consultant at Blackmont, advising two real clients on GTM strategy: Emm (UK femtech wearables, pre-launch) and Gononet (B2B SaaS retail ERP, UK market entry). I cannot share their confidential data.
- Applying for marketing data scientist and marketing analyst roles from Monday 30 March 2026

My existing GitHub projects (already built):
- sagrika-mishra/InfluencerMarketingAnalytics — PSM causal inference, RoBERTa NLP, SHAP, K-Means on YouTube creator data
- sagrika-mishra/Clickstream-Social-Media-Analysis — funnel analysis, attribution, revenue quantification (HaggisBus)
- sagrika-mishra/customer-retention-journey-analysis — Random Forest churn prediction, CRM strategy
- Group project (LLM): GPT-4o-mini fine-tuning on FinRED dataset, prompt engineering (CoT + few-shot), spaCy NER

---

## The project I am building right now

**Repo name:** healthtrack-subscription-intelligence
**GitHub:** github.com/sagrika-mishra/healthtrack-subscription-intelligence

**What it is:** An end-to-end marketing measurement pipeline for "HealthTrack" — a fictional UK DTC health subscription brand (inspired by real consulting work, built with public/real data). One project demonstrating every core marketing DS skill in a single coherent business story.

**The CMO's question:** Which channels actually drive subscriptions, where is revenue leaking in the funnel, and what should we do next quarter?

---

## Current setup status

- [x] GitHub repo created with folder structure
- [x] Google Cloud project created: healthtrack-analytics
- [x] BigQuery working — confirmed real GA4 query returns results
- [x] Python packages installed: pandas, numpy, scikit-learn, statsmodels, pytrends, praw, anthropic, google-cloud-bigquery
- [ ] Looker Studio connected to BigQuery
- [ ] Reddit API credentials set up
- [ ] Any notebook code written

**Next step when I left off:** Connect Looker Studio to BigQuery, then write NB1 code

---

## Data sources

| Source | What it is | Status |
|---|---|---|
| `bigquery-public-data.ga4_obfuscated_sample_ecommerce` | Real GA4 Google Merchandise Store data — sessions, events, user paths, channels | Working in BigQuery |
| Google Trends (pytrends) | Real weekly search volume — used as MMM channel activity signal | Package installed, not yet pulled |
| Reddit API (praw) | Real public posts from r/HealthTech, r/Supplements, r/Fitness | Package installed, not yet set up |
| Simulated spend data | numpy — weekly marketing spend across 5 channels. Clearly labelled as simulated. | Not yet generated |

---

## Five notebooks to build — in order

### NB1: 01_funnel_analysis_bigquery.ipynb
**Skills:** Advanced SQL (CTEs, window functions, unnesting), GA4 event schema, funnel analysis, CRO, Looker Studio dashboard
**Data:** BigQuery GA4 public dataset
**Key outputs:**
- Session reconstruction — user journey sequencing with window functions
- Funnel stages: session_start → view_item → add_to_cart → begin_checkout → purchase
- Drop-off rate + revenue impact per stage
- Channel performance: users, sessions, conversion rate by traffic_source.medium
- First-touch vs last-touch attribution comparison in SQL
- Looker Studio dashboard with 3 pages (funnel overview, channel performance, attribution)

### NB2: 02_attribution_modelling.ipynb
**Skills:** Marketing attribution, multi-touch, Markov chain data-driven attribution
**Data:** Session path data from NB1
**Key outputs:**
- Last-click (baseline), linear multi-touch, Markov chain data-driven attribution
- Channel credit comparison across all three models
- Budget implication of each model choice

### NB3: 03_causal_inference_incrementality.ipynb
**Skills:** Causal inference, synthetic control, geo incrementality, counterfactual analysis
**Data:** Simulated geo-level weekly subscription data (10 regions, 5 treatment / 5 control)
**Key outputs:**
- Synthetic control construction
- True incremental lift vs naive before/after
- Bias quantification in last-click measurement
- Directly mirrors Google's "counterfactual causal inference" and Meta's "synthetic control" JD language

### NB4: 04_mmm_and_ab_testing.ipynb
**Skills:** MMM, adstock modelling, Ridge regression, saturation curves, Bayesian A/B testing, sample size
**Data:** Real Google Trends + simulated spend (labelled) for MMM. Simulated experiment data for A/B.
**Key outputs:**
- Adstock transformation per channel
- Channel contribution decomposition
- Saturation curves
- Bayesian Beta-Binomial + frequentist chi-squared A/B test
- Sample size calculator, business impact in £ ARR

### NB5: 05_dark_funnel_claude_api.ipynb
**Skills:** NLP, sentiment analysis, dark funnel measurement, prompt engineering, Claude API, agentic AI
**Data:** Real Reddit posts (praw), real Google Trends, simulated survey attribution data
**Key outputs:**
- Reddit sentiment + topic analysis
- First-touch survey vs last-click attribution gap (dark funnel quantification)
- Claude API CMO weekly brief (budget recommendation, top CRO fix, next experiment, retention priorities)
- Applies FinRED prompt engineering skills (CoT + few-shot, output quality evaluation)

---

## Looker Studio dashboard spec

**Connection:** BigQuery custom SQL connector (NOT the GA4 connector — BigQuery gives raw event-level data)
**Three pages:**
1. Funnel overview — conversion rates and drop-off cost by stage
2. Channel performance — sessions, conversion rate, revenue by source/medium
3. Attribution comparison — channel credit under last-click vs first-touch

**When built:** Add the shareable link to README.md immediately

---

## Key ATS keywords this project covers

Marketing measurement: MMM, media mix modelling, adstock, channel ROI, attribution modelling, multi-touch attribution, dark funnel, incrementality, marketing spend optimisation

Analytics stack: GA4, BigQuery, advanced SQL, CTEs, window functions, Looker Studio, funnel analysis, CRO, conversion rate optimisation, session path analysis

Data science: A/B testing, Bayesian inference, causal inference, synthetic control, Ridge regression, NLP, sentiment analysis, customer segmentation

AI: Agentic AI, Claude API, prompt engineering, LLM integration, GenAI for marketing

---

## Resume context

**Target roles:** Marketing Data Scientist, Marketing Analytics DS, Measurement Scientist, Growth Data Scientist
**Target companies:** Spotify, Booking.com, Deliveroo, Revolut, Monzo, Wise, Sky, ITV, Unilever, P&G, L'Oreal — and eventually FAANG (Google, Meta)
**Applying from:** Monday 30 March 2026

**Blackmont consulting experience (on resume as work experience):**
- "Designed GTM analytics framework for a UK femtech wearables brand (pre-launch): waitlist intent scoring, dark funnel measurement strategy, audience segmentation"
- "Developed UK market entry analytics strategy for a B2B SaaS retail ERP (Middle East/US → UK): market sizing, ICP propensity model, channel mix recommendation"

---

## How to continue in a new chat

Paste this entire document at the start of a new Claude conversation and say what you need. For example:

- "I'm ready to connect Looker Studio — walk me through it"
- "Write the complete code for NB1"
- "I've finished NB1 — write NB2 code"
- "Help me set up the Reddit API"
- "Review my NB1 notebook and suggest improvements"

Claude will know exactly where you are and what to build next.

---

## Important constraints

- Do NOT use Emm or Gononet's actual data in this public repo (client confidentiality)
- All simulated data must be clearly labelled as simulated in notebooks and README
- Real data sources: GA4 public BigQuery dataset, pytrends, Reddit public posts only
- Credentials (.env file) must never be committed to GitHub
- Add .env to .gitignore immediately

---

## The one-paragraph interview pitch for this project

"I built an end-to-end marketing measurement pipeline called HealthTrack Subscription Intelligence using real GA4 data in BigQuery — advanced SQL for funnel reconstruction and channel attribution, three attribution models including Markov chain data-driven attribution, a geo-based incrementality study using synthetic control that directly mirrors Google and Meta's measurement methodology, a lightweight MMM using real Google Trends signals with adstock transformation, and a Bayesian A/B testing framework. The whole pipeline feeds into a Claude API brief generator that synthesises all four analytical layers into a CMO weekly recommendation. The GA4 and channel analysis is live in Looker Studio. Inspired by real consulting work on GTM strategy for a femtech wearables brand and a B2B SaaS company entering the UK market."
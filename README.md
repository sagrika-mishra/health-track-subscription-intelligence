# HealthTrack Subscription Intelligence

A marketing measurement system built on real GA4 data in BigQuery.

**Core question:** Which channels drive subscriptions and where is revenue leaking in the funnel?

This project starts with that question and answers it through funnel analysis and channel attribution — then extends into causal incrementality measurement, media mix modelling, and an AI-generated CMO brief.

> Built with real GA4 event data (Google BigQuery public dataset), real Google Trends signals, and real Reddit community data. Spend data is simulated and clearly labelled throughout. Inspired by real GTM consulting work at Blackmont.

---

## The business problem

HealthTrack is a UK DTC health subscription brand. At the end of Q1 2024, the CMO asks three questions the current reporting stack cannot answer.

**Where is revenue leaking in the funnel?**
Trial-to-subscription conversion is low enough that even a small improvement would materially affect ARR. But the dashboard shows overall conversion — not which funnel stage is responsible or where to intervene.

**Which channels actually deserve the budget?**
GA4 attributes most conversions to Google Ads on a last-click basis. But buyers typically research health products for weeks across communities, review sites, and organic content before clicking an ad. The question is whether the current budget allocation reflects real contribution or measurement bias.

**Did the paid social campaign generate lift beyond what would have happened anyway?**
Q1 spend on paid social increased and subscriptions rose. But correlation is not causation. Without a counterfactual, there is no way to know whether the campaign drove incremental subscriptions or simply captured demand that already existed.

This pipeline addresses all three through funnel analysis, attribution modelling, causal measurement, and budget optimisation — using a combination of real behavioural data, modelled scenarios, and clearly labelled simulations.

---

## Live dashboard

**[Looker Studio — HealthTrack Q1 Funnel & Channel Performance](LINK_TO_ADD)**

Connected to BigQuery via custom SQL. Shows Q1 funnel performance, channel breakdown, and first-touch vs last-touch attribution comparison.

---

## Analytical scope

This project covers Q1 2024 — one quarter of marketing activity for HealthTrack. The quarterly framing reflects how real marketing teams operate: measurement cycles, budget reviews, and campaign evaluations all happen at the quarter level.

The GA4 public dataset (`ga4_obfuscated_sample_ecommerce`) provides real session and event data as the behavioural foundation. Marketing spend, geo data, and survey responses are simulated at realistic quarterly levels and clearly labelled throughout.

---

## Project structure

Four layers. Each builds on the previous one.

```
Layer 1 — Core measurement (NB1 + NB2)
  Q1 funnel analysis and channel attribution.
  This is where the business question gets answered.

Layer 2 — Causal measurement (NB3)
  Geo incrementality testing with synthetic control.
  Estimates whether Q1 paid social generated incremental lift.

Layer 3 — Budget optimisation (NB4)
  Q1 media mix model and A/B testing framework.
  Estimates channel contribution and models next quarter spend.

Layer 4 — Intelligence layer (NB5)
  Dark funnel signal analysis and AI-generated Q2 brief.
  Surfaces what GA4 cannot capture and structures next steps.
```

---

## Notebooks

### NB1 — Q1 funnel analysis + BigQuery SQL
**`notebooks/01_funnel_analysis_bigquery.ipynb`**

The core notebook. Everything else builds on this.

**Business question:** Where in the Q1 trial funnel are users dropping off — and what is the estimated revenue impact of each drop-off?

**Skills:** Advanced SQL (CTEs, window functions, array unnesting), GA4 event schema, funnel analysis, conversion rate optimisation, Looker Studio

**Data:** Real — `bigquery-public-data.ga4_obfuscated_sample_ecommerce` (Google's public GA4 dataset)

**What it does:**
- Reconstructs individual user sessions from raw GA4 events using CTEs and window functions
- Classifies each session into funnel stages: `session_start → view_item → add_to_cart → begin_checkout → purchase`
- Calculates drop-off rate and estimated revenue impact at each stage
- Breaks down Q1 channel performance: users, sessions, conversion rate by `traffic_source.medium`
- Compares first-touch vs last-touch channel attribution directly in SQL
- Feeds a three-page Looker Studio live dashboard

**Key findings:** [Populated once built]

---

### NB2 — Q1 attribution modelling
**`notebooks/02_attribution_modelling.ipynb`**

**Business question:** Which channels deserve credit for Q1 conversions — and how does the answer change under different attribution models?

**Skills:** Multi-touch attribution, Markov chain data-driven attribution, channel credit analysis, budget implication modelling

**Data:** Session path data from NB1

**What it does:**
- Builds three attribution models on Q1 session paths: last-click (GA4 baseline), linear multi-touch, Markov chain data-driven
- Compares estimated channel credit across all three models side by side
- Quantifies the budget implication of each model choice for Q2 planning
- Shows where last-click systematically under-credits awareness channels

**Key findings:** [Populated once built]

---

### NB3 — Q1 causal inference + incrementality
**`notebooks/03_causal_inference_incrementality.ipynb`**

**Business question:** Did Q1 paid social generate incremental subscriptions beyond what would have happened anyway?

**Skills:** Causal inference, synthetic control, geo-based incrementality testing, counterfactual analysis, difference-in-differences

**Data:** Simulated Q1 geo-level weekly subscription data (10 regions, 5 treatment / 5 control) — clearly labelled as simulated

**What it does:**
- Designs a Q1 geo holdout incrementality test across 10 UK regions
- Constructs a synthetic control region as the counterfactual baseline
- Estimates incremental lift from paid social vs naive before/after comparison
- Quantifies the bias in observed ROAS and re-estimates ROAS using incremental lift rather than naive observed conversion

Directly mirrors what Google describes as "counterfactual causal inference studies" and what Meta describes as "synthetic control to measure marketing's global impact" in their marketing data scientist job descriptions.

**Key findings:** [Populated once built]

---

### NB4 — Q1 media mix model + A/B testing framework
**`notebooks/04_mmm_and_ab_testing.ipynb`**

**Business question:** What is the estimated channel contribution to Q1 subscriptions — and does the new onboarding flow improve trial-to-subscription conversion?

**Skills:** Media mix modelling, adstock transformation, Ridge regression, saturation curves, Bayesian inference, A/B testing, experimentation design, sample size calculation

**Data:**
- Real Google Trends weekly search volume (pytrends) as channel activity proxy
- Simulated Q1 weekly marketing spend across 5 channels (numpy) — clearly labelled
- Simulated A/B experiment data with realistic conversion rates

**What it does:**

*Q1 MMM:*
- Applies adstock transformation per channel — advertising effects carry over across weeks
- Fits Ridge regression to estimate channel contribution to Q1 subscriptions
- Plots saturation curves showing where each channel reaches diminishing returns
- Models Q2 budget reallocation scenarios based on Q1 estimated contribution

*A/B testing:*
- Runs frequentist chi-squared significance test on onboarding experiment
- Runs Bayesian Beta-Binomial posterior analysis
- Calculates minimum detectable effect and required sample size for Q2 experiments
- Estimates ARR impact at the observed conversion lift under both frequentist and Bayesian frameworks

**Key findings:** [Populated once built]

---

### NB5 — Dark funnel signals + Q2 CMO brief
**`notebooks/05_dark_funnel_claude_api.ipynb`**

**Business question:** What are potential customers saying in health communities that GA4 cannot capture — and what should the CMO prioritise entering Q2?

**Skills:** NLP, sentiment analysis, community signal analysis, dark funnel measurement, prompt engineering, Claude API

**Data:**
- Real Reddit posts: r/HealthTech, r/Supplements, r/Fitness — collected via Reddit API from public discussions
- Real Google Trends branded search volume as intent proxy
- Simulated Q1 survey attribution data ("how did you first hear about us?") — clearly labelled

**What it does:**
- Collects and analyses community sentiment on health subscription products from public Reddit discussions
- Identifies the top objections and unanswered questions that the Q1 funnel is not addressing
- Estimates the gap between last-click GA4 attribution and survey first-touch attribution — the dark funnel portion of Q1 acquisition
- Feeds Q1 outputs from all four layers into Claude API to generate a structured Q2 planning brief: estimated budget reallocation, top CRO priority, next experiment recommendation, and retention focus

The AI brief is the output layer of this project — it synthesises the measurement work into a format a CMO can act on. The measurement is the substance; the brief is the wrapper.

**Key findings:** [Populated once built]

---

## Data sources

| Data | Source | Real or simulated |
|---|---|---|
| GA4 sessions, events, user paths, channels | `bigquery-public-data.ga4_obfuscated_sample_ecommerce` | **Real** |
| Weekly search volume trends | Google Trends via pytrends | **Real** |
| Community discussions and sentiment | Reddit API — public subreddits | **Real** |
| Q1 weekly marketing spend by channel | numpy simulation | **Simulated — clearly labelled** |
| Q1 geo-level subscription data | numpy simulation | **Simulated — clearly labelled** |
| Q1 survey attribution responses | Simulation based on industry benchmarks | **Simulated — clearly labelled** |

---

## Tech stack

```
Data warehouse:    Google BigQuery
Dashboard:         Looker Studio (BigQuery custom SQL connector)
Channel signals:   Google Trends (pytrends)
Community data:    Reddit API (praw)
Modelling:         Python — pandas, numpy, statsmodels, scikit-learn
Causal inference:  Synthetic control, difference-in-differences
Attribution:       Markov chain, linear multi-touch, last-click
MMM:               Ridge regression with adstock transformation
A/B testing:       Bayesian Beta-Binomial + frequentist chi-squared
AI layer:          Claude API (Anthropic)
Environment:       VSCode, Jupyter, Google Cloud Platform
```

---

## Skills demonstrated

| Skill | Notebook | JD keyword |
|---|---|---|
| Advanced SQL — CTEs, window functions, unnesting | NB1 | BigQuery, SQL |
| GA4 event schema and funnel analysis | NB1 | Google Analytics 4, funnel optimisation |
| Live dashboard | NB1 | Looker Studio, data visualisation |
| Multi-touch and Markov chain attribution | NB2 | Attribution modelling |
| Synthetic control and geo incrementality | NB3 | Causal inference, measurement science |
| Adstock MMM and saturation curves | NB4 | Media mix modelling |
| Bayesian and frequentist A/B testing | NB4 | Experimentation, A/B testing |
| Community NLP and sentiment analysis | NB5 | Text analytics, sentiment |
| Claude API and prompt engineering | NB5 | GenAI, LLM integration |

---

## Repository structure

```
healthtrack-subscription-intelligence/
├── notebooks/
│   ├── 01_funnel_analysis_bigquery.ipynb
│   ├── 02_attribution_modelling.ipynb
│   ├── 03_causal_inference_incrementality.ipynb
│   ├── 04_mmm_and_ab_testing.ipynb
│   └── 05_dark_funnel_claude_api.ipynb
├── data/
│   ├── raw/
│   │   ├── google_trends.csv
│   │   └── reddit_posts.csv
│   └── processed/
├── outputs/
│   ├── figures/
│   └── q2_cmo_brief.md
├── src/
│   ├── bigquery_queries.sql
│   ├── attribution_models.py
│   ├── mmm_utils.py
│   └── ab_testing.py
├── .env.example
├── requirements.txt
└── README.md
```

---

## Setup

```bash
# Clone
git clone https://github.com/sagrika-mishra/healthtrack-subscription-intelligence
cd healthtrack-subscription-intelligence

# Install
pip install -r requirements.txt

# Environment
cp .env.example .env
# Add: REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, ANTHROPIC_API_KEY

# Authenticate Google Cloud
gcloud auth application-default login

# Run notebooks in order: 01 → 02 → 03 → 04 → 05
```

---

## About

Built as part of a marketing data science portfolio. Demonstrates end-to-end Q1 marketing measurement — from raw GA4 event data through attribution, causal inference, and media mix modelling to an AI-generated Q2 planning brief.

Inspired by real GTM strategy consulting work at Blackmont for clients in femtech wearables and B2B SaaS retail technology.

**Author:** Sagrika Mishra · [github.com/sagrika-mishra](https://github.com/sagrika-mishra)
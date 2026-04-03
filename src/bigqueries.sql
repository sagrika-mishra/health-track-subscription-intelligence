-- =============================================================
-- HealthTrack Subscription Intelligence
-- BigQuery Data Layer — All SQL Queries
-- Period: Q1 (Nov 2020 – Jan 2021)
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce
-- Tables are saved in: healthtrack-analytics.healthtrack_analytics
-- =============================================================


-- STEP 0: VERIFY RAW DATA EXISTS
-- Run this first to confirm the public dataset is accessible
-- =============================================================
SELECT
  event_name,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name IN (
    'session_start', 'view_item',
    'add_to_cart', 'begin_checkout', 'purchase'
  )
GROUP BY event_name
ORDER BY event_count DESC;

-- Expected results:
-- view_item       386,068
-- session_start   354,970
-- add_to_cart      58,543
-- begin_checkout   38,757
-- purchase          5,692


-- =============================================================
-- TABLE 1: q1_sessions
-- PURPOSE: Master session table. One row per session.
--          Flags which funnel stages each session reached.
--          Captures last-touch channel per session.
--          Every other table is built from this one.
--
-- =============================================================

CREATE OR REPLACE TABLE
  `healthtrack-analytics.healthtrack_analytics.q1_sessions`
AS

WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp,
    COALESCE(traffic_source.medium, '(none)') AS channel,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS session_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN (
      'session_start', 'view_item',
      'add_to_cart', 'begin_checkout', 'purchase'
    )
),

session_funnel AS (
  SELECT
    user_pseudo_id,
    session_id,
    MAX(CASE WHEN event_name = 'session_start'  THEN 1 ELSE 0 END) AS reached_session,
    MAX(CASE WHEN event_name = 'view_item'       THEN 1 ELSE 0 END) AS reached_view_item,
    MAX(CASE WHEN event_name = 'add_to_cart'     THEN 1 ELSE 0 END) AS reached_add_to_cart,
    MAX(CASE WHEN event_name = 'begin_checkout'  THEN 1 ELSE 0 END) AS reached_begin_checkout,
    MAX(CASE WHEN event_name = 'purchase'        THEN 1 ELSE 0 END) AS reached_purchase,
    MIN(event_timestamp) AS first_event_ts,
    MAX(event_timestamp) AS last_event_ts,
    MAX(channel)         AS last_touch_channel
  FROM raw_events
  WHERE session_id IS NOT NULL
  GROUP BY user_pseudo_id, session_id
)

SELECT
  user_pseudo_id,
  session_id,
  reached_session,
  reached_view_item,
  reached_add_to_cart,
  reached_begin_checkout,
  reached_purchase,
  last_touch_channel,
  CASE
    WHEN reached_purchase       = 1 THEN 'converted'
    WHEN reached_begin_checkout = 1 THEN 'dropped_at_payment'
    WHEN reached_add_to_cart    = 1 THEN 'dropped_at_checkout'
    WHEN reached_view_item      = 1 THEN 'dropped_at_browse'
    ELSE                                  'bounced'
  END AS funnel_path
FROM session_funnel;

-- Expected output: ~354,000 rows

-- =============================================================
-- TABLE 2: q1_funnel_summary
-- PURPOSE: Aggregated funnel metrics. One row per funnel stage.
-- =============================================================

CREATE OR REPLACE TABLE
  `healthtrack-analytics.healthtrack_analytics.q1_funnel_summary`
AS

WITH stage_counts AS (
  SELECT
    SUM(reached_session)        AS sessions,
    SUM(reached_view_item)      AS viewed_item,
    SUM(reached_add_to_cart)    AS added_to_cart,
    SUM(reached_begin_checkout) AS began_checkout,
    SUM(reached_purchase)       AS purchased
  FROM `healthtrack-analytics.healthtrack_analytics.q1_sessions`
),

unpivoted AS (
  SELECT 1 AS stage_order, 'Session start'  AS stage, sessions     AS users FROM stage_counts
  UNION ALL
  SELECT 2, 'Viewed item',    viewed_item    FROM stage_counts
  UNION ALL
  SELECT 3, 'Added to cart',  added_to_cart  FROM stage_counts
  UNION ALL
  SELECT 4, 'Began checkout', began_checkout FROM stage_counts
  UNION ALL
  SELECT 5, 'Purchased',      purchased      FROM stage_counts
)

SELECT
  stage_order,
  stage,
  users,
  ROUND(
    users * 100.0 / FIRST_VALUE(users) OVER (ORDER BY stage_order),
  2) AS conversion_rate_pct,
  ROUND(
    (LAG(users) OVER (ORDER BY stage_order) - users) * 100.0
    / NULLIF(LAG(users) OVER (ORDER BY stage_order), 0),
  2) AS dropoff_rate_pct,
  COALESCE(
    LAG(users) OVER (ORDER BY stage_order) - users,
  0) AS sessions_lost
FROM unpivoted
ORDER BY stage_order;

-- Expected output: 5 rows
-- Session start   354,857   100%      null    0
-- Viewed item      77,020    21.7%    78.3%   277,837
-- Added to cart    15,188     4.28%   80.28%   61,832
-- Began checkout   11,106     3.13%   26.88%    4,082
-- Purchased         4,848     1.37%   56.35%    6,258


-- =============================================================
-- TABLE 3: q1_channel_performance
-- PURPOSE: Channel-level funnel conversion rates.
--          One row per channel.
--
-- KEY TECHNIQUES:
--   GROUP BY channel  — aggregates all sessions per channel
--   SUM / COUNT ratio — calculates conversion rate at each stage
--   Estimated revenue at risk uses illustrative AOV of £65
-- =============================================================

CREATE OR REPLACE TABLE
  `healthtrack-analytics.healthtrack_analytics.q1_channel_performance`
AS

SELECT
  last_touch_channel                                         AS channel,
  COUNT(*)                                                   AS total_sessions,
  SUM(reached_view_item)                                     AS sessions_viewed_item,
  SUM(reached_add_to_cart)                                   AS sessions_added_cart,
  SUM(reached_begin_checkout)                                AS sessions_began_checkout,
  SUM(reached_purchase)                                      AS sessions_purchased,
  ROUND(SUM(reached_view_item)      * 100.0 / COUNT(*), 2)  AS view_rate_pct,
  ROUND(SUM(reached_add_to_cart)    * 100.0 / COUNT(*), 2)  AS cart_rate_pct,
  ROUND(SUM(reached_begin_checkout) * 100.0 / COUNT(*), 2)  AS checkout_rate_pct,
  ROUND(SUM(reached_purchase)       * 100.0 / COUNT(*), 2)  AS purchase_rate_pct,
  (COUNT(*) - SUM(reached_purchase)) * 65                   AS est_revenue_at_risk_gbp
FROM
  `healthtrack-analytics.healthtrack_analytics.q1_sessions`
WHERE
  last_touch_channel IS NOT NULL
GROUP BY
  last_touch_channel
ORDER BY
  total_sessions DESC;

-- Expected output: 6 rows
-- organic         121,987 sessions   1.10% purchase rate
-- (none)           82,732 sessions   1.30% purchase rate
-- referral         62,611 sessions   1.69% purchase rate
-- <Other>          51,879 sessions   0.98% purchase rate
-- (data deleted)   21,856 sessions   3.23% purchase rate  ← highest
-- cpc              15,561 sessions   0.98% purchase rate  ← lowest trackable


-- =============================================================
-- TABLE 4: q1_user_journeys
-- PURPOSE: User-level journey analysis. One row per unique user.
--          Connects multiple sessions for the same user.
--          Shows journey complexity and first-touch channel.
--          Key insight: users with 8+ sessions convert at 29%
--          vs single-session users at 0.49%.
--
-- =============================================================

CREATE OR REPLACE TABLE
  `healthtrack-analytics.healthtrack_analytics.q1_user_journeys`
AS

WITH user_sessions AS (
  SELECT
    user_pseudo_id,
    session_id,
    last_touch_channel,
    funnel_path,
    reached_purchase,
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id
      ORDER BY session_id ASC
    ) AS session_number
  FROM `healthtrack-analytics.healthtrack_analytics.q1_sessions`
),

purchasing_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `healthtrack-analytics.healthtrack_analytics.q1_sessions`
  WHERE reached_purchase = 1
),

first_touch AS (
  SELECT
    user_pseudo_id,
    last_touch_channel AS first_touch_channel
  FROM user_sessions
  WHERE session_number = 1
),

sessions_to_convert AS (
  SELECT
    user_pseudo_id,
    COUNT(*)           AS total_sessions,
    SUM(reached_purchase) AS total_purchases
  FROM `healthtrack-analytics.healthtrack_analytics.q1_sessions`
  GROUP BY user_pseudo_id
)

SELECT
  s.user_pseudo_id,
  s.total_sessions,
  s.total_purchases,
  f.first_touch_channel,
  CASE
    WHEN s.total_sessions = 1              THEN 'single_session'
    WHEN s.total_sessions BETWEEN 2 AND 3  THEN '2_to_3_sessions'
    WHEN s.total_sessions BETWEEN 4 AND 7  THEN '4_to_7_sessions'
    ELSE                                        '8_or_more_sessions'
  END AS journey_complexity,
  CASE
    WHEN p.user_pseudo_id IS NOT NULL THEN 1
    ELSE 0
  END AS converted
FROM sessions_to_convert s
LEFT JOIN first_touch f      USING (user_pseudo_id)
LEFT JOIN purchasing_users p USING (user_pseudo_id)
ORDER BY s.total_sessions DESC;

-- Expected output: ~268,000 rows

-- =============================================================
-- TABLE 5: q1_journey_summary
-- PURPOSE: Aggregated journey complexity summary.
-- =============================================================

CREATE OR REPLACE TABLE
  `healthtrack-analytics.healthtrack_analytics.q1_journey_summary`
AS

SELECT
  journey_complexity,
  COUNT(*)                                           AS total_users,
  SUM(converted)                                     AS converted_users,
  ROUND(SUM(converted) * 100.0 / COUNT(*), 2)       AS conversion_rate_pct,
  ROUND(AVG(total_sessions), 1)                      AS avg_sessions_per_user,
  ROUND(AVG(total_purchases), 3)                     AS avg_purchases_per_user,
  CASE journey_complexity
    WHEN 'single_session'     THEN 1
    WHEN '2_to_3_sessions'    THEN 2
    WHEN '4_to_7_sessions'    THEN 3
    WHEN '8_or_more_sessions' THEN 4
  END AS sort_order
FROM `healthtrack-analytics.healthtrack_analytics.q1_user_journeys`
GROUP BY journey_complexity
ORDER BY sort_order;

-- Expected output: 4 rows
-- single_session      221,342 users   0.49% conversion
-- 2_to_3_sessions      37,306 users   4.30% conversion
-- 4_to_7_sessions       7,851 users  16.41% conversion
-- 8_or_more_sessions    1,524 users  29.00% conversion

-- =============================================================

SELECT 'q1_sessions'          AS table_name, COUNT(*) AS rows FROM `healthtrack-analytics.healthtrack_analytics.q1_sessions`
UNION ALL
SELECT 'q1_funnel_summary',     COUNT(*) FROM `healthtrack-analytics.healthtrack_analytics.q1_funnel_summary`
UNION ALL
SELECT 'q1_channel_performance',COUNT(*) FROM `healthtrack-analytics.healthtrack_analytics.q1_channel_performance`
UNION ALL
SELECT 'q1_user_journeys',      COUNT(*) FROM `healthtrack-analytics.healthtrack_analytics.q1_user_journeys`
UNION ALL
SELECT 'q1_journey_summary',    COUNT(*) FROM `healthtrack-analytics.healthtrack_analytics.q1_journey_summary`;


-- =============================================================
-- Journey complexity by channel (the key multi-session finding)
SELECT
  journey_complexity,
  first_touch_channel,
  COUNT(*)                                     AS total_users,
  SUM(converted)                               AS converted_users,
  ROUND(SUM(converted) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
  ROUND(AVG(total_sessions), 1)                AS avg_sessions
FROM `healthtrack-analytics.healthtrack_analytics.q1_user_journeys`
GROUP BY journey_complexity, first_touch_channel
ORDER BY
  CASE journey_complexity
    WHEN 'single_session'     THEN 1
    WHEN '2_to_3_sessions'    THEN 2
    WHEN '4_to_7_sessions'    THEN 3
    WHEN '8_or_more_sessions' THEN 4
  END,
  conversion_rate_pct DESC;
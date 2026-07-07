create database project;
use project;

/* Smart Urban EV Charging Network — SQL Project
   Problem Statement: Analyse the adoption, utilization, reliability, and revenue 
   performance of EV charging infrastructure across Indian cities to guide expansion  
   decisions.
*/


-- Step 1
CREATE TABLE cities (
  city_id   INT PRIMARY KEY,
  city_name VARCHAR(50),
  state     VARCHAR(50),
  country   VARCHAR(30),
  lat       DECIMAL(7,5),
  lon       DECIMAL(7,5),
  population INT,
  tier      VARCHAR(10)
);

select * from cities;

-- Step 2
CREATE TABLE ev_vehicles (
  vehicle_id           INT PRIMARY KEY,
  vehicle_code         VARCHAR(10),
  model_name           VARCHAR(50),
  manufacturer         VARCHAR(50),
  battery_capacity_kwh DECIMAL(5,2),
  range_km             INT,
  vehicle_type         VARCHAR(20),
  registration_date    DATE,
  home_city_id         INT,
  status               VARCHAR(15),
  current_battery_pct  DECIMAL(4,1),
  FOREIGN KEY (home_city_id) REFERENCES cities(city_id)
);

select * from ev_vehicles;

CREATE TABLE charging_stations (
  station_id        INT PRIMARY KEY,
  station_code      VARCHAR(10),
  city_id           INT,
  latitude          DECIMAL(8,5),
  longitude         DECIMAL(8,5),
  operator_name     VARCHAR(50),
  station_type      VARCHAR(20),
  total_ports       INT,
  power_kw          INT,
  status            VARCHAR(25),
  inauguration_date DATE,
  price_per_kwh     DECIMAL(5,2),
  FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

select * from charging_stations;

-- Step 4
CREATE TABLE users (
  user_id            INT PRIMARY KEY,
  user_code          VARCHAR(12),
  email              VARCHAR(80),
  gender             VARCHAR(10),
  age                INT,
  city_id            INT,
  join_date          DATE,
  membership_tier    VARCHAR(15),
  wallet_balance_inr DECIMAL(8,2),
  is_fleet_user      VARCHAR(3),
  FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

select * from users;

-- Step 5
CREATE TABLE user_vehicle_mapping (
  mapping_id           INT PRIMARY KEY,
  user_id              INT,
  vehicle_id           INT,
  ownership_start_date DATE,
  ownership_type       VARCHAR(20),
  FOREIGN KEY (user_id)    REFERENCES users(user_id),
  FOREIGN KEY (vehicle_id) REFERENCES ev_vehicles(vehicle_id)
);

select * from user_vehicle_mapping;



-- Step 6
CREATE TABLE charging_sessions (
  session_id      INT PRIMARY KEY,
  vehicle_id      INT,
  station_id      INT,
  start_time      DATETIME,
  end_time        DATETIME,
  duration_minutes INT,
  energy_kwh      DECIMAL(6,2),
  total_cost_inr  DECIMAL(8,2),
  payment_method  VARCHAR(20),
  session_status  VARCHAR(15),
  user_rating     DECIMAL(2,1),
  FOREIGN KEY (vehicle_id) REFERENCES ev_vehicles(vehicle_id),
  FOREIGN KEY (station_id) REFERENCES charging_stations(station_id)
);


select * from charging_sessions;

-- Step 7
CREATE TABLE maintenance_logs (
  log_id            INT PRIMARY KEY,
  station_id        INT,
  reported_at       DATETIME,
  resolved_at       DATETIME,
  issue_type        VARCHAR(40),
  severity          VARCHAR(10),
  repair_cost_inr   DECIMAL(10,2),
  resolution_status VARCHAR(10),
  FOREIGN KEY (station_id) REFERENCES charging_stations(station_id)
);

select * from maintenance_logs;

-- Step 8
CREATE TABLE energy_grid_stats (
    stat_id INT PRIMARY KEY,
    city_id INT,
    `year_month` VARCHAR(7),
    total_energy_consumed_kwh DECIMAL(8,2),
    renewable_energy_pct DECIMAL(4,3),
    peak_demand_kw DECIMAL(7,2),
    grid_outage_minutes DECIMAL(6,2),
    avg_grid_tariff_inr DECIMAL(4,2),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

select * from energy_grid_stats;

/* Smart Urban EV Charging Network — SQL Project
Problem Statement: Analyse the adoption, utilization, reliability, and revenue 
                   performance of EV charging infrastructure across Indian cities to 
                   guide expansion decisions.*/


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE charging_sessions;
SET FOREIGN_KEY_CHECKS = 1;




-- ════════════════════════════════════════════════════════════
--  BASIC (Q1–Q5)
-- ════════════════════════════════════════════════════════════

-- Q1 List all charging stations in Pune that are currently Operational.                   
select cs.station_id, cs.station_code, cs.operator_name,
       cs.station_type, cs.total_ports, cs.power_kw, cs.price_per_kwh, 
       c.city_name
from charging_stations cs
join cities c on c.city_id = cs.city_id
where c.city_name = "Pune" and cs.status = "Operational";

-- Q2.Count the total number of EV vehicles registered per city.
SELECT c.city_name, c.tier, COUNT(v.vehicle_id) AS total_vehicles
FROM   cities c
LEFT   JOIN ev_vehicles v ON c.city_id = v.home_city_id
GROUP  BY c.city_id, c.city_name, c.tier
ORDER  BY total_vehicles DESC;

-- Q3. Find all users with Platinum membership and wallet balance above ₹2000.
SELECT user_id, user_code, email, age, gender,
       membership_tier, wallet_balance_inr
from users
where wallet_balance_inr > 2000 and membership_tier = "Platinum"
order by wallet_balance_inr desc;

-- Q4. Which payment methods were used in sessions that were Interrupted or Failed?
select distinct payment_method, session_status
from charging_sessions
where session_status in ("Interrupted","Failed")
order by payment_method;


-- Q5. Top 5 most expensive charging stations by price_per_kwh.
select cs.station_code, cs.operator_name, cs.station_type, 
       c.city_name, cs.price_per_kwh,c.tier
from charging_stations cs
join cities c on cs.city_id = c.city_id
order by cs.price_per_kwh desc limit 5;


-- ════════════════════════════════════════════════════════════
--  INTERMEDIATE (Q6–Q12)
-- ════════════════════════════════════════════════════════════

-- Q6. Total revenue (total_cost_inr) generated by each operator across all sessions.
SELECT cs.operator_name,
       COUNT(s.session_id)        AS total_sessions,
       ROUND(SUM(s.total_cost_inr), 2) AS total_revenue_inr,
       ROUND(AVG(s.total_cost_inr), 2) AS avg_revenue_per_session
FROM   charging_stations cs
JOIN   charging_sessions s ON cs.station_id = s.station_id
WHERE  s.session_status = 'Completed'
GROUP  BY cs.operator_name
ORDER  BY total_revenue_inr DESC;

-- Q7. Which city has the highest average user_rating for charging sessions?
SELECT c.city_name, c.tier,
       ROUND(AVG(s.user_rating), 2) AS avg_rating,
       COUNT(s.session_id)          AS total_sessions
FROM   cities c
JOIN   charging_stations cs ON c.city_id = cs.city_id
JOIN   charging_sessions s  ON cs.station_id = s.station_id
WHERE  s.user_rating IS NOT NULL
GROUP  BY c.city_id, c.city_name, c.tier
ORDER  BY avg_rating DESC
LIMIT  1;


-- Q8. Vehicles that have NEVER had a charging session. (LEFT JOIN + NULL check)
SELECT count(*)
FROM   ev_vehicles v
LEFT  JOIN charging_sessions s ON v.vehicle_id = s.vehicle_id
LEFT  JOIN cities c ON v.home_city_id = c.city_id   -- both LEFT JOINs
WHERE  s.session_id IS NULL
ORDER  BY v.manufacturer, v.model_name;


-- Q9. Average charging duration (minutes) per station_type.
SELECT cs.station_type,
       COUNT(s.session_id)              AS total_sessions,
       ROUND(AVG(s.duration_minutes), 1) AS avg_duration_min,
       ROUND(AVG(s.energy_kwh), 2)      AS avg_energy_kwh
FROM   charging_stations cs
JOIN   charging_sessions s ON cs.station_id = s.station_id
GROUP  BY cs.station_type
ORDER  BY avg_duration_min;

-- Q10. Manufacturer whose vehicles consume the most energy per session on average.
SELECT v.manufacturer,
       COUNT(s.session_id)         AS total_sessions,
       ROUND(AVG(s.energy_kwh), 3) AS avg_energy_per_session_kwh
FROM   ev_vehicles v
JOIN   charging_sessions s ON v.vehicle_id = s.vehicle_id
WHERE  s.session_status = 'Completed'
GROUP  BY v.manufacturer
ORDER  BY avg_energy_per_session_kwh DESC;

-- Q11. Stations with more than 3 maintenance issues that are still Operational.
SELECT cs.station_id, cs.station_code, cs.operator_name,
       c.city_name, cs.station_type, cs.status,
       COUNT(m.log_id)             AS total_issues,
       SUM(m.repair_cost_inr)      AS total_repair_cost
FROM   charging_stations cs
JOIN   cities c ON cs.city_id = c.city_id
JOIN   maintenance_logs m ON cs.station_id = m.station_id
WHERE  cs.status = 'Operational'
GROUP  BY cs.station_id, cs.station_code, cs.operator_name,
          c.city_name, cs.station_type, cs.status
HAVING COUNT(m.log_id) > 3
ORDER  BY total_issues DESC;

-- Q12. For each membership tier: total sessions and total energy consumed.
SELECT u.membership_tier,
       COUNT(s.session_id)          AS total_sessions,
       ROUND(SUM(s.energy_kwh), 2)  AS total_energy_kwh,
       ROUND(AVG(s.energy_kwh), 3)  AS avg_energy_per_session,
       ROUND(SUM(s.total_cost_inr), 2) AS total_revenue_inr
FROM   users u
JOIN   user_vehicle_mapping uvm ON u.user_id  = uvm.user_id
JOIN   charging_sessions    s   ON uvm.vehicle_id = s.vehicle_id
GROUP  BY u.membership_tier
ORDER  BY total_revenue_inr DESC;


-- ════════════════════════════════════════════════════════════
--  ADVANCED (Q13–Q20)
-- ════════════════════════════════════════════════════════════

-- Q13. Rank cities by total charging revenue using RANK() window function.
SELECT city_name, tier, total_revenue_inr,
       RANK()       OVER (ORDER BY total_revenue_inr DESC) AS revenue_rank,
       DENSE_RANK() OVER (ORDER BY total_revenue_inr DESC) AS "dense_rank",
       ROUND(total_revenue_inr * 100.0 /
             SUM(total_revenue_inr) OVER (), 2)            AS revenue_share_pct
FROM (
    SELECT c.city_name, c.tier,
           ROUND(SUM(s.total_cost_inr), 2) AS total_revenue_inr
    FROM   cities c
    JOIN   charging_stations cs ON c.city_id    = cs.city_id
    JOIN   charging_sessions  s  ON cs.station_id = s.station_id
    WHERE  s.session_status = 'Completed'
    GROUP  BY c.city_id, c.city_name, c.tier
) revenue_by_city
ORDER  BY revenue_rank;


-- Q14. For each station, find the month with the highest number of sessions.
--      CTE + RANK pattern
WITH monthly_sessions AS (
    SELECT station_id,
           DATE_FORMAT(start_time, '%Y-%m') AS session_month,
           COUNT(*)                          AS session_count
    FROM   charging_sessions
    GROUP  BY station_id, DATE_FORMAT(start_time, '%Y-%m')
),
ranked AS (
    SELECT station_id, session_month, session_count,
           RANK() OVER (PARTITION BY station_id
                        ORDER BY session_count DESC) AS rnk
    FROM   monthly_sessions
)
SELECT r.station_id, cs.station_code, c.city_name,
       r.session_month AS peak_month,
       r.session_count AS peak_sessions
FROM   ranked r
JOIN   charging_stations cs ON r.station_id = cs.station_id
JOIN   cities c ON cs.city_id = c.city_id
WHERE  r.rnk = 1
ORDER  BY r.session_count DESC;


-- Q15. Users who own more than one vehicle AND have completed more than 5 sessions.
WITH user_vehicle_count AS (
    SELECT user_id, COUNT(vehicle_id) AS vehicle_count
    FROM   user_vehicle_mapping
    GROUP  BY user_id
    HAVING COUNT(vehicle_id) > 1
),
user_session_count AS (
    SELECT uvm.user_id, COUNT(s.session_id) AS completed_sessions
    FROM   user_vehicle_mapping uvm
    JOIN   charging_sessions s ON uvm.vehicle_id = s.vehicle_id
    WHERE  s.session_status = 'Completed'
    GROUP  BY uvm.user_id
    HAVING COUNT(s.session_id) > 5
)
SELECT u.user_id, u.user_code, u.email, u.membership_tier,
       uvc.vehicle_count,
       usc.completed_sessions
FROM   users u
JOIN   user_vehicle_count  uvc ON u.user_id = uvc.user_id
JOIN   user_session_count  usc ON u.user_id = usc.user_id
ORDER  BY usc.completed_sessions DESC;


-- Q16. Month-over-month growth in energy consumed per city using LAG().
WITH monthly_energy AS (
    SELECT c.city_id, c.city_name,
           DATE_FORMAT(s.start_time, '%Y-%m') AS yr_month,
           ROUND(SUM(s.energy_kwh), 2)         AS total_energy
    FROM   cities c
    JOIN   charging_stations cs ON c.city_id    = cs.city_id
    JOIN   charging_sessions  s  ON cs.station_id = s.station_id
    GROUP  BY c.city_id, c.city_name,
              DATE_FORMAT(s.start_time, '%Y-%m')
)
SELECT city_name, yr_month, total_energy,
       LAG(total_energy) OVER (PARTITION BY city_id
                               ORDER BY yr_month)  AS prev_month_energy,
       ROUND(
           (total_energy - LAG(total_energy) OVER (PARTITION BY city_id
                                                   ORDER BY yr_month))
           * 100.0 /
           NULLIF(LAG(total_energy) OVER (PARTITION BY city_id
                                          ORDER BY yr_month), 0)
       , 2)                                         AS mom_growth_pct
FROM   monthly_energy
ORDER  BY city_name, yr_month;


-- Q17. Stations where maintenance cost > 50% of revenue — are they profitable?
WITH station_revenue AS (
    SELECT station_id,
           ROUND(SUM(total_cost_inr), 2) AS total_revenue
    FROM   charging_sessions
    WHERE  session_status = 'Completed'
    GROUP  BY station_id
),
station_maint AS (
    SELECT station_id,
           ROUND(SUM(repair_cost_inr), 2) AS total_maint_cost
    FROM   maintenance_logs
    GROUP  BY station_id
)
SELECT cs.station_code, c.city_name, cs.operator_name, cs.status,
       COALESCE(sr.total_revenue, 0)    AS total_revenue_inr,
       COALESCE(sm.total_maint_cost, 0) AS total_maint_cost_inr,
       ROUND(
           COALESCE(sm.total_maint_cost, 0) * 100.0 /
           NULLIF(COALESCE(sr.total_revenue, 0), 0)
       , 2)                              AS maint_to_revenue_ratio_pct,
       CASE
           WHEN COALESCE(sm.total_maint_cost,0) > 0.5 * COALESCE(sr.total_revenue,0)
           THEN 'NOT PROFITABLE'
           ELSE 'PROFITABLE'
       END                               AS profitability
FROM   charging_stations cs
JOIN   cities c ON cs.city_id = c.city_id
LEFT   JOIN station_revenue sr ON cs.station_id = sr.station_id
LEFT   JOIN station_maint   sm ON cs.station_id = sm.station_id
WHERE  COALESCE(sm.total_maint_cost, 0) >
       0.5 * COALESCE(sr.total_revenue, 0)
ORDER  BY maint_to_revenue_ratio_pct DESC;


-- Q18. Top 3 most-used stations per city using ROW_NUMBER() partitioned by city.
WITH station_usage AS (
    SELECT cs.station_id, cs.station_code, cs.operator_name,
           cs.station_type, c.city_id, c.city_name,
           COUNT(s.session_id) AS total_sessions,
           ROUND(SUM(s.total_cost_inr), 2) AS total_revenue
    FROM   charging_stations cs
    JOIN   cities c ON cs.city_id = c.city_id
    JOIN   charging_sessions s ON cs.station_id = s.station_id
    GROUP  BY cs.station_id, cs.station_code, cs.operator_name,
              cs.station_type, c.city_id, c.city_name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY city_id
                              ORDER BY total_sessions DESC) AS city_rank
    FROM   station_usage
)
SELECT city_name, city_rank, station_code, operator_name,
       station_type, total_sessions, total_revenue
FROM   ranked
WHERE  city_rank <= 3
ORDER  BY city_name, city_rank;


-- Q19. Renewable energy % vs grid outage time correlation per city over 2 years.
--      (Pearson-style: using CORR via manual formula since MySQL lacks CORR())
WITH stats AS (
    SELECT city_id,
           AVG(renewable_energy_pct)    AS avg_re,
           AVG(grid_outage_minutes)     AS avg_go,
           STDDEV(renewable_energy_pct) AS sd_re,
           STDDEV(grid_outage_minutes)  AS sd_go
    FROM   energy_grid_stats
    GROUP  BY city_id
),
pairs AS (
    SELECT e.city_id,
           (e.renewable_energy_pct - s.avg_re) *
           (e.grid_outage_minutes  - s.avg_go) AS cross_dev
    FROM   energy_grid_stats e
    JOIN   stats s ON e.city_id = s.city_id
)
SELECT
    c.city_name,
    ROUND(s.avg_re * 100, 1)  AS avg_renewable_pct,   -- ✅ s not st
    ROUND(s.avg_go, 1)        AS avg_outage_min,       -- ✅ s not st
    ROUND(
        SUM(p.cross_dev) / (COUNT(*) * s.sd_re * s.sd_go)  -- ✅ s not st
    , 4)  AS pearson_correlation,
    CASE
        WHEN SUM(p.cross_dev) / (COUNT(*) * s.sd_re * s.sd_go) < -0.3   -- ✅
        THEN 'Negative (more renewable = less outage)'
        WHEN SUM(p.cross_dev) / (COUNT(*) * s.sd_re * s.sd_go) > 0.3    -- ✅
        THEN 'Positive (more renewable = more outage?)'
        ELSE 'No strong correlation'
    END AS interpretation
FROM   pairs p
JOIN   stats   s ON p.city_id = s.city_id   -- alias is 's'
JOIN   cities  c ON p.city_id = c.city_id
GROUP  BY c.city_name, s.avg_re, s.avg_go, s.sd_re, s.sd_go   -- ✅ s not st
ORDER  BY pearson_correlation;

-- Q20. Cohort analysis: avg session count per user in first 90 days, by join quarter.
WITH user_cohort AS (
    SELECT u.user_id,
           CONCAT(YEAR(u.join_date), '-Q',
                  QUARTER(u.join_date))   AS join_quarter,
           u.join_date
    FROM   users u
),
early_sessions AS (
    SELECT uvm.user_id,
           COUNT(s.session_id) AS sessions_in_90_days
    FROM   user_vehicle_mapping uvm
    JOIN   charging_sessions    s   ON uvm.vehicle_id = s.vehicle_id
    JOIN   user_cohort          uc  ON uvm.user_id    = uc.user_id
    WHERE  s.session_status = 'Completed'
      AND  s.start_time >= uc.join_date
      AND  s.start_time <  DATE_ADD(uc.join_date, INTERVAL 90 DAY)
    GROUP  BY uvm.user_id
)
SELECT uc.join_quarter,
       COUNT(DISTINCT uc.user_id)              AS cohort_size,
       COUNT(DISTINCT es.user_id)              AS users_with_sessions,
       ROUND(AVG(COALESCE(es.sessions_in_90_days, 0)), 2) AS avg_sessions_90d,
       ROUND(
           COUNT(DISTINCT es.user_id) * 100.0 /
           COUNT(DISTINCT uc.user_id)
       , 1)                                    AS activation_rate_pct
FROM   user_cohort uc
LEFT   JOIN early_sessions es ON uc.user_id = es.user_id
GROUP  BY uc.join_quarter
ORDER  BY uc.join_quarter;

-- ============================================================
--  END OF FILE
-- ============================================================



/*
+-----------------------------------------------------+------------------------------------------------+
| Signal                                              | What it means                                  |
+-----------------------------------------------------+------------------------------------------------+
| Ahmedabad has 69 EVs but fewer stations than Mumbai | HIGH demand, LOW supply = expand urgently      |
| Tier-1 cities have 34–45 EVs only                   | Demand is relatively lower in existing cities  |
| Tier-2 cities occupy ALL top 5 positions            | The market has already shifted to Tier-2       |
+-----------------------------------------------------+------------------------------------------------+
*/


select * from cities where tier = "Tier-2";






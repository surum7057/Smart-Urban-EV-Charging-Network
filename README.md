# Smart-Urban-EV-Charging-Network
A SQL analytics project that analyzes EV charging stations, revenue, maintenance, and customer behavior to support business decision-making.
# ⚡ Smart Urban EV Charging Network – SQL Project

## 📌 Project Overview

This project analyzes an **Electric Vehicle (EV) Charging Network** using SQL to help answer a critical business question:

> **Should the company expand EV charging infrastructure to Tier-2 cities, or should it first improve the existing Tier-1 infrastructure?**

The project uses real-world business scenarios, SQL queries, and data analysis to generate insights that support strategic decision-making.

---

## 🎯 Business Problem

As EV adoption increases across India, charging infrastructure must keep pace.

The company needs to determine whether it should:

- Expand charging stations into Tier-2 cities, or
- Improve the reliability and efficiency of the existing Tier-1 charging network first.

This project answers that question through data-driven analysis.

---

## 📊 Project Objectives

- Analyze EV demand across different cities.
- Compare charging infrastructure with vehicle growth.
- Evaluate revenue generation and customer usage.
- Measure charging station profitability.
- Analyze maintenance costs and operational reliability.
- Identify future expansion opportunities.

---

# 🗂️ Database Information

The project consists of **8 relational tables**.

| Table | Description |
|--------|-------------|
| cities | City information including tier classification |
| ev_vehicles | Registered EV vehicles |
| charging_stations | Charging station details |
| users | Customer information |
| user_vehicle_mapping | Mapping between users and vehicles |
| charging_sessions | Charging history (**Fact Table**) |
| maintenance_logs | Station maintenance records |
| energy_grid_stats | Electricity and grid statistics |

### Database Import Order

```
cities
    ↓
ev_vehicles
    ↓
charging_stations
    ↓
users
    ↓
user_vehicle_mapping
    ↓
charging_sessions
    ↓
maintenance_logs
    ↓
energy_grid_stats
```

> **Fact Table:** `charging_sessions`

All other tables act as **Dimension Tables**.

---

# 🧩 Entity Relationship Model

The database follows a relational model where:

- Cities contain charging stations.
- Users own EV vehicles.
- Vehicles perform charging sessions.
- Charging stations require maintenance.
- Cities provide energy grid statistics.

---

# 📈 Project Structure

The analysis is divided into **4 Business Pillars**.

---

# Pillar 1 – Infrastructure Baseline

### Goal

Understand whether current charging infrastructure can support future EV growth.

### Key Insights

- Tier-2 cities already have significant EV adoption.
- Many Tier-2 cities have fewer charging stations despite growing demand.
- Vehicle-to-station ratio is higher in several cities.
- Tier-2 customers already pay premium charging prices.
- Ultra Fast DC chargers generate the highest revenue per session.

### Business Decision

Infrastructure expansion should prioritize Tier-2 cities with high demand while improving overloaded Tier-1 stations.

---

# Pillar 2 – Revenue & Usage

### Goal

Identify the customers, cities, and vehicle brands generating the highest revenue.

### Key Insights

- Tata Motors contributes the highest charging volume.
- Volvo generates the highest revenue per charging session.
- Platinum users contribute the largest share of revenue.
- Four of the top five revenue-generating cities are Tier-2 cities.

### Business Decision

Target both:

- Affordable EV owners (volume)
- Premium EV owners (high-value sessions)

to maximize revenue.

---

# Pillar 3 – Reliability & Risk

### Goal

Evaluate operational efficiency before expanding.

### Key Insights

- Payment failures occur across all payment methods equally.
- Around 40% of vehicles have never used the charging network.
- Some stations spend more on maintenance than they generate in revenue.
- Renewable energy alone does not guarantee reliable infrastructure.

### Business Decision

Before expansion:

- Improve charging station reliability.
- Reactivate inactive users.
- Optimize unprofitable stations.
- Strengthen backup power in high-risk cities.

---

# Pillar 4 – Growth Signals

### Goal

Identify cities showing long-term growth.

### Key Insights

- Monthly energy consumption is increasing in several cities.
- LAG() was used to calculate month-over-month growth.
- High energy growth indicates increasing EV adoption.

### Business Decision

Prioritize investment in cities with consistently increasing charging demand.

---

# 🛠 SQL Concepts Used

This project demonstrates practical use of:

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- CASE
- Aggregate Functions
- INNER JOIN
- LEFT JOIN
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
  - ROW_NUMBER()
  - RANK()
  - DENSE_RANK()
  - LAG()
- Date Functions
- Conditional Logic
- Revenue Analysis
- Business Analytics

---

# 📊 Business Insights

The project answers questions such as:

- Which cities have the highest EV demand?
- Which charging stations generate the most revenue?
- Which charger type performs best?
- Which users are most valuable?
- Which stations are profitable?
- Which cities should receive new charging stations?
- Which vehicles remain inactive?
- How reliable is the charging network?
- Which cities show future growth?

---

# 📌 Final Recommendation

The analysis suggests a balanced strategy:

✅ Expand into high-performing Tier-2 cities where demand and revenue are already strong.

✅ Simultaneously improve overloaded Tier-1 infrastructure to ensure reliability.

Rather than choosing only one strategy, the data supports **targeted expansion combined with infrastructure optimization**.

---

# 🚀 Skills Demonstrated

- SQL
- Relational Database Design
- Data Cleaning
- Business Analytics
- Revenue Analysis
- Window Functions
- Data Interpretation
- Problem Solving
- Dashboard Thinking
- Decision Support Analytics

---

# 📂 Project Files

```
EV_SQL_Project/
│
├── Dataset/
├── SQL Queries.sql
├── ER Diagram
├── Presentation (PPT)
└── README.md
```

---

# 👨‍💻 Team Members

- **Suraj Prashant More**
- **Tejas Lakhpati Koli**

---

# 📄 Conclusion

This project demonstrates how SQL can be used not only to retrieve data but also to solve real-world business problems. By analyzing EV infrastructure, customer behavior, operational efficiency, and revenue trends, the project provides actionable recommendations for strategic expansion and network optimization.

---

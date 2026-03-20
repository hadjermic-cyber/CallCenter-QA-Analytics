# 📊 Call Center QA Analytics

An end-to-end data analytics project analyzing quality assurance 
performance across a call center with 12 agents, 10 audit categories, 
and 1,235 audit records spanning the full year 2024.

---

## 🎯 Project Objective

To transform raw QA audit data into actionable operational insights — 
identifying top and bottom performers, failure drivers, and coaching 
priorities to support data-driven decision making in operations management.

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| MySQL | Data storage, cleaning & analysis |
| Power BI | Interactive dashboard & visualizations |
| Excel/CSV | Raw data source |
| GitHub | Version control & project documentation |

---

## 📁 Project Structure
```
callcenter-qa-analytics/
├── data/
│   ├── agents.csv               # 12 agents across 4 teams
│   ├── audit_categories.csv     # 10 weighted QA categories
│   └── qa_audits.csv            # 1,235 audit records (2024)
├── sql/
│   ├── 01_create_tables.sql     # Database schema
│   ├── 02_insert_data.sql       # Data import
│   └── 03_analysis_queries.sql  # 5 analysis queries
├── dashboard/
│   ├── page1_overview.png
│   └── page2_failure_analysis.png
└── README.md
```

---

## 🗄️ Database Schema

Three relational tables built in MySQL:

- **agents** — agent profiles, teams and supervisors
- **audit_categories** — 10 QA criteria with weights across 2 frameworks
- **qa_audits** — fact table linking agents to scored audit records

---

## 🔍 SQL Analysis Performed

**Query 1 — Agent Scoreboard**
Weighted average score per agent using category weights, ranked from 
top to bottom performer.

**Query 2 — Monthly Trends**
Score evolution month by month for each agent to detect improvement 
or decline over the year.

**Query 3 — Pareto Analysis**
Identified the top failure categories driving the most low scores — 
Escalation Handling, Problem Resolution and Documentation Accuracy 
account for the majority of all failures.

**Query 4 — Outlier Detection**
Flagged agents scoring significantly below their team average using 
CTEs and CASE logic, with coaching urgency labels.

**Query 5 — Coaching Priority List**
Combined low scores and high failure rates per category to produce 
a ranked action list for operations managers.

---

## 📊 Dashboard

The Power BI dashboard is split across two pages:

**Page 1 — Overview & Performance**
- 4 KPI cards: Avg Score, Total Audits, Failure Rate, Agents for Coaching
- Agent scoreboard with conditional color formatting
- Monthly score trend by agent

**Page 2 — Failure Analysis & Coaching**
- Pareto chart: failure drivers by category with cumulative % line
- Coaching priority table with conditional formatting by failure rate

---

## 💡 Key Findings

- **Top performers:** Amina Touré (93) and Fatima Benali (91)
- **Agents flagged for coaching:** Emma Côté and Carlos Mendez show 
failure rates above 40% in Escalation Handling and Compliance
- **Top failure driver:** Escalation Handling accounts for the largest 
share of quality failures across all teams
- **Trend:** Overall QA scores show a gradual improvement from Q1 to Q4 2024


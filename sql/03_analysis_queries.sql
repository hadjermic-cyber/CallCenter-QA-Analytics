-- ============================================================
-- Query 1: Agent weighted score ranking (full year 2024)
-- Each category has a different weight, so we can't just
-- average the scores -- we need a weighted average.
-- ============================================================
SELECT
    a.agent_name,
    a.team,
    a.supervisor,
    ROUND(
        SUM(q.score * ac.weight) / SUM(ac.weight)
    , 2)                             AS weighted_avg_score,
    COUNT(q.audit_id)                AS total_audits,
    RANK() OVER (
        ORDER BY SUM(q.score * ac.weight) / SUM(ac.weight) DESC
    )                                AS performance_rank
FROM qa_audits q
JOIN agents         a  ON q.agent_id    = a.agent_id
JOIN audit_categories ac ON q.category_id = ac.category_id
GROUP BY
    a.agent_id, a.agent_name, a.team, a.supervisor
ORDER BY
    weighted_avg_score DESC;

-- ============================================================
-- Query 2: Monthly average score per agent (2024)
-- Shows progression over time -- good for spotting
-- agents who are improving vs declining.
-- ============================================================
SELECT
    a.agent_name,
    a.team,
    MONTH(q.audit_date)              AS month_num,
    MONTHNAME(q.audit_date)          AS month_name,
    ROUND(AVG(q.score), 2)           AS avg_score,
    COUNT(q.audit_id)                AS audits_that_month
FROM qa_audits q
JOIN agents a ON q.agent_id = a.agent_id
GROUP BY
    a.agent_id, a.agent_name, a.team,
    MONTH(q.audit_date), MONTHNAME(q.audit_date)
ORDER BY
    a.agent_name, month_num;

-- ============================================================
-- Query 3: Pareto analysis -- top drivers of quality failures
-- We define a "failure" as any audit score below 70.
-- This tells operations WHERE to focus improvement efforts.
-- ============================================================
SELECT
    ac.category_name,
    ac.framework,
    COUNT(q.audit_id)                        AS total_failures,
    ROUND(AVG(q.score), 2)                   AS avg_score_when_failing,
    ROUND(
        COUNT(q.audit_id) * 100.0 /
        SUM(COUNT(q.audit_id)) OVER ()
    , 1)                                     AS pct_of_all_failures,
    ROUND(
        SUM(COUNT(q.audit_id)) OVER (
            ORDER BY COUNT(q.audit_id) DESC
        ) * 100.0 / SUM(COUNT(q.audit_id)) OVER ()
    , 1)                                     AS cumulative_pct
FROM qa_audits q
JOIN audit_categories ac ON q.category_id = ac.category_id
WHERE q.score < 70
GROUP BY
    ac.category_id, ac.category_name, ac.framework
ORDER BY
    total_failures DESC;

-- ============================================================
-- Query 4: Outlier detection -- agents below team average
-- We calculate each agent's score vs their team average.
-- A gap of more than 10 points flags them for review.
-- ============================================================
WITH agent_scores AS (
    SELECT
        a.agent_id,
        a.agent_name,
        a.team,
        ROUND(AVG(q.score), 2) AS agent_avg
    FROM qa_audits q
    JOIN agents a ON q.agent_id = a.agent_id
    GROUP BY a.agent_id, a.agent_name, a.team
),
team_scores AS (
    SELECT
        team,
        ROUND(AVG(agent_avg), 2) AS team_avg
    FROM agent_scores
    GROUP BY team
)
SELECT
    ag.agent_name,
    ag.team,
    ag.agent_avg,
    ts.team_avg,
    ROUND(ag.agent_avg - ts.team_avg, 2)  AS gap_vs_team,
    CASE
        WHEN ag.agent_avg - ts.team_avg < -10 THEN '🚨 Needs urgent coaching'
        WHEN ag.agent_avg - ts.team_avg < -5  THEN '⚠️  Monitor closely'
        ELSE '✅ On track'
    END                                    AS status
FROM agent_scores ag
JOIN team_scores ts ON ag.team = ts.team
ORDER BY gap_vs_team ASC;

-- ============================================================
-- Query 5: Coaching priority list
-- Combines low overall score + high failure count to
-- identify agents and their specific weak categories.
-- This is the actionable output for operations managers.
-- ============================================================
SELECT
    a.agent_name,
    a.team,
    a.supervisor,
    ac.category_name,
    ROUND(AVG(q.score), 2)      AS avg_score_in_category,
    COUNT(q.audit_id)           AS total_audits_in_category,
    SUM(CASE WHEN q.score < 70 THEN 1 ELSE 0 END)
                                AS failure_count,
    ROUND(
        SUM(CASE WHEN q.score < 70 THEN 1 ELSE 0 END) * 100.0
        / COUNT(q.audit_id)
    , 1)                        AS failure_rate_pct
FROM qa_audits q
JOIN agents           a  ON q.agent_id    = a.agent_id
JOIN audit_categories ac ON q.category_id = ac.category_id
GROUP BY
    a.agent_id, a.agent_name, a.team, a.supervisor,
    ac.category_id, ac.category_name
HAVING
    failure_rate_pct > 25          -- only show real problem areas
ORDER BY
    failure_rate_pct DESC,
    failure_count    DESC
LIMIT 20;

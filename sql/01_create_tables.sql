CREATE DATABASE IF NOT EXISTS callcenter_qa;
USE callcenter_qa;

CREATE TABLE agents (
    agent_id    INT PRIMARY KEY AUTO_INCREMENT,
    agent_name  VARCHAR(100) NOT NULL,
    team        VARCHAR(50)  NOT NULL,
    supervisor  VARCHAR(100) NOT NULL,
    hire_date   DATE         NOT NULL
);

CREATE TABLE audit_categories (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    weight        DECIMAL(4,2) NOT NULL,
    framework     VARCHAR(50)  NOT NULL
);

CREATE TABLE qa_audits (
    audit_id    INT PRIMARY KEY AUTO_INCREMENT,
    agent_id    INT          NOT NULL,
    category_id INT          NOT NULL,
    audit_date  DATE         NOT NULL,
    score       DECIMAL(5,2) NOT NULL,
    max_score   DECIMAL(5,2) NOT NULL DEFAULT 100,
    auditor     VARCHAR(100) NOT NULL,
    notes       TEXT,
    FOREIGN KEY (agent_id)    REFERENCES agents(agent_id),
    FOREIGN KEY (category_id) REFERENCES audit_categories(category_id)
);

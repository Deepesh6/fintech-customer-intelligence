# Customer Transaction Intelligence Platform

A production-grade data pipeline targeting early churn detection, behavioural segmentation, and revenue impact quantification for fintech companies (PhonePe, CRED, Razorpay, Groww).

## Business Problem

> "We are losing customers silently. Active users from 3 months ago have stopped transacting entirely — but our systems have no early warning mechanism."

This platform solves 3 problems:
1. **Early Churn Detection** — Identify users showing disengagement before they fully churn
2. **Behavioural Segmentation** — Segment users by transaction behaviour for targeted retention
3. **Revenue Impact Quantification** — Quantify revenue at risk from churning segments

## Tech Stack

| Layer | Technology |
|---|---|
| Data Warehouse | Snowflake |
| Transformation | DBT Core |
| Orchestration | Apache Airflow |
| ML | Python, scikit-learn (KMeans, Logistic Regression) |
| Language | Python, SQL |

## Dataset

PaySim synthetic financial transactions dataset — 6.3M transactions, 11 features.
- Source: Kaggle (ealaxi/paysim1)
- Fraud rate: 0.13% (heavily imbalanced — handled via class_weight='balanced')

## Pipeline Architecture
RAW_TRANSACTIONS (Snowflake)
↓
STG_TRANSACTIONS (DBT view — column standardization)
↓
FCT_CUSTOMER_FEATURES (DBT table — 13 engineered features)
↓
ml_pipeline.py (KMeans segmentation + LR churn scoring)
↓
ML_CUSTOMER_SCORES (Snowflake — 6.3M customers scored)

## Key Results

- **943,024 churned customers** identified (14.8% churn rate)
- **293,537 high-value dormant customers** — revenue at risk
- **4 behavioural segments** identified via KMeans clustering
- Logistic Regression baseline: **28% recall on churned customers**

## ML Models

### KMeans Clustering (Behavioural Segmentation)
- k=4 clusters
- Features: transaction amount, frequency, active span, high value flag
- Segments: Low Value One-Time, High Value One-Time, Repeat High Value, Repeat Mid Value

### Logistic Regression (Churn Prediction)
- Target: `is_churned` (recency_score > 700)
- Handled class imbalance via `class_weight='balanced'`
- Baseline recall: 28% (next step: Random Forest / XGBoost)

## Project Structure
fintech_customer_intelligence/
├── models/
│   ├── staging/
│   │   └── stg_transactions.sql
│   └── marts/
│       └── fct_customer_features.sql
├── macros/
│   └── generate_schema_name.sql
├── ml_pipeline.py
├── dbt_project.yml
└── .env.example

## Setup

1. Clone the repo
2. Create a Snowflake account and load PaySim dataset
3. Configure `.env` using `.env.example`
4. Run DBT models: `dbt run`
5. Run ML pipeline: `python ml_pipeline.py`

## Airflow DAG

Orchestration DAG (`fintech_pipeline_dag.py`) designed for Linux/cloud deployment:
- Task 1: DBT staging model refresh
- Task 2: DBT marts model refresh  
- Task 3: ML scoring pipeline
- Task 4: Completion log

DAG tested with `airflow dags report` — 4 tasks registered successfully.
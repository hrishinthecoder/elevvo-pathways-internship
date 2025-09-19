# Task 4 — Data Cleaning & Insight Generation from Survey Data

This project simulates the Kaggle Data Science Survey (2017–2021) with 1,500+ responses. It demonstrates an end-to-end workflow for cleaning messy survey data and extracting insights.

**Deliverables generated here:** cleaned CSV, executed Jupyter Notebook with outputs, documentation, and figures.

---

## 1) Dataset Overview
- **Raw rows:** 1,530  
- **Cleaned rows:** 1,500 (after removing 30 exact duplicates)

Synthetic fields include: `respondent_id`, `year`, `country_*`, `education_*`, `job_role_*`, `primary_language_*`, `ml_tools_raw`, `years_experience_raw`, `salary_usd_raw`, `remote_work_raw`, and processed columns.

---

## 2) Cleaning Methodology
- **Standardization:** Mapped country/education/job role/language/remote values to canonical forms.
- **Experience parsing:** Converted ranges like `3-5` → `4.0`, and `10+` → `12.0`.
- **Salary normalization:** Removed `$`/commas, converted to float, **imputed** missing by median per job role, then **winsorized** at 1st/99th percentiles.
- **Duplicates:** Dropped exact duplicates on `(respondent_id, year, job_role_raw, primary_language_raw)`.
- **ML tools:** Split semicolon lists into arrays; added `ml_tool_count` feature.
- **Encodings:** Label-encoded `country`, `education`, `job_role`, `primary_language`, `remote_work` for modeling.

---

## 3) Key Findings (Explained)
- **Python Dominance:** Reinforces training prioritization and hiring pipelines that favor Python skills.
- **Role-Based Pay:** Benchmark compensation and career ladders using role median salary gaps.
- **Remote/Hybrid Signals:** Guide workplace policy and tooling (VPN, collaboration, MLOps platforms).
- **Tooling Ecosystem:** scikit-learn/TensorFlow/PyTorch commonly cited; align stack and licenses accordingly.
- **Experience ↔ Salary:** Positive correlation suggests returns to skill tenure and senior IC tracks.

---

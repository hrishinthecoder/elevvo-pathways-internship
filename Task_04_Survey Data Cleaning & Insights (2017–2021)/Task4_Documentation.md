# Task 4 — Data Cleaning & Insight Generation from Survey Data

This project simulates the Kaggle Data Science Survey (2017–2021) with 1,500+ responses. It demonstrates an end-to-end workflow for cleaning messy survey data and extracting insights.

**Deliverables generated here:** cleaned CSV, executed Jupyter Notebook with outputs, documentation, and figures.

---

## 1) Dataset Overview
- **Raw rows:** 1,530  
- **Cleaned rows:** 1,500 (after removing 30 exact duplicates)

Synthetic fields include: `respondent_id`, `year`, `country_*`, `education_*`, `job_role_*`, `primary_language_*`, `ml_tools_raw`, `years_experience_raw`, `salary_usd_raw`, `remote_work_raw`, and processed columns.

**Files**
- [survey_raw.csv](survey_raw.csv)
- [cleaned_survey.csv](cleaned_survey.csv)
- [task4_survey_cleaning_insights.ipynb](task4_survey_cleaning_insights.ipynb)

---

## 2) Cleaning Methodology
- **Standardization:** Mapped country/education/job role/language/remote values to canonical forms.
- **Experience parsing:** Converted ranges like `3-5` → `4.0`, and `10+` → `12.0`.
- **Salary normalization:** Removed `$`/commas, converted to float, **imputed** missing by median per job role, then **winsorized** at 1st/99th percentiles.
- **Duplicates:** Dropped exact duplicates on `(respondent_id, year, job_role_raw, primary_language_raw)`.
- **ML tools:** Split semicolon lists into arrays; added `ml_tool_count` feature.
- **Encodings:** Label-encoded `country`, `education`, `job_role`, `primary_language`, `remote_work` for modeling.

---

## 3) Visual Insights (Top 5)
1. **Programming Languages:** Python is the dominant primary language.  
   ![Top Programming Languages](fig1_top_languages.png)

2. **Median Salary by Role:** ML/Data Engineer/ML Engineer roles lead median salaries.  
   ![Median Salary by Job Role](fig2_salary_by_role.png)

3. **Remote Work Preference:** Clear tilt toward remote/hybrid options.  
   ![Remote Work Preference](fig3_remote_pie.png)

4. **Salary Distribution:** Right-skewed even after winsorization; long tail of high earners.  
   ![Salary Distribution](fig4_salary_hist.png)

5. **Role–Language Mix:** Certain roles cluster strongly around Python; SQL spreads across analyst/data roles.  
   ![Job Role vs Primary Language](fig5_heatmap_role_lang.png)

---

## 4) Key Findings (Explained)
- **Python Dominance:** Reinforces training prioritization and hiring pipelines that favor Python skills.
- **Role-Based Pay:** Benchmark compensation and career ladders using role median salary gaps.
- **Remote/Hybrid Signals:** Guide workplace policy and tooling (VPN, collaboration, MLOps platforms).
- **Tooling Ecosystem:** scikit-learn/TensorFlow/PyTorch commonly cited; align stack and licenses accordingly.
- **Experience ↔ Salary:** Positive correlation suggests returns to skill tenure and senior IC tracks.

---

## 5) Reproducibility
Run the executed notebook with outputs:  
- [task4_survey_cleaning_insights.ipynb](task4_survey_cleaning_insights.ipynb)

The notebook includes: missing-value audit, duplicate analysis, encoding demo, and all charts.

---

## 6) LinkedIn Snippet (Copy/Paste)
See: [LinkedIn_Post_Task4.txt](LinkedIn_Post_Task4.txt)

> **Pitch:** Built a robust survey-cleaning pipeline (1.5k+ rows), encoded key categories, and delivered business-ready insights & visuals for decision support (compensation, training, hybrid work).

---

### Credits
Prepared for a portfolio-ready **Task 4**: Data Cleaning and Insight Generation from Survey Data.
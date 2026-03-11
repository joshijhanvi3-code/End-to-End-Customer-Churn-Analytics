# Customer Churn Prediction & Risk Segmentation
### End-to-End SQL + Machine Learning + Power BI Solution

---

## 1. Executive Summary

This project delivers a complete churn analytics pipeline — from raw data cleaning in SQL to machine learning prediction and business-ready dashboards.

Using historical customer data (6,007 records), I built and evaluated multiple classification models to estimate churn probability. The final Random Forest model achieved:

- **ROC-AUC: 0.90**
- **Accuracy: 84%**
- **Strong recall for churned customers (0.77)**

The model was then applied to newly joined customers (411 records) to generate churn probability scores and segment them into actionable risk tiers.

A high-risk segment (≥ 0.80 probability) represented **68.6% of newly joined customers** — driven primarily by contract type and early tenure characteristics.

---

## 2. Business Problem

Customer churn directly impacts recurring revenue and customer lifetime value. Acquisition cost is significantly higher than retention cost, making early churn detection critical.

The objective of this project was to:

- Identify churn drivers
- Predict churn probability at the individual customer level
- Segment customers by risk category
- Translate predictions into retention strategy recommendations

---

## 3. Data Engineering & Preparation (SQL)

### NULL Value Audit
A full NULL audit was performed across all 32 columns using conditional aggregation (`Data_Quality_Check.sql`).

Business-friendly NULL replacements were applied:

| Column | Replacement |
|---|---|
| Service-related fields | `"No"` |
| `Value_Deal` | `"None"` |
| `Churn_Category` / `Churn_Reason` | `"Others"` |

A production-ready table (`prod_churn`) was created to ensure clean downstream modeling (`Data_Transformation_Prod_Table.sql`).

### Exploratory Analysis (SQL)
Key analyses performed (`Exploratory_Data_Analysis.sql`):
- Gender and contract type distribution
- Revenue contribution by customer status
- State-wise geographic distribution
- Internet service type breakdown

### Dataset Segmentation via SQL Views
Two views were created (`View_Creation_Model_Segmentation.sql`):

- `vw_ChurnData` → Historical customers (Stayed + Churned) — used for model training
- `vw_JoinData` → Newly joined customers — used for churn scoring

This separation ensures proper supervised model training and realistic forward-looking scoring.

---

## 4. Exploratory Analysis

### Dataset Overview

| Metric | Value |
|---|---|
| Total customers | 6,007 |
| Churn rate | 28.8% |
| Avg tenure | 17 months |
| Avg monthly charge | $65 |

### Key Observations

- Month-to-Month contracts show significantly higher churn than annual contracts
- Early tenure customers (< 18 months) show elevated churn behavior
- Competitor-related reasons dominate churn causes (43.9% of all churn)
- Fiber Optic internet type associated with highest churn rate (41.1%)

---

## 5. Machine Learning Approach

### Data Quality Note
`Monthly_Charge` contains a minimum value of -10.0, likely representing a billing credit or adjustment. Retained as-is for modeling.

### Preprocessing
Implemented a production-grade pipeline using:

- `ColumnTransformer` combining numeric and categorical transformations
- `StandardScaler` for numerical features
- `OneHotEncoder` with `handle_unknown='ignore'` for categorical features
- `Stratified 5-Fold Cross Validation` on training data only
- Class imbalance handling via `class_weight='balanced'`

> **Note:** `Customer_ID`, `Churn_Category`, and `Churn_Reason` were excluded from features. The latter two are post-event labels not available at prediction time — including them would cause data leakage.

### Models Evaluated

**Logistic Regression (Baseline)**
- CV ROC-AUC: 0.8786 ± 0.0038
- Test ROC-AUC: 0.886
- Accuracy: 79%

**Random Forest (Final Model)**
- CV ROC-AUC: 0.9011 ± 0.0059
- Test ROC-AUC: 0.899
- Accuracy: 84%

Random Forest demonstrated stronger discriminatory power and improved recall balance, and was selected as the final model.

---

## 6. Churn Scoring & Risk Segmentation

The final model was applied to newly joined customers (411 records). Each customer received a churn probability score and a risk category:

| Risk Category | Probability Threshold |
|---|---|
| High Risk | ≥ 0.80 |
| Medium Risk | 0.50 – 0.79 |
| Low Risk | < 0.50 |

### Results

| Metric | Value |
|---|---|
| Total new customers analyzed | 411 |
| High-risk customers identified | 282 |
| High-risk percentage | 68.61% |

### Why Is the High-Risk Percentage So High?

The high-risk concentration is explained by structural characteristics in the new-customer dataset:

- 100% of high-risk customers are on **Month-to-Month contracts**
- Average tenure among high-risk customers ≈ **15 months**
- Early-tenure + flexible contracts historically correlate with churn in training data

> **Important:** This does NOT mean 68% will churn. It means 68% have risk characteristics similar to past churners. The probability score is a **prioritization tool**, not a deterministic outcome.

---

## 7. Business Recommendations

1. Offer discounted 12-month contract upgrades to high-risk Month-to-Month customers
2. Launch targeted retention campaigns for top 20% highest probability customers
3. Provide loyalty incentives within first 12–18 months of tenure
4. Integrate churn scoring into CRM for monthly monitoring
5. A/B test retention offers to measure ROI impact

---

## 8. Power BI Dashboard

Developed a 3-page interactive dashboard:

**Page 1 — Summary**
- KPI cards: Total Customers (6,418), New Joiners (411), Total Churn (1,732), Churn Rate (27%)
- Churn by gender, age group, tenure group, contract, payment method
- Geographic distribution (Top 5 states)
- Churn by internet type and services used
- Slicers: Monthly Charge Range, Marital Status

**Page 2 — Churn Reason Analysis**
- Bar chart of all churn reasons ranked by volume
- Donut chart showing churn category breakdown (Competitor 43.9%, Attitude 17.4%, Dissatisfaction 17.3%, Price 11.3%)

**Page 3 — High Risk Joiners Prediction**
- ML model output integrated directly into dashboard
- Customer-level table with Churn Probability, Risk Category, Contract, Tenure
- Demographic breakdown of high-risk segment (age, marital status, tenure, payment method, state)
- High Risk Customers KPI: 282

---

## 9. Limitations

- No hyperparameter tuning beyond baseline configuration
- No SHAP or model explainability visualization implemented
- No financial impact simulation performed
- Model trained on historical snapshot; real-world performance may vary
- `State` column included as a feature (~28 categories) — may introduce dimensionality noise

---

## 10. Next Steps

- Hyperparameter tuning (GridSearchCV / RandomizedSearchCV)
- Gradient Boosting / XGBoost comparison
- SHAP-based feature explainability
- Retention ROI simulation
- API deployment (FastAPI / Flask)
- Automated monthly batch scoring pipeline

---

## Conclusion

This project demonstrates an end-to-end churn analytics workflow integrating:

- **SQL-based data engineering** (NULL audit, transformation, view creation)
- **Machine learning pipelines** (preprocessing, cross-validation, model comparison)
- **Risk segmentation** (probability scoring, tiered categorization)
- **Business intelligence reporting** (3-page interactive Power BI dashboard)

The solution provides probabilistic churn estimation and actionable segmentation to support data-driven retention strategies.

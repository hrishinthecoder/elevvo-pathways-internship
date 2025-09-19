# Customer Segmentation Using RFM Analysis

## 📌 Overview
This project applies **RFM (Recency, Frequency, Monetary)** analysis to an Online Retail–style dataset in order to segment customers into actionable groups for marketing and retention strategies.  

The analysis identifies high-value customers, loyal buyers, at-risk segments, and inactive users, enabling businesses to **prioritize resources, improve retention, and grow Customer Lifetime Value (CLV).**

---

## 📂 Project Structure
- **`online_retail_synthetic.csv`** — Synthetic Online Retail dataset (26k+ transactions, ~2k customers).
- **`online_retail_rfm.csv`** — Per-customer RFM metrics, scores, and assigned segment.
- **`RFM_Customer_Segmentation.ipynb`** — Jupyter Notebook (clean, step-by-step workflow).
- **`RFM_Customer_Segmentation_Executed.ipynb`** — Executed Notebook (with outputs).
- **`RFM_Project_Report.docx`** — Word report (overview, methodology, insights, marketing recommendations).
- **`LinkedIn_Post.txt`** — Short, portfolio-ready post for social sharing.
- **Plots (`/plots`)** — Visualizations (segment counts, heatmap of R–F vs M, revenue by segment).

---

## ⚙️ Methodology
1. **Data Preparation**
   - Cleaned dataset (removed invalid/cancelled transactions).
   - Computed transaction value (`Quantity × UnitPrice`).

2. **RFM Feature Engineering**
   - **Recency**: Days since last purchase.
   - **Frequency**: Number of unique invoices.
   - **Monetary**: Total spend.

3. **Scoring**
   - Assigned 1–5 quintile scores for each RFM dimension.
   - Recency reversed (recent = higher score).

4. **Segmentation**
   - Rule-based mapping of RFM scores into groups:
     - Champions, Loyal Customers, Potential Loyalists, Recent, Promising, At Risk, Can’t Lose Them, Hibernating, Lost.

5. **Visualization**
   - Segment distribution (count).
   - Heatmap of Monetary by Recency × Frequency.
   - Revenue contribution by segment.

---

## 📊 Key Insights
- **Champions & Loyal Customers** drive a large share of revenue.
- **Potential Loyalists** show high promise and should be nurtured with cross/upsell.
- **At Risk / Can’t Lose Them** require win-back campaigns to prevent churn.
- **Hibernating / Lost** customers should be addressed with low-cost re-engagement or feedback collection.

---

## 🎯 Marketing Recommendations
- **Champions** → VIP tiers, exclusives, concierge support.  
- **Loyal Customers** → Rewards, referrals, bundles.  
- **Potential Loyalists** → Onboarding, targeted offers.  
- **At Risk** → Time-limited discounts, abandonment emails.  
- **Hibernating/Lost** → Low-cost channels, occasional nudges, feedback.  

---

## 🛠️ Tech Stack
- **Languages/Tools**: Python, Jupyter Notebook
- **Libraries**: pandas, numpy, matplotlib, seaborn (optional)
- **Documentation**: Word Report, README
- **Visualization**: Matplotlib charts, exportable images

---

## 🚀 How to Run
1. Clone/download this repo.  
2. Install dependencies:
   ```bash
   pip install pandas numpy matplotlib seaborn notebook

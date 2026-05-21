### 1. SQL Data Structuring
* Wrote optimized SQL scripts to segment raw data tables, filtering and grouping production assets by operational metadata (`brand`, `country_of_origin`, `market_segment`).
* Implemented aggregated queries to cross-reference customer satisfaction metrics against financial metrics (`annual_sales_units`), ensuring a highly reliable data schema prior to feeding the ML pipeline.

### 2. Python EDA & Machine Learning Pipeline
* **Data Cleansing:** Implemented missing-value treatments and outlier detection strategies across 2,000 unique records.
* **Pipeline Automation:** Engineered an automated `ColumnTransformer` architecture that standardizes numeric features (`battery_capacity_kwh`, `range_miles`, `horsepower`, etc.) using `StandardScaler` and dynamically encodes high-cardinality categorical strings (`brand`, `model`, `variant`) via `OneHotEncoder`.
* **Model Benchmarking:** Evaluated five distinct regression architectures using a strict 80/20 train-test split.

### 3. Power BI Business Intelligence Dashboard
* Created cross-functional visualization layouts depicting global EV market distributions across Luxury, Premium, and Mid-range segments.
* Combined operational vehicle characteristics (battery capacity vs range efficiency) alongside financial summaries (annual sales units, regional origins) into a centralized reporting matrix.

---

## 📊 Machine Learning Model Comparison & Results

During initial pipeline tests, standard unregularized **Linear Regression** collapsed entirely ($R^2 < 0$) due to extreme multicollinearity introduced by high-cardinality vehicle model dummy variables. Incorporating L2 regularization (**Ridge Regression**) stabilized coefficients and yielded exceptional baseline performance.

Ultimately, non-linear tree ensembles proved to be superior, indicating that EV prices follow tight, non-linear feature interactions:

| Model Architecture | MAE (USD) | RMSE (USD) | $R^2$ Score (Variance Explained) |
| :--- | :---: | :---: | :---: |
| 🏆 **Random Forest Regressor** | **$4,723.04** | **$7,550.45** | **0.9500 (95.0%)** |
| 🥈 **Gradient Boosting Regressor** | $5,443.32 | $7,580.37 | 0.9496 (94.9%) |
| 🥉 **Ridge Regression (L2 Regularized)** | $6,558.44 | $9,454.12 | 0.9216 (92.1%) |
| 📊 **Decision Tree Regressor** | $5,358.46 | $10,742.55 | 0.8988 (89.8%) |
| ❌ *Linear Regression (Unregularized)* | *Extremely Large* | *Extremely Large* | *Negative / Overfitted* |

### Key Takeaways:
* **Top Model:** The **Random Forest Regressor** achieved peak accuracy, explaining **95.0%** of the pricing variance on completely unseen data, with an average prediction error of just **~$4,723 (MAE)**.
* **Feature Importance:** Battery capacity (`battery_capacity_kwh`), horsepower, and premium market segment classifications ranked highest during structural feature importance evaluations.

---

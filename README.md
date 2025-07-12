# 2024–2025 Master's Thesis: Did the 2021 Child Tax Credit Ease Mental Health Woes?

This repository contains the Stata code and final paper for my dual-degree Master’s thesis at Georgetown University, examining whether the expanded 2021 Child Tax Credit (CTC) reduced household anxiety using a Difference-in-Differences framework and event study regressions.

## Research Summary

- **Research Question**: Did eligibility for or receipt of the 2021 CTC reduce self-reported anxiety among U.S. households?
- **Approach**: I use microdata from the Household Pulse Survey (HPS) and apply a Difference-in-Differences (DiD) approach with event study extensions.
- **Outcome**: Binary anxiety indicator (derived from a 4-category HPS variable)
- **Treatment**: Eligibility or receipt of the CTC, defined using child age, birth year, and self-reported receipt during the post-period
- **Result**: CTC eligibility is associated with a modest increase in anxiety at the population level, potentially reflecting economic volatility and mental health strain during the policy period. However, subgroup analysis reveals that **vulnerable households**—such as **low-income**, **non-college-educated**, and **single-parent** households—experienced a **less severe increase in anxiety**, suggesting the CTC may have offered **partial psychological relief** for those most in need.

## Data Scope

- **Source**: U.S. Census Bureau’s Household Pulse Survey (HPS)
- **Period Used**: **Weeks 28–41**, capturing pre- and post-periods around the CTC advance payments.

## Repository Structure

| File                                 | Description |
|--------------------------------------|-------------|
| `Do-Thesis_Regression Analysis_4.13(b).do` | Stata regression script |
| `Do-Thesis_Visualizations (4.27).do`       | Stata visualizations script |
| `Cantu, Nissishalom - Thesis.pdf`          | Final thesis PDF |
| *(No data files included)*           | Source data omitted due to size and licensing |

## Note on Data Availability

The final `.dta` files (`HPS_Final_Data III.dta` and `HPS_Final_Data IV.dta`) used in this analysis are **not included** in this repository due to GitHub size restrictions and licensing considerations.

All data are derived from the U.S. Census Bureau’s **Household Pulse Survey (HPS)**, which is publicly available. You can access the original survey datasets here:

🔗 https://www.census.gov/data/experimental-data-products/household-pulse-survey.html

If you're seeking to reproduce the analysis, I recommend starting with the HPS microdata and adapting the included `.do` files.

## Methods Summary

- **Software**: Stata 18
- **Techniques**:
  - Difference-in-Differences (DiD) regression
  - Event study using interaction terms
  - Subgroup analyses (by education, income, household structure)
- **Controls**: Demographics, time fixed effects, household characteristics

## Author

**Nissi Cantu**  
Master of Public Policy & Master of Business Administration  
Georgetown University  
📧 nc809@georgetown.edu  
🔗 [LinkedIn](https://www.linkedin.com/in/nissi-cantu/)

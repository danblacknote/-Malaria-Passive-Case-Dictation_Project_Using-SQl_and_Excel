 Overview

This project contains the data analysis workflow for the ICEMR Ethiopian Project at the Gambella Site (Abobo Catholic Health Center). It covers data exploration, cleaning, transformation, and statistical analysis of 7,847 malaria cases collected during 2025–2026.

Author: Mr. Deneke Zewdu
Date: October 2026

 What We Did
 1. Data Exploration
- Loaded the raw CSV dataset into SQL Server
- Checked data types, missing values, and unique values per column
- Identified multi-select fields (symptoms, prevention methods)
- Reviewed data quality issues (implausible ages, family sizes, etc.)

 2. Data Cleaning
- Fixed column names (removed typos, spaces, special characters)
- Handled NULL and 'NA' values
- Converted text columns to numeric where needed
- Verified coding consistency across related variables

 3. Data Transformation
- Encoded multi-select fields into individual categories
- Split space-separated codes into rows using STRING_SPLIT
- Created derived variables (age groups, prevention categories)
- Recoded coded variables (symptoms, occupations, history) into readable labels

 4. Descriptive Analysis

Numerical Summary
- Computed N, Mean ± SD, Median (IQR), Min, Max
- Variables: Age, Family Size, Income, Bednets, Parasite Counts

Categorical Summary
- Computed frequency (N) and percentage (%)
- Variables: Sex, Education, Age Groups, Occupation, Symptoms, Prevention Methods
- Handled multi-select variables with correct denominators

Binary Summary
- Counted Yes/No for bit variables
- Variables: IRS Spray, Bednet Use, Travel History, Family History

 5. Stratified Analysis
- Cross-tabulated variables by Microscopy Result (Positive vs Negative)
- Compared prevention methods, occupation, age, sex between groups
- Calculated positivity rates within each subgroup

 6. Parasite Density Analysis
- Computed Gametocyte to Asexual ratio by species
- Compared ratios across age groups
- Identified transmission reservoir patterns

 7. Statistical Testing
- Chi-square test of independence
- Odds ratios with 95% confidence intervals
- P-values for each association
- Effect size interpretation

 8. Visualization and Reporting
- Seasonal trend charts (2025 and 2026)
- Age, sex, and species distribution charts
- Prevention method usage charts
- PowerPoint summary report

Repository Structure
             ├── README.md
             ├── LICENSE
             ├── .gitignore
             │
             ├── scripts/
             │   ├── 01_data_exploration.sql
             │   ├── 02_data_quality_check.sql
             │   └── 03_statistical_summary.sql
             │
             ├── excel/
             │   └── statistical_calculation.xlsx
             │
             ├── charts/
             │   ├── monthly_2025/
             │   ├── monthly_2026/
             │   ├── comparison_2025_2026/
             │   ├── sex_distribution/
             │   ├── microscopy_result/
             │   ├── species_by_microscopy/
             │   ├── result_by_rdt/
             │   ├── species_by_rdt/
             │   ├── gametocyte_asexual_ratio/
             │   └── gametocyte_asexual_by_age_group/

       
 Tools Used
- SQL Server 2016+ — data storage and querying
- SSMS — SQL Server Management Studio
- Excel 2016 — data preparation
- PowerPoint — final reporting

 How to Use
1. Set up SQL Server 2016 or newer
2. Create the database:
   CREATE DATABASE malaria_study;
3. Import the CSV data using SSMS Import Wizard or BULK INSERT
4. Run the SQL queries in the `sql/` folder in order
5. Export results to Excel for reporting

Contact
        Mr. Deneke Zewdu
        ICEMR Ethiopian Project Data Manager
        Email: danblacknote111@gmail.com
        Phone: +251948956011

 License
MIT License

Data sharing: Raw patient data is not included for confidentiality.

USE your database_name
-- Run once
CREATE VIEW [vw_PCD_Gambella_Analysis] AS
SELECT *
FROM [PCD Gambella]
WHERE [Study_Clinic] NOT IN ('GB_ABOB', 'GB_89C', 'GB_ABC');


/* =====================================================================
   ICEMR Gambella Project — Batch 1: DATA EXPLORATION
   Database : your_database_name
   Source   : [vw_PCD_Gambella_Analysis]   -- already excludes GB_ABOB/GB_89C/GB_ABC
   Purpose  : Understand structure, missingness, distributions,
              and data-quality red flags before cleaning or modeling.
   ===================================================================== */



/* ---------------------------------------------------------------------
   1. STRUCTURE & SIZE
   --------------------------------------------------------------------- */

-- 1.1 Row count
SELECT COUNT(*) AS total_rows
FROM [vw_PCD_Gambella_Analysis];




-- 1.2 Columns and data types
SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH AS max_length,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PCD Gambella'
ORDER BY ORDINAL_POSITION;




-- 1.3 Which clinics are left in the view?
SELECT 
  [Study_Clinic], 
  COUNT(*) AS n
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Study_Clinic]
ORDER BY n DESC;





/* ---------------------------------------------------------------------
   2. MISSINGNESS PER COLUMN
   --------------------------------------------------------------------- */

WITH null_counts AS (
    SELECT
        COUNT(*)                                                              AS total_rows,
        SUM(CASE WHEN [Survey_Date]                IS NULL THEN 1 ELSE 0 END) AS null_SurveyDate,
        SUM(CASE WHEN [Study_Clinic]               IS NULL THEN 1 ELSE 0 END) AS null_StudyClinic,
        SUM(CASE WHEN [MRN_Number]                 IS NULL THEN 1 ELSE 0 END) AS null_MRN,
        SUM(CASE WHEN [Age_Year]                   IS NULL THEN 1 ELSE 0 END) AS null_AgeYear,
        SUM(CASE WHEN [Age_Coded]                  IS NULL THEN 1 ELSE 0 END) AS null_AgeCoded,
        SUM(CASE WHEN [Sex]                        IS NULL THEN 1 ELSE 0 END) AS null_Sex,
        SUM(CASE WHEN [Education]                  IS NULL THEN 1 ELSE 0 END) AS null_Education,
        SUM(CASE WHEN [Occopation]                 IS NULL THEN 1 ELSE 0 END) AS null_Occupation,
        SUM(CASE WHEN [Family_Size]                IS NULL THEN 1 ELSE 0 END) AS null_FamilySize,
        SUM(CASE WHEN [Mosquito_Prevantion_Method] IS NULL THEN 1 ELSE 0 END) AS null_Prevention,
        SUM(CASE WHEN [Number_of_BedNet]           IS NULL THEN 1 ELSE 0 END) AS null_BedNets,
        SUM(CASE WHEN [IRS_Spray_History]          IS NULL THEN 1 ELSE 0 END) AS null_IRS,
        SUM(CASE WHEN [Malaria_Symptoms]           IS NULL THEN 1 ELSE 0 END) AS null_Symptoms,
        SUM(CASE WHEN [Malaria_Positive_History]   IS NULL THEN 1 ELSE 0 END) AS null_MalHist,
        SUM(CASE WHEN [RDT_Result]                 IS NULL THEN 1 ELSE 0 END) AS null_RDT,
        SUM(CASE WHEN [Microscopy_Result]          IS NULL THEN 1 ELSE 0 END) AS null_Microscopy,
        SUM(CASE WHEN [Asexual_Count]              IS NULL THEN 1 ELSE 0 END) AS null_Asexual,
        SUM(CASE WHEN [Gametocyte_Count]           IS NULL THEN 1 ELSE 0 END) AS null_Gameto
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT 'Survey Date'                 AS column_name, null_SurveyDate AS null_count, ROUND(100.0 * null_SurveyDate / total_rows, 2) AS pct_null FROM null_counts
UNION ALL SELECT 'Study Clinic',               null_StudyClinic, ROUND(100.0 * null_StudyClinic / total_rows, 2) FROM null_counts
UNION ALL SELECT 'MRN_Number',                 null_MRN,         ROUND(100.0 * null_MRN         / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Age_Year',                   null_AgeYear,     ROUND(100.0 * null_AgeYear     / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Age_Coded',                  null_AgeCoded,    ROUND(100.0 * null_AgeCoded    / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Sex',                        null_Sex,         ROUND(100.0 * null_Sex         / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Education',                  null_Education,   ROUND(100.0 * null_Education   / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Occopation',                 null_Occupation,  ROUND(100.0 * null_Occupation  / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Family_Size',                null_FamilySize,  ROUND(100.0 * null_FamilySize  / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Mosquito_Prevantion_Method', null_Prevention,  ROUND(100.0 * null_Prevention  / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Number_of_BedNet',           null_BedNets,     ROUND(100.0 * null_BedNets     / total_rows, 2) FROM null_counts
UNION ALL SELECT 'IRS_Spray_History',          null_IRS,         ROUND(100.0 * null_IRS         / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Malaria_Symptoms',           null_Symptoms,    ROUND(100.0 * null_Symptoms    / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Malaria_Positive_History',   null_MalHist,     ROUND(100.0 * null_MalHist     / total_rows, 2) FROM null_counts
UNION ALL SELECT 'RDT-Result',                 null_RDT,         ROUND(100.0 * null_RDT         / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Microscopy_Result',          null_Microscopy,  ROUND(100.0 * null_Microscopy  / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Asexual Count',              null_Asexual,     ROUND(100.0 * null_Asexual     / total_rows, 2) FROM null_counts
UNION ALL SELECT 'Gametocyte Count',           null_Gameto,      ROUND(100.0 * null_Gameto      / total_rows, 2) FROM null_counts
ORDER BY pct_null DESC;




/* ---------------------------------------------------------------------
   3. DISTRIBUTIONS OF KEY CATEGORICAL VARIABLES
   --------------------------------------------------------------------- */

-- 3.1 Sex
SELECT [Sex] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Sex]
ORDER BY n DESC;



-- 3.2 Education (raw codes)
SELECT [Education] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Education]
ORDER BY n DESC;



-- 3.3 Occupation (raw codes)
SELECT [Occopation] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Occopation]
ORDER BY n DESC;



-- 3.4 Age_Coded
SELECT [Age_Coded] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Age_Coded]
ORDER BY n DESC;



-- 3.5 Microscopy result
SELECT [Microscopy_Result] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Microscopy_Result]
ORDER BY n DESC;





-- 3.6 RDT result
SELECT [RDT_Result] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [RDT_Result]
ORDER BY n DESC;




-- 3.7 Species by microscopy (raw)
SELECT [Specec_by_Microscopy] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Specec_by_Microscopy]
ORDER BY n DESC;




-- 3.8 IRS spray history
SELECT [IRS_Spray_History] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [IRS_Spray_History]
ORDER BY n DESC;



-- 3.9 Malaria positive history
SELECT [Malaria_Positive_History] AS value, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Malaria_Positive_History]
ORDER BY n DESC;



/* ---------------------------------------------------------------------
   4. NUMERIC VARIABLE SUMMARY
   --------------------------------------------------------------------- */
WITH numeric_summary AS (
    SELECT 'Age_Year' AS variable,
           COUNT([Age_Year])                  AS n,
           MIN([Age_Year])                    AS min_,
           MAX([Age_Year])                    AS max_,
           ROUND(AVG(CAST([Age_Year] AS FLOAT)), 3)    AS mean_,
           ROUND(STDEV(CAST([Age_Year] AS FLOAT)), 3)  AS sd_
    FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Age_Month',
           COUNT([Age_Month]), MIN([Age_Month]), MAX([Age_Month]),
           ROUND(AVG(CAST([Age_Month] AS FLOAT)), 3),
           ROUND(STDEV(CAST([Age_Month] AS FLOAT)), 3)
    FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Family_Size',
           COUNT([Family_Size]), MIN([Family_Size]), MAX([Family_Size]),
           ROUND(AVG(CAST([Family_Size] AS FLOAT)), 3),
           ROUND(STDEV(CAST([Family_Size] AS FLOAT)), 3)
    FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Number_of_BedNet',
           COUNT([Number_of_BedNet]), MIN([Number_of_BedNet]), MAX([Number_of_BedNet]),
           ROUND(AVG(CAST([Number_of_BedNet] AS FLOAT)), 3),
           ROUND(STDEV(CAST([Number_of_BedNet] AS FLOAT)), 3)
    FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Asexual Count',
           COUNT([Asexual Count]), MIN([Asexual Count]), MAX([Asexual Count]),
           ROUND(AVG(CAST([Asexual Count] AS FLOAT)), 3),
           ROUND(STDEV(CAST([Asexual Count] AS FLOAT)), 3)
    FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Gametocyte Count',
           COUNT([Gametocyte Count]), MIN([Gametocyte Count]), MAX([Gametocyte Count]),
           ROUND(AVG(CAST([Gametocyte Count] AS FLOAT)), 3),
           ROUND(STDEV(CAST([Gametocyte Count] AS FLOAT)), 3)
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT variable, n, min_, max_, mean_, sd_
FROM numeric_summary
ORDER BY variable;





/* ---------------------------------------------------------------------
   5. DATA-QUALITY RED FLAGS
   --------------------------------------------------------------------- */

-- 5.1 Duplicate MRN numbers
SELECT [MRN_Number], COUNT(*) AS times_seen,
       MIN([Survey Date]) AS first_date,
       MAX([Survey Date]) AS last_date
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [MRN_Number]
HAVING COUNT(*) > 1
ORDER BY times_seen DESC;




-- 5.2 Duplicate (MRN + Survey Date) pairs
SELECT [MRN_Number], [Survey Date], COUNT(*) AS times_seen
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [MRN_Number], [Survey Date]
HAVING COUNT(*) > 1
ORDER BY times_seen DESC;




-- 5.3 Survey dates outside 2023–2027
SELECT [MRN_Number], [Survey Date], [Study Clinic]
FROM [vw_PCD_Gambella_Analysis]
WHERE YEAR([Survey Date]) NOT BETWEEN 2023 AND 2027
   OR [Survey Date] IS NULL;


/* ---------------------------------------------------------------------
   6. DATE COVERAGE & MONTHLY DISTRIBUTION
   --------------------------------------------------------------------- */

SELECT
    MIN([Survey Date])                   AS earliest_survey,
    MAX([Survey Date])                   AS latest_survey,
    COUNT(DISTINCT YEAR([Survey Date]))  AS distinct_years,
    COUNT(DISTINCT MONTH([Survey Date])) AS distinct_months
FROM [vw_PCD_Gambella_Analysis];

-- Monthly counts by year
SELECT
    YEAR([Survey Date])  AS yr,
    MONTH([Survey Date]) AS mo,
    COUNT(*)             AS n_cases
FROM [vw_PCD_Gambella_Analysis]
WHERE [Survey Date] IS NOT NULL
GROUP BY YEAR([Survey Date]), MONTH([Survey Date])
ORDER BY yr, mo;


/* ---------------------------------------------------------------------
   7. OUTCOME VARIABLES
   --------------------------------------------------------------------- */

-- 7.1 Microscopy breakdown
SELECT
    [Microscopy_Result]                                         AS result,
    COUNT(*)                                                    AS n,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)          AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Microscopy_Result]
ORDER BY n DESC;

-- 7.2 RDT breakdown
SELECT
    [RDT-Result]                                                AS result,
    COUNT(*)                                                    AS n,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)          AS pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [RDT-Result]
ORDER BY n DESC;

-- 7.3 Microscopy × RDT agreement
SELECT
    [Microscopy_Result] AS microscopy,
    [RDT-Result]        AS rdt,
    COUNT(*)            AS n
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Microscopy_Result], [RDT-Result]
ORDER BY microscopy, rdt;

/* ============================================================================
   PCD Gambella — Malaria Prevalence & Risk Factor Analysis
   ----------------------------------------------------------------------------
   View     : vw_PCD_Gambella_Analysis
   Outcome  : Microscopy_Result ('P' = Positive, 'N' = Negative)
   Scope    : Descriptive statistics, cross-tabs, and bivariate analyses
              of malaria positivity against demographic, clinical,
              exposure, and preventive variables.
   Sections : 24 analytical blocks (clinic, year/month, numeric summaries,
              binaries, categories, outcomes, age/sex/occupation,
              prevention methods, history variables, gametocyte ratios)
   Author   : [Your Name]     Version: 1.0     Updated: [Date]
   ============================================================================ */



USE [your database_name]
SELECT 
  [Study_Clinic],
  [Microscopy_Result],
  COUNT(*) AS n
FROM [vw_PCD_Gambella_Analysis]
WHERE [Microscopy_Result] IN ('P','N')
GROUP BY [Study_Clinic],
         [Microscopy_Result]
ORDER BY n DESC;





---Total Case By Year 
SELECT 
  YEAR([Survey_Date]) AS Survey_Date,
  COUNT(*)  AS n
FROM [vw_PCD_Gambella_Analysis]
GROUP BY YEAR([Survey_Date])
ORDER BY YEAR([Survey_Date]) ASC;







---Total Case By Year 
SELECT 
  YEAR([Survey_Date]) AS Survey_Year,
  MONTH([Survey_Date]) AS Survey_Month,
  [Microscopy_Result]  AS Mic_Result,
  COUNT(*)  AS n
FROM [vw_PCD_Gambella_Analysis]
WHERE [Microscopy_Result] IN ('P','N')
GROUP BY MONTH([Survey_Date]),
         YEAR([Survey_Date]),
         [Microscopy_Result]
ORDER BY YEAR([Survey_Date]),
          MONTH([Survey_Date]) ASC;






-- ============================================
-- NUMERIC VARIABLES — Mean ± SD, Median (IQR), Min, Max
-- ============================================
WITH UnpivotedData AS (
    SELECT 'Age_Year' AS Variable, CAST([Age_Year] AS FLOAT) AS Value FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Age_Month', CAST([Age_Month] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Family_Size', CAST([Family_Size] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Number_of_BedNet', CAST([Number_of_BedNet] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Number_of_Days_Slept_Under_BadNet', 
           CAST([Number_of_Days_Slept_Under_BadNet] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Avrg_Monthly_Income', 
           TRY_CAST([Avrg_Monthly_Income] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Asexual_Count', 
           TRY_CAST([Asexual_Count] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL
    SELECT 'Gametocyte_Count', 
           TRY_CAST([Gametocyte_Count] AS FLOAT) FROM [vw_PCD_Gambella_Analysis]
),
Stats AS (
    SELECT 
        Variable,
        COUNT(Value)                          AS N,
        AVG(Value)                            AS Mean,
        STDEV(Value)                          AS SD,
        MIN(Value)                            AS Min,
        MAX(Value)                            AS Max,
        MAX(Median)                           AS Median,
        MAX(Q1)                               AS Q1,
        MAX(Q3)                               AS Q3,
        MAX(Q3) - MAX(Q1)                     AS IQR
    FROM (
        SELECT 
            Variable, Value,
            PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Value) 
                OVER (PARTITION BY Variable) AS Median,
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Value) 
                OVER (PARTITION BY Variable) AS Q1,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Value) 
                OVER (PARTITION BY Variable) AS Q3
        FROM UnpivotedData
        WHERE Value IS NOT NULL
    ) x
    GROUP BY Variable
)
SELECT 
    Variable,
    N,
    CAST(Mean AS DECIMAL(12,2))   AS Mean,
    CAST(SD AS DECIMAL(12,2))     AS SD,
    CAST(Min AS DECIMAL(12,2))    AS [Min],
    CAST(Max AS DECIMAL(12,2))    AS [Max],
    CAST(Median AS DECIMAL(12,2)) AS Median,
    CAST(IQR AS DECIMAL(12,2))    AS IQR,
    CAST(CAST(Mean AS DECIMAL(12,2)) AS VARCHAR) + ' ± ' 
        + CAST(CAST(SD AS DECIMAL(12,2)) AS VARCHAR)         AS [Mean ± SD],
    CAST(CAST(Median AS DECIMAL(12,2)) AS VARCHAR) + ' (' 
        + CAST(CAST(Q1 AS DECIMAL(12,2)) AS VARCHAR) + '–' 
        + CAST(CAST(Q3 AS DECIMAL(12,2)) AS VARCHAR) + ')'   AS [Median (IQR)],
    CAST(CAST(Min AS DECIMAL(12,2)) AS VARCHAR) + '–' 
        + CAST(CAST(Max AS DECIMAL(12,2)) AS VARCHAR)        AS [Min–Max]
FROM Stats
ORDER BY 
    CASE Variable
        WHEN 'Age_Year' THEN 1
        WHEN 'Age_Month' THEN 2
        WHEN 'Family_Size' THEN 3
        WHEN 'Number_of_BedNet' THEN 4
        WHEN 'Number_of_Days_Slept_Under_BadNet' THEN 5
        WHEN 'Avrg_Monthly_Income' THEN 6
        WHEN 'Asexual_Count' THEN 7
        WHEN 'Gametocyte_Count' THEN 8
    END;








-- ============================================
-- Categorical/BINARY VARIABLES — Count 0/1
-- ============================================
SELECT 'Family_Travel_History' AS Variable,
       SUM(CASE WHEN [Family_Travel_History] = 1 THEN 1 ELSE 0 END) AS Yes_N,
       SUM(CASE WHEN [Family_Travel_History] = 0 THEN 1 ELSE 0 END) AS No_N,
       COUNT(*) AS Total
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'Family_Diagnostic_History',
       SUM(CASE WHEN [Family_Diagnostic_History] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [Family_Diagnostic_History] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'Malaria_Positive_History',
       SUM(CASE WHEN [Malaria_Positive_History] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [Malaria_Positive_History] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'Badnet_Hole',
       SUM(CASE WHEN [Badnet_Hole] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [Badnet_Hole] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'Sleap_Under_BadNet',
       SUM(CASE WHEN [Sleap_Under_BadNet] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [Sleap_Under_BadNet] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'IRS_Spray_History',
       SUM(CASE WHEN [IRS_Spray_History] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [IRS_Spray_History] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis]
UNION ALL
SELECT 'Kitchen_Garden_Avalibility',
       SUM(CASE WHEN [Kitchen_Garden_Avalibility] = 1 THEN 1 ELSE 0 END),
       SUM(CASE WHEN [Kitchen_Garden_Avalibility] = 0 THEN 1 ELSE 0 END),
       COUNT(*)
FROM [vw_PCD_Gambella_Analysis];







-- ============================================
-- CATEGORICAL VARIABLES — Frequency + %
-- Shows all categories with % of total N
-- ============================================
WITH CatData AS (
    SELECT 'Sex' AS Variable, CAST([Sex] AS NVARCHAR(255)) AS Category FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Village', CAST([Village] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Education', CAST([Education] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'RDT_Result', CAST([RDT_Result] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Microscopy_Result', CAST([Microscopy_Result] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Specec_by_RDT', CAST([Specec_by_RDT] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Specec_by_Microscopy', CAST([Specec_by_Microscopy] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Travel_History', CAST([Travel_History] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Farming_Paractice', CAST([Farming_Paractice] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'NerBy_Mosquito_Habitate', CAST([NerBy_Mosquito_Habitate] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Study_Clinic', CAST([Study_Clinic] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
    UNION ALL SELECT 'Site', CAST([Site] AS NVARCHAR(255)) FROM [vw_PCD_Gambella_Analysis]
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    c.Variable,
    c.Category,
    COUNT(*) AS N,
    CAST(COUNT(*) * 100.0 / T.Total_N AS DECIMAL(5,2)) AS Pct
FROM CatData c
CROSS JOIN TotalPatients T
GROUP BY c.Variable, c.Category, T.Total_N
ORDER BY 
    c.Variable,
    COUNT(*) DESC;








-- ============================================
-- KEY OUTCOMES — RDT and Microscopy Results
-- ============================================
SELECT 'RDT Result' AS Test, 
       [RDT_Result] AS Result, 
       COUNT(*) AS N,
       CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [vw_PCD_Gambella_Analysis]) 
            AS DECIMAL(5,2)) AS Pct
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [RDT_Result]

UNION ALL

SELECT 'Microscopy Result', 
       [Microscopy_Result], 
       COUNT(*),
       CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [vw_PCD_Gambella_Analysis]) 
            AS DECIMAL(5,2))
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Microscopy_Result]

ORDER BY Test, N DESC;






-- ============================================
-- Age Categories — Simple Count and Percentage
-- ============================================
WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN [Age_Year] < 5                  THEN '1. < 5 years'
            WHEN [Age_Year] BETWEEN 5 AND 14     THEN '2. 5-14 years'
            WHEN [Age_Year] BETWEEN 15 AND 24    THEN '3. 15-24 years'
            WHEN [Age_Year] BETWEEN 25 AND 44    THEN '4. 25-44 years'
            WHEN [Age_Year] BETWEEN 45 AND 59    THEN '5. 45-59 years'
            WHEN [Age_Year] >= 60                THEN '6. >= 60 years'
            ELSE '7. Unknown'
        END AS Age_Group
    FROM [vw_PCD_Gambella_Analysis]
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    Age_Group,
    COUNT(*) AS N,
    CAST(COUNT(*) * 100.0 / T.Total_N AS DECIMAL(5,2)) AS Percentage
FROM AgeGroups
CROSS JOIN TotalPatients T
GROUP BY Age_Group, T.Total_N
ORDER BY Age_Group;







-- ============================================
-- Age Categories vs Microscopy Result (P vs N)
-- ============================================
WITH AgeGroups AS (
    SELECT 
        [Microscopy_Result],
        CASE 
            WHEN [Age_Year] < 5                  THEN '1. < 5 years'
            WHEN [Age_Year] BETWEEN 5 AND 14     THEN '2. 5-14 years'
            WHEN [Age_Year] BETWEEN 15 AND 24    THEN '3. 15-24 years'
            WHEN [Age_Year] BETWEEN 25 AND 44    THEN '4. 25-44 years'
            WHEN [Age_Year] BETWEEN 45 AND 59    THEN '5. 45-59 years'
            WHEN [Age_Year] >= 60                THEN '6. >= 60 years'
            ELSE '7. Unknown'
        END AS Age_Group
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
MicroscopyTotals AS (
    SELECT 
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_Total,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_Total
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    a.Age_Group,
    SUM(CASE WHEN a.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN a.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN a.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(M.Pos_Total, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct,
    CAST(
        SUM(CASE WHEN a.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(M.Neg_Total, 0) 
    AS DECIMAL(5,2)) AS Neg_Pct
FROM AgeGroups a
CROSS JOIN MicroscopyTotals M
GROUP BY a.Age_Group, M.Pos_Total, M.Neg_Total
ORDER BY 
    CASE a.Age_Group
        WHEN '1. < 5 years' THEN 1
        WHEN '2. 5-14 years' THEN 2
        WHEN '3. 15-24 years' THEN 3
        WHEN '4. 25-44 years' THEN 4
        WHEN '5. 45-59 years' THEN 5
        WHEN '6. >= 60 years' THEN 6
        WHEN '7. Unknown' THEN 7
        ELSE 99
    END;








-- ============================================
-- Malaria Symptoms — Count & % (Sorted by N DESC)
-- ============================================
WITH SplitSymptoms AS (
    SELECT 
        [MRN_Number],
        TRIM(value) AS Symptom
    FROM [vw_PCD_Gambella_Analysis]
    CROSS APPLY STRING_SPLIT([Malaria_Symptoms], ' ')
    WHERE [Malaria_Symptoms] IS NOT NULL
      AND TRIM(value) <> ''
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    s.Symptom AS Code,
    CASE s.Symptom
        WHEN 'X' THEN 'None'
        WHEN 'A' THEN 'Fever'
        WHEN 'B' THEN 'Chills/Shivering'
        WHEN 'C' THEN 'Malaise'
        WHEN 'D' THEN 'Fatigue'
        WHEN 'E' THEN 'Muscle pain'
        WHEN 'F' THEN 'Joint pain'
        WHEN 'G' THEN 'Headache'
        WHEN 'H' THEN 'Irritability'
        WHEN 'I' THEN 'Nausea'
        WHEN 'K' THEN 'Vomiting'
        WHEN 'M' THEN 'Diarrhea'
        WHEN 'O' THEN 'Abdomen pains'
        WHEN 'P' THEN 'Loss of appetite'
        WHEN 'R' THEN 'Breathing difficulty'
        WHEN 'S' THEN 'Dizziness'
        WHEN 'T' THEN 'Coughing'
        WHEN 'U' THEN 'Stomachache'
        WHEN 'W' THEN 'Sweating'
        WHEN 'Z' THEN 'Others'
        ELSE 'Unknown: ' + s.Symptom
    END AS Symptom,
    COUNT(DISTINCT s.[MRN_Number]) AS N,
    CAST(
        COUNT(DISTINCT s.[MRN_Number]) * 100.0 / T.Total_N 
    AS DECIMAL(5,2)) AS Percentage
FROM SplitSymptoms s
CROSS JOIN TotalPatients T
GROUP BY s.Symptom, T.Total_N
ORDER BY N DESC;      







-- ============================================
-- Malaria Symptoms vs Microscopy Result
-- Sorted by Micro_Pos_N DESC
-- ============================================
WITH SplitSymptoms AS (
    SELECT 
        [MRN_Number],
        [Microscopy_Result],
        TRIM(value) AS Symptom
    FROM [vw_PCD_Gambella_Analysis]
    CROSS APPLY STRING_SPLIT([Malaria_Symptoms], ' ')
    WHERE [Malaria_Symptoms] IS NOT NULL
      AND TRIM(value) <> ''
      AND [Microscopy_Result] IN ('P','N')
),
MicroscopyTotals AS (
    SELECT 
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_Total,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_Total
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    s.Symptom AS Code,
    CASE s.Symptom
        WHEN 'X' THEN 'None'
        WHEN 'A' THEN 'Fever'
        WHEN 'B' THEN 'Chills/Shivering'
        WHEN 'C' THEN 'Malaise'
        WHEN 'D' THEN 'Fatigue'
        WHEN 'E' THEN 'Muscle pain'
        WHEN 'F' THEN 'Joint pain'
        WHEN 'G' THEN 'Headache'
        WHEN 'H' THEN 'Irritability'
        WHEN 'I' THEN 'Nausea'
        WHEN 'K' THEN 'Vomiting'
        WHEN 'M' THEN 'Diarrhea'
        WHEN 'O' THEN 'Abdomen pains'
        WHEN 'P' THEN 'Loss of appetite'
        WHEN 'R' THEN 'Breathing difficulty'
        WHEN 'S' THEN 'Dizziness'
        WHEN 'T' THEN 'Coughing'
        WHEN 'U' THEN 'Stomachache'
        WHEN 'W' THEN 'Sweating'
        WHEN 'Z' THEN 'Others'
        ELSE 'Unknown: ' + s.Symptom
    END AS Symptom,
    COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                        THEN s.[MRN_Number] END) AS Micro_Pos_N,
    COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                        THEN s.[MRN_Number] END) AS Micro_Neg_N,
    CAST(
        COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                            THEN s.[MRN_Number] END) * 100.0 
        / NULLIF(M.Pos_Total, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct,
    CAST(
        COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                            THEN s.[MRN_Number] END) * 100.0 
        / NULLIF(M.Neg_Total, 0) 
    AS DECIMAL(5,2)) AS Neg_Pct,
    CAST(
        (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                             THEN s.[MRN_Number] END) * 100.0 
            / NULLIF(M.Neg_Total, 0))
      - (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                             THEN s.[MRN_Number] END) * 100.0 
            / NULLIF(M.Pos_Total, 0))
    AS DECIMAL(5,2)) AS Diff
FROM SplitSymptoms s
CROSS JOIN MicroscopyTotals M
GROUP BY s.Symptom, M.Pos_Total, M.Neg_Total
ORDER BY (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                              THEN s.[MRN_Number] END)
        + COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                              THEN s.[MRN_Number] END)) DESC;






-- ============================================
-- Malaria Prevention Methods — Count & % (Overall)
-- Sorted by N DESC
-- ============================================
WITH SplitPrevention AS (
    SELECT 
        [MRN_Number],
        TRY_CAST(TRIM(value) AS INT) AS Code
    FROM [vw_PCD_Gambella_Analysis]
    CROSS APPLY STRING_SPLIT([Mosquito_Prevantion_Method], ' ')
    WHERE [Mosquito_Prevantion_Method] IS NOT NULL
      AND TRIM(value) <> ''
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    s.Code,
    CASE s.Code
        WHEN 0  THEN 'Do Nothing'
        WHEN 1  THEN 'Use screened windows/doors'
        WHEN 2  THEN 'Use bednet'
        WHEN 3  THEN 'Regular use of commercial sprays'
        WHEN 4  THEN 'Regular use of coils'
        WHEN 5  THEN 'Burn herbs/cow dung'
        WHEN 6  THEN 'Fan'
        WHEN 7  THEN 'Use other commercial repellents'
        WHEN 8  THEN 'Smoking'
        WHEN 9  THEN 'Government IRS (Indoor Residual Spraying)'
        WHEN 10 THEN 'Draining stagnant water'
        WHEN 11 THEN 'Clean up house environment'
        WHEN 99 THEN 'Others'
        ELSE 'Unknown: ' + CAST(s.Code AS VARCHAR)
    END AS Prevention_Method,
    COUNT(DISTINCT s.[MRN_Number]) AS N,
    CAST(
        COUNT(DISTINCT s.[MRN_Number]) * 100.0 / T.Total_N 
    AS DECIMAL(5,2)) AS Percentage
FROM SplitPrevention s
CROSS JOIN TotalPatients T
WHERE s.Code IS NOT NULL
GROUP BY s.Code, T.Total_N
ORDER BY N DESC; 






-- ============================================
-- Malaria Prevention Methods vs Microscopy Result
-- Sorted by Micro_Pos_N + Micro_Neg_N DESC
-- ============================================
WITH SplitPrevention AS (
    SELECT 
        [MRN_Number],
        [Microscopy_Result],
        TRY_CAST(TRIM(value) AS INT) AS Code
    FROM [vw_PCD_Gambella_Analysis]
    CROSS APPLY STRING_SPLIT([Mosquito_Prevantion_Method], ' ')
    WHERE [Mosquito_Prevantion_Method] IS NOT NULL
      AND TRIM(value) <> ''
      AND [Microscopy_Result] IN ('P','N')
),
MicroscopyTotals AS (
    SELECT 
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_Total,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_Total
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    s.Code,
    CASE s.Code
        WHEN 0  THEN 'Do Nothing'
        WHEN 1  THEN 'Use screened windows/doors'
        WHEN 2  THEN 'Use bednet'
        WHEN 3  THEN 'Regular use of commercial sprays'
        WHEN 4  THEN 'Regular use of coils'
        WHEN 5  THEN 'Burn herbs/cow dung'
        WHEN 6  THEN 'Fan'
        WHEN 7  THEN 'Use other commercial repellents'
        WHEN 8  THEN 'Smoking'
        WHEN 9  THEN 'Government IRS (Indoor Residual Spraying)'
        WHEN 10 THEN 'Draining stagnant water'
        WHEN 11 THEN 'Clean up house environment'
        WHEN 99 THEN 'Others'
        ELSE 'Unknown: ' + CAST(s.Code AS VARCHAR)
    END AS Prevention_Method,
    COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                        THEN s.[MRN_Number] END) AS Micro_Pos_N,
    COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                        THEN s.[MRN_Number] END) AS Micro_Neg_N,
    CAST(
        COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                            THEN s.[MRN_Number] END) * 100.0 
        / NULLIF(M.Pos_Total, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct,
    CAST(
        COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                            THEN s.[MRN_Number] END) * 100.0 
        / NULLIF(M.Neg_Total, 0) 
    AS DECIMAL(5,2)) AS Neg_Pct,
    CAST(
        (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                             THEN s.[MRN_Number] END) * 100.0 
            / NULLIF(M.Neg_Total, 0))
      - (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                             THEN s.[MRN_Number] END) * 100.0 
            / NULLIF(M.Pos_Total, 0))
    AS DECIMAL(5,2)) AS Diff_Neg_Minus_Pos,
    CASE 
        WHEN (
            (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                                 THEN s.[MRN_Number] END) * 100.0 
                / NULLIF(M.Neg_Total, 0))
          - (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                                 THEN s.[MRN_Number] END) * 100.0 
                / NULLIF(M.Pos_Total, 0))
        ) >= 5  THEN 'Likely protective '
        WHEN (
            (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                                 THEN s.[MRN_Number] END) * 100.0 
                / NULLIF(M.Neg_Total, 0))
          - (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                                 THEN s.[MRN_Number] END) * 100.0 
                / NULLIF(M.Pos_Total, 0))
        ) <= -5 THEN 'More in positives '
        ELSE 'No clear difference'
    END AS Interpretation
FROM SplitPrevention s
CROSS JOIN MicroscopyTotals M
WHERE s.Code IS NOT NULL
GROUP BY s.Code, M.Pos_Total, M.Neg_Total
ORDER BY (COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'P' 
                              THEN s.[MRN_Number] END)
        + COUNT(DISTINCT CASE WHEN s.[Microscopy_Result] = 'N' 
                              THEN s.[MRN_Number] END)) DESC;







-- ============================================
-- Occupation — Count & % (Overall, DSC Order)
-- [Occopation] is tinyint — single code per patient
-- ============================================
WITH OccupationData AS (
    SELECT 
        CASE [Occopation]
            WHEN 1  THEN 'Farmer/Agricultural worker'
            WHEN 2  THEN 'Trader'
            WHEN 3  THEN 'Office worker/Teacher'
            WHEN 4  THEN 'Student'
            WHEN 5  THEN 'Non-school Child (Age < 15)'
            WHEN 6  THEN 'Government employer'
            WHEN 7  THEN 'Herdsman'
            WHEN 8  THEN 'Fisherman'
            WHEN 9  THEN 'Mining'
            WHEN 10 THEN 'Factory/Construction worker'
            WHEN 11 THEN 'Unemployed'
            WHEN 12 THEN 'Salesperson, Shop Clerk, Server'
            WHEN 13 THEN 'Merchant'
            WHEN 14 THEN 'Housewife/House Keeping'
            WHEN 15 THEN 'Retired'
            WHEN 16 THEN 'Daily worker'
            WHEN 99 THEN 'Others'
            ELSE 'Unknown: ' + CAST([Occopation] AS VARCHAR)
        END AS Occupation
    FROM [vw_PCD_Gambella_Analysis]
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    Occupation,
    COUNT(*) AS N,
    CAST(COUNT(*) * 100.0 / T.Total_N AS DECIMAL(5,2)) AS Percentage
FROM OccupationData
CROSS JOIN TotalPatients T
GROUP BY Occupation, T.Total_N
ORDER BY N DESC;







-- ============================================
-- Occupation vs Microscopy Result (P vs N)
-- Sorted by combined total N DESC
-- ============================================
WITH OccupationData AS (
    SELECT 
        [Microscopy_Result],
        CASE [Occopation]
            WHEN 1  THEN 'Farmer/Agricultural worker'
            WHEN 2  THEN 'Trader'
            WHEN 3  THEN 'Office worker/Teacher'
            WHEN 4  THEN 'Student'
            WHEN 5  THEN 'Non-school Child (Age < 15)'
            WHEN 6  THEN 'Government employer'
            WHEN 7  THEN 'Herdsman'
            WHEN 8  THEN 'Fisherman'
            WHEN 9  THEN 'Mining'
            WHEN 10 THEN 'Factory/Construction worker'
            WHEN 11 THEN 'Unemployed'
            WHEN 12 THEN 'Salesperson, Shop Clerk, Server'
            WHEN 13 THEN 'Merchant'
            WHEN 14 THEN 'Housewife/House Keeping'
            WHEN 15 THEN 'Retired'
            WHEN 16 THEN 'Daily worker'
            WHEN 99 THEN 'Others'
            ELSE 'Unknown: ' + CAST([Occopation] AS VARCHAR)
        END AS Occupation
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
MicroscopyTotals AS (
    SELECT 
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_Total,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_Total
    FROM [vw_PCD_Gambella_Analysis]
)
SELECT 
    o.Occupation,
    SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(M.Pos_Total, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct,
    CAST(
        SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(M.Neg_Total, 0) 
    AS DECIMAL(5,2)) AS Neg_Pct,
    CAST(
        (SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
            / NULLIF(M.Neg_Total, 0))
      - (SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
            / NULLIF(M.Pos_Total, 0))
    AS DECIMAL(5,2)) AS Diff_Neg_Minus_Pos,
    CASE 
        WHEN (
            (SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
                / NULLIF(M.Neg_Total, 0))
          - (SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
                / NULLIF(M.Pos_Total, 0))
        ) >= 5  THEN 'Higher in negatives '
        WHEN (
            (SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
                / NULLIF(M.Neg_Total, 0))
          - (SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
                / NULLIF(M.Pos_Total, 0))
        ) <= -5 THEN 'Higher in positives '
        ELSE 'No clear difference'
    END AS Interpretation
FROM OccupationData o
CROSS JOIN MicroscopyTotals M
GROUP BY o.Occupation, M.Pos_Total, M.Neg_Total
ORDER BY (SUM(CASE WHEN o.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END)
        + SUM(CASE WHEN o.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END)) DESC;







-- ============================================
-- Gametocyte / Asexual Ratio by Species
-- Assumes species stored as numeric codes
-- ============================================
WITH CleanData AS (
    SELECT 
        [Specec_by_Microscopy] AS Species_Code,
        TRY_CAST([Asexual_Count] AS FLOAT)    AS Asexual,
        TRY_CAST([Gametocyte_Count] AS FLOAT) AS Gameto
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] = 'P'        -- ← CHECK THIS VALUE
),
Labeled AS (
    SELECT 
        CASE Species_Code
            WHEN 1 THEN 'P.f'
            WHEN 2 THEN 'P.v'
            WHEN 3 THEN 'Mix'
            WHEN 4 THEN 'P. malariae'
            WHEN 5 THEN 'P. ovale'
            ELSE 'Other: ' + CAST(Species_Code AS VARCHAR)
        END AS Species,
        Asexual,
        Gameto
    FROM CleanData
)
SELECT 
    Species,
    COUNT(*) AS N,
    CAST(AVG(Asexual) AS DECIMAL(18,9)) AS [Mean Asexual],
    CAST(AVG(Gameto) AS DECIMAL(18,9))  AS [Mean Gametocyte],
    CAST(SUM(Gameto) / NULLIF(SUM(Asexual), 0) AS DECIMAL(10,3)) 
        AS [Gametocyte:Asexual Ratio]
FROM Labeled
WHERE Species NOT LIKE 'Other%'
GROUP BY Species
ORDER BY 
    CASE Species
        WHEN 'P.f' THEN 1
        WHEN 'P.v' THEN 2
        WHEN 'Mix' THEN 3
        WHEN 'P. malariae' THEN 4
        WHEN 'P. ovale' THEN 5
    END;








-- ============================================
-- Auto-detect species codes and compute ratio
-- ============================================
SELECT 
    [Specec_by_Microscopy] AS Species_Raw,
    COUNT(*) AS N,
    CAST(AVG(TRY_CAST([Asexual_Count] AS FLOAT)) AS DECIMAL(18,9))    AS [Mean Asexual],
    CAST(AVG(TRY_CAST([Gametocyte_Count] AS FLOAT)) AS DECIMAL(18,9)) AS [Mean Gametocyte],
    CAST(
        SUM(TRY_CAST([Gametocyte_Count] AS FLOAT)) 
        / NULLIF(SUM(TRY_CAST([Asexual_Count] AS FLOAT)), 0) 
    AS DECIMAL(10,3)) AS [Gametocyte:Asexual Ratio]
FROM [vw_PCD_Gambella_Analysis]
WHERE [Microscopy_Result] = 'P'
GROUP BY [Specec_by_Microscopy]
ORDER BY N DESC;








-- ============================================
-- Overall Gametocyte/Asexual Ratio by Age Group
-- ============================================
WITH CleanData AS (
    SELECT 
        CASE 
            WHEN [Age_Year] < 5                  THEN '1. < 5 years'
            WHEN [Age_Year] BETWEEN 5 AND 14     THEN '2. 5-14 years'
            WHEN [Age_Year] BETWEEN 15 AND 24    THEN '3. 15-24 years'
            WHEN [Age_Year] BETWEEN 25 AND 44    THEN '4. 25-44 years'
            WHEN [Age_Year] BETWEEN 45 AND 59    THEN '5. 45-59 years'
            WHEN [Age_Year] >= 60                THEN '6. >= 60 years'
            ELSE '7. Unknown'
        END AS Age_Group,
        TRY_CAST([Asexual_Count] AS FLOAT)    AS Asexual,
        TRY_CAST([Gametocyte_Count] AS FLOAT) AS Gameto
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] = 'P'
)
SELECT 
    Age_Group,
    COUNT(*) AS N,
    CAST(AVG(Asexual) AS DECIMAL(18,9)) AS [Mean Asexual],
    CAST(AVG(Gameto) AS DECIMAL(18,9))  AS [Mean Gametocyte],
    CAST(SUM(Gameto) / NULLIF(SUM(Asexual), 0) AS DECIMAL(10,3)) 
        AS [Gametocyte:Asexual Ratio],
    -- Gametocyte carrier rate
    SUM(CASE WHEN Gameto > 0 THEN 1 ELSE 0 END) AS Gameto_Carriers,
    CAST(
        SUM(CASE WHEN Gameto > 0 THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Carrier_Rate_Pct
FROM CleanData
WHERE Age_Group <> '7. Unknown'
GROUP BY Age_Group
ORDER BY Age_Group;







-- ============================================
-- Microscopy Results by Age Group
-- Wide format: Pos and Neg side by side
-- ============================================
WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN [Age_Year] < 5                  THEN '1. < 5 years'
            WHEN [Age_Year] BETWEEN 5 AND 14     THEN '2. 5-14 years'
            WHEN [Age_Year] BETWEEN 15 AND 24    THEN '3. 15-24 years'
            WHEN [Age_Year] BETWEEN 25 AND 44    THEN '4. 25-44 years'
            WHEN [Age_Year] BETWEEN 45 AND 59    THEN '5. 45-59 years'
            WHEN [Age_Year] >= 60                THEN '6. >= 60 years'
            ELSE '7. Unknown'
        END AS Age_Group,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
TotalPatients AS (
    SELECT COUNT(*) AS Total_N 
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    a.Age_Group,
    -- Raw counts
    SUM(CASE WHEN a.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN a.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    -- Row % (within each age group)
    CAST(
        SUM(CASE WHEN a.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Age,
    CAST(
        SUM(CASE WHEN a.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Neg_Pct_Within_Age
FROM AgeGroups a
GROUP BY a.Age_Group
ORDER BY 
    CASE a.Age_Group
        WHEN '1. < 5 years' THEN 1
        WHEN '2. 5-14 years' THEN 2
        WHEN '3. 15-24 years' THEN 3
        WHEN '4. 25-44 years' THEN 4
        WHEN '5. 45-59 years' THEN 5
        WHEN '6. >= 60 years' THEN 6
        WHEN '7. Unknown' THEN 7
    END;






-- ============================================
-- Microscopy Results by SEX — Count & %
-- ============================================
WITH SexData AS (
    SELECT 
        CASE 
            WHEN [Sex] LIKE 'F%' THEN 'Female'
            WHEN [Sex] LIKE 'M%' THEN 'Male'
            ELSE 'Unknown'
        END AS Sex_Clean,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    s.Sex_Clean AS Sex,
    SUM(CASE WHEN s.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN s.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN s.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Sex,
    CAST(
        SUM(CASE WHEN s.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Neg_Pct_Within_Sex,
    CAST(
        SUM(CASE WHEN s.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos,
    CAST(
        COUNT(*) * 100.0 / NULLIF(T.Total_Tested, 0) 
    AS DECIMAL(5,2)) AS Pct_Of_All_Tested
FROM SexData s
CROSS JOIN Totals T
GROUP BY s.Sex_Clean, T.Total_Pos, T.Total_Tested
ORDER BY 
    CASE s.Sex_Clean
        WHEN 'Female' THEN 1
        WHEN 'Male' THEN 2
        ELSE 3
    END;





-- ============================================
-- Microscopy Results by Prevention Category
-- Counts EVERY mention (not unique patients)
-- ============================================
WITH SplitPrevention AS (
    SELECT 
        [MRN_Number],
        [Microscopy_Result],
        TRY_CAST(TRIM(value) AS INT) AS Code
    FROM [vw_PCD_Gambella_Analysis]
    CROSS APPLY STRING_SPLIT([Mosquito_Prevantion_Method], ' ')
    WHERE [Mosquito_Prevantion_Method] IS NOT NULL
      AND TRIM(value) <> ''
      AND [Microscopy_Result] IN ('P','N')
),
Categorized AS (
    -- No DISTINCT — keep every mention
    SELECT 
        [MRN_Number],
        [Microscopy_Result],
        CASE Code
            WHEN 0  THEN 'None'
            WHEN 1  THEN 'Physical'
            WHEN 2  THEN 'Physical'
            WHEN 3  THEN 'Chemical'
            WHEN 4  THEN 'Chemical'
            WHEN 5  THEN 'Traditional'
            WHEN 6  THEN 'Physical'
            WHEN 7  THEN 'Chemical'
            WHEN 8  THEN 'Traditional'
            WHEN 9  THEN 'Chemical'
            WHEN 10 THEN 'Environmental'
            WHEN 11 THEN 'Environmental'
            WHEN 99 THEN 'Other'
            ELSE 'Unknown'
        END AS Category
    FROM SplitPrevention
    WHERE Code IS NOT NULL
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    c.Category,
    SUM(CASE WHEN c.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN c.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN c.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Category,
    CAST(
        SUM(CASE WHEN c.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos,
    CAST(
        COUNT(*) * 100.0 / NULLIF(T.Total_Tested, 0) 
    AS DECIMAL(5,2)) AS Pct_Of_All_Tested
FROM Categorized c
CROSS JOIN Totals T
WHERE c.Category <> 'Unknown'
GROUP BY c.Category, T.Total_Pos, T.Total_Tested
ORDER BY 
    CASE c.Category
        WHEN 'Physical' THEN 1
        WHEN 'Chemical' THEN 2
        WHEN 'Traditional' THEN 3
        WHEN 'Environmental' THEN 4
        WHEN 'None' THEN 5
        WHEN 'Other' THEN 6
    END;






-- ============================================
-- Microscopy Results by PAST MALARIA HISTORY
-- DSC Order of N
-- ============================================
WITH HistoryData AS (
    SELECT 
        CASE 
            WHEN [Past_Malaria_History] IS NULL 
                 OR TRIM([Past_Malaria_History]) = '' 
                 THEN 'Not Recorded'
            WHEN UPPER(TRIM([Past_Malaria_History])) IN ('YES','Y','1','POSITIVE','P') 
                 THEN 'Yes (previous malaria)'
            WHEN UPPER(TRIM([Past_Malaria_History])) IN ('NO','N','0','NEGATIVE') 
                 THEN 'No (no previous malaria)'
            ELSE 'Other: ' + TRIM([Past_Malaria_History])
        END AS Past_History,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    h.Past_History,
    SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Micro_Pos_N,
    SUM(CASE WHEN h.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Micro_Neg_N,
    COUNT(*) AS Total_N,
    -- Positivity rate WITHIN this history group
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Group,
    -- % of all positives in this group
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos,
    -- % of all tested in this group
    CAST(
        COUNT(*) * 100.0 / NULLIF(T.Total_Tested, 0) 
    AS DECIMAL(5,2)) AS Pct_Of_All_Tested
FROM HistoryData h
CROSS JOIN Totals T
GROUP BY h.Past_History, T.Total_Pos, T.Total_Tested
ORDER BY Total_N DESC;  





SELECT 
    [Past_Malaria_History], 
    COUNT(*) AS N
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Past_Malaria_History]
ORDER BY N DESC;





-- ============================================
-- Microscopy Results by IRS SPRAY HISTORY
-- [IRS_Spray_History]: 0 = No, 1 = Yes
-- Sorted by Total_N DESC
-- ============================================
WITH IRSData AS (
    SELECT 
        CASE 
            WHEN [IRS_Spray_History] IS NULL THEN '3. Not Recorded'
            WHEN [IRS_Spray_History] = 0 THEN '1. No IRS spray'
            WHEN [IRS_Spray_History] = 1 THEN '2. Yes IRS spray'
            ELSE '4. Other'
        END AS IRS_Status,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    i.IRS_Status,
    SUM(CASE WHEN i.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_N,
    SUM(CASE WHEN i.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN i.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN i.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Neg_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN i.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos
FROM IRSData i
CROSS JOIN Totals T
GROUP BY i.IRS_Status, T.Total_Pos
ORDER BY Total_N DESC;





-- ============================================
-- Microscopy Results by MALARIA POSITIVE HISTORY
-- [Malaria_Positive_History]: y = Yes, no = No
-- ============================================
WITH HistoryData AS (
    SELECT 
        CASE 
            WHEN [Malaria_Positive_History] IS NULL 
                 OR TRIM([Malaria_Positive_History]) = '' 
                 THEN '3. Not Recorded'
            WHEN LOWER(TRIM([Malaria_Positive_History])) IN ('y','yes','1','positive') 
                 THEN '2. Yes (previous malaria)'
            WHEN LOWER(TRIM([Malaria_Positive_History])) IN ('no','n','0','negative') 
                 THEN '1. No (no previous malaria)'
            ELSE '4. Other: ' + [Malaria_Positive_History]
        END AS Positive_History,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    h.Positive_History,
    SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_N,
    SUM(CASE WHEN h.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Neg_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos
FROM HistoryData h
CROSS JOIN Totals T
GROUP BY h.Positive_History, T.Total_Pos
ORDER BY Total_N DESC;




-- Malaria Positive History
SELECT [Malaria_Positive_History], COUNT(*) AS N 
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Malaria_Positive_History];

-- Past Malaria History
SELECT [Past_Malaria_History], COUNT(*) AS N 
FROM [vw_PCD_Gambella_Analysis]
GROUP BY [Past_Malaria_History];





-- ============================================
-- Microscopy Results by MALARIA POSITIVE HISTORY
-- [Malaria_Positive_History]: 0 = No, 1 = Yes
-- ============================================
WITH HistoryData AS (
    SELECT 
        CASE 
            WHEN [Malaria_Positive_History] IS NULL THEN '3. Not Recorded'
            WHEN [Malaria_Positive_History] = 0 THEN '1. No (no previous malaria)'
            WHEN [Malaria_Positive_History] = 1 THEN '2. Yes (previous malaria)'
            ELSE '4. Other'
        END AS Positive_History,
        [Microscopy_Result]
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
),
Totals AS (
    SELECT 
        COUNT(*) AS Total_Tested,
        SUM(CASE WHEN [Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Total_Pos,
        SUM(CASE WHEN [Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Total_Neg
    FROM [vw_PCD_Gambella_Analysis]
    WHERE [Microscopy_Result] IN ('P','N')
)
SELECT 
    h.Positive_History,
    SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1 ELSE 0 END) AS Pos_N,
    SUM(CASE WHEN h.[Microscopy_Result] = 'N' THEN 1 ELSE 0 END) AS Neg_N,
    COUNT(*) AS Total_N,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1.0 ELSE 0 END) * 100 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'N' THEN 1.0 ELSE 0 END) * 100 
        / NULLIF(COUNT(*), 0) 
    AS DECIMAL(5,2)) AS Neg_Pct_Within_Group,
    CAST(
        SUM(CASE WHEN h.[Microscopy_Result] = 'P' THEN 1.0 ELSE 0 END) * 100 
        / NULLIF(T.Total_Pos, 0) 
    AS DECIMAL(5,2)) AS Pos_Pct_Of_All_Pos
FROM HistoryData h
CROSS JOIN Totals T
GROUP BY h.Positive_History, T.Total_Pos
ORDER BY Total_N DESC;









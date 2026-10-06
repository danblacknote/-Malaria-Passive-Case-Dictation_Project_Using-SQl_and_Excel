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

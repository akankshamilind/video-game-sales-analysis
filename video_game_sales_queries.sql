-- =====================================================================
-- Video Game Sales Analysis: How does Nintendo compare to Sony and
-- Microsoft across regions, genres, and platforms?
-- Author: Akanksha Milind
-- Data: Kaggle "Video Game Sales" (vgsales.csv), sales in millions of units
-- Tool: SQLite (DB Browser for SQLite)
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: Data quality check
-- How many rows are there, and how many are missing a year?
-- ---------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Year = 'N/A' THEN 1 ELSE 0 END) AS rows_missing_year
FROM vgsales;


-- ---------------------------------------------------------------------
-- STEP 2: Build a lookup table that says which company makes each console
-- (The raw data only has platform codes like "Wii" or "PS2".)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS platforms;

CREATE TABLE platforms (
    platform TEXT PRIMARY KEY,
    maker    TEXT,
    type     TEXT          -- 'Home' console or 'Handheld'
);

INSERT INTO platforms (platform, maker, type) VALUES
    ('NES',  'Nintendo',  'Home'),
    ('SNES', 'Nintendo',  'Home'),
    ('N64',  'Nintendo',  'Home'),
    ('GC',   'Nintendo',  'Home'),
    ('Wii',  'Nintendo',  'Home'),
    ('WiiU', 'Nintendo',  'Home'),
    ('GB',   'Nintendo',  'Handheld'),
    ('GBA',  'Nintendo',  'Handheld'),
    ('DS',   'Nintendo',  'Handheld'),
    ('3DS',  'Nintendo',  'Handheld'),
    ('PS',   'Sony',      'Home'),
    ('PS2',  'Sony',      'Home'),
    ('PS3',  'Sony',      'Home'),
    ('PS4',  'Sony',      'Home'),
    ('PSP',  'Sony',      'Handheld'),
    ('PSV',  'Sony',      'Handheld'),
    ('XB',   'Microsoft', 'Home'),
    ('X360', 'Microsoft', 'Home'),
    ('XOne', 'Microsoft', 'Home'),
    ('GEN',  'Sega',      'Home'),
    ('SAT',  'Sega',      'Home'),
    ('DC',   'Sega',      'Home'),
    ('SCD',  'Sega',      'Home'),
    ('GG',   'Sega',      'Handheld');


-- ---------------------------------------------------------------------
-- STEP 3: Create a clean view
-- - Joins each game to its console maker (LEFT JOIN keeps PC etc. as 'Other')
-- - Turns text columns into numbers
-- - Removes rows with no year and the incomplete years after 2016
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS games_clean;

CREATE VIEW games_clean AS
SELECT
    g.Name                          AS name,
    g.Platform                      AS platform,
    CAST(g.Year AS INTEGER)         AS year,
    g.Genre                         AS genre,
    g.Publisher                     AS publisher,
    CAST(g.NA_Sales     AS REAL)    AS na_sales,
    CAST(g.EU_Sales     AS REAL)    AS eu_sales,
    CAST(g.JP_Sales     AS REAL)    AS jp_sales,
    CAST(g.Other_Sales  AS REAL)    AS other_sales,
    CAST(g.Global_Sales AS REAL)    AS global_sales,
    COALESCE(p.maker, 'Other')      AS maker,
    COALESCE(p.type,  'Other')      AS platform_type
FROM vgsales AS g
LEFT JOIN platforms AS p
    ON g.Platform = p.platform
WHERE g.Year <> 'N/A'
  AND CAST(g.Year AS INTEGER) BETWEEN 1980 AND 2016;


-- ---------------------------------------------------------------------
-- Q1: Total game sales and number of games by console maker
-- ---------------------------------------------------------------------
SELECT
    maker,
    ROUND(SUM(global_sales), 1)  AS global_sales_millions,
    COUNT(*)                     AS num_games,
    ROUND(AVG(global_sales), 2)  AS avg_sales_per_game
FROM games_clean
GROUP BY maker
ORDER BY global_sales_millions DESC;


-- ---------------------------------------------------------------------
-- Q2: Where does each maker sell? (% of its sales from each region)
-- ---------------------------------------------------------------------
SELECT
    maker,
    ROUND(100.0 * SUM(na_sales)    / SUM(global_sales), 1) AS pct_north_america,
    ROUND(100.0 * SUM(eu_sales)    / SUM(global_sales), 1) AS pct_europe,
    ROUND(100.0 * SUM(jp_sales)    / SUM(global_sales), 1) AS pct_japan,
    ROUND(100.0 * SUM(other_sales) / SUM(global_sales), 1) AS pct_other
FROM games_clean
WHERE maker IN ('Nintendo', 'Sony', 'Microsoft')
GROUP BY maker
ORDER BY SUM(global_sales) DESC;


-- ---------------------------------------------------------------------
-- Q3: Sales by year for the big three (used for the Tableau line chart)
-- ---------------------------------------------------------------------
SELECT
    year,
    maker,
    ROUND(SUM(global_sales), 1) AS global_sales_millions
FROM games_clean
WHERE maker IN ('Nintendo', 'Sony', 'Microsoft')
GROUP BY year, maker
ORDER BY year, maker;


-- ---------------------------------------------------------------------
-- Q4: Which genres sell best on Nintendo consoles?
-- avg_sales_per_game shows which genres "punch above their weight"
-- ---------------------------------------------------------------------
SELECT
    genre,
    ROUND(SUM(global_sales), 1)  AS global_sales_millions,
    COUNT(*)                     AS num_games,
    ROUND(AVG(global_sales), 2)  AS avg_sales_per_game
FROM games_clean
WHERE maker = 'Nintendo'
GROUP BY genre
ORDER BY global_sales_millions DESC;


-- ---------------------------------------------------------------------
-- Q5: Handheld vs. home console sales, Nintendo vs. Sony
-- ---------------------------------------------------------------------
SELECT
    maker,
    platform_type,
    ROUND(SUM(global_sales), 1) AS global_sales_millions
FROM games_clean
WHERE maker IN ('Nintendo', 'Sony')
GROUP BY maker, platform_type
ORDER BY maker, global_sales_millions DESC;


-- ---------------------------------------------------------------------
-- Q6: Best-selling game on each Nintendo console (window function)
-- ROW_NUMBER ranks games within each platform; we keep rank 1
-- ---------------------------------------------------------------------
SELECT platform, name, global_sales
FROM (
    SELECT
        platform,
        name,
        global_sales,
        ROW_NUMBER() OVER (PARTITION BY platform ORDER BY global_sales DESC) AS rank_in_platform
    FROM games_clean
    WHERE maker = 'Nintendo'
) AS ranked
WHERE rank_in_platform = 1
ORDER BY global_sales DESC;


-- ---------------------------------------------------------------------
-- Q7: Top 10 games published by Nintendo
-- ---------------------------------------------------------------------
SELECT
    name,
    platform,
    year,
    global_sales
FROM games_clean
WHERE publisher = 'Nintendo'
ORDER BY global_sales DESC
LIMIT 10;

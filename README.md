# Video Game Sales Analysis: Nintendo vs. Sony vs. Microsoft

**Interactive dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/akanksha.milind/viz/NintendovsSonyvsMicrosoftVideoGameSalesAnalysis_/NintendoDashboard)

## Question
How does Nintendo compare to Sony and Microsoft across sales eras, regions, genres, and console types?

## Data
- **Source:** Kaggle "Video Game Sales" (vgchartz.com scrape), `vgsales.csv`
- **Size:** 16,598 games, each with more than 100,000 copies sold
- **Columns:** name, platform, year, genre, publisher, and sales (in millions) for North America, Europe, Japan, other regions, and global

## Tools
- **SQL (SQLite / DB Browser for SQLite):** data cleaning, modeling, and analysis
- **Tableau Public:** interactive dashboard

## Process
1. **Data quality check:** found 271 rows with no release year, plus a hidden trailing space in the imported table name, which was fixed with a rename.
2. **Lookup table:** the raw data only has platform codes (e.g., "Wii", "PS2"), so I built a `platforms` table mapping 24 consoles to their manufacturer and type (home or handheld).
3. **Clean view:** created `games_clean`, which joins sales to the lookup table (LEFT JOIN, with unmatched platforms labeled "Other"), casts text to numbers, and removes rows with missing or incomplete years (keeps 1980–2016).
4. **Analysis:** 7 queries using GROUP BY, CASE, COALESCE, a subquery, and a window function (`ROW_NUMBER() OVER (PARTITION BY ...)`).
5. **Dashboard:** 4 charts (sales by year, regional mix, Nintendo genres, top 10 Nintendo games) plus key findings.

## Key findings
- **Near tie at the top:** games on Nintendo consoles sold ~3.49B units vs. ~3.54B for Sony, with about 400 fewer titles (0.57M vs. 0.54M per game).
- **Three eras:** Sony led 1996–2005, Nintendo led 2006–2010 (peaking at 332.4M units in 2009, the highest single year of any maker), and Sony led again 2011–2015. Nintendo's yearly sales fell ~86% from 2009 to 2015.
- **Japan strength:** 21.6% of Nintendo's sales came from Japan, vs. 13.2% for Sony and 1.0% for Microsoft. North America is still Nintendo's largest region (50.4%).
- **Handhelds are core:** handhelds made up 46.8% of Nintendo's game sales vs. 10.0% of Sony's. Nintendo's handheld sales alone (1.63B) exceeded Microsoft's entire total (1.36B).
- **Quality over quantity:** Platform games averaged 1.15M units per title, about 2.8× Action games (0.41M), despite less than half as many titles (505 vs. 1,137).
- **Franchise power:** Mario or Pokémon was the #1 game on 8 of 10 Nintendo consoles, and 6 of Nintendo's top 10 games were Wii/DS titles from 2006–2009.

## Limitations
- Only includes games that sold over 100,000 copies.
- Data ends partway through 2016, so 2016 totals are incomplete, and the Nintendo Switch (2017) is not included.
- Sales are game (software) units sold on each company's consoles, not console hardware sales.
- Sales figures are estimates from vgchartz.com.

## Files
- `video_game_sales_queries.sql`: all SQL, in order, with comments
- `README.md`: this file

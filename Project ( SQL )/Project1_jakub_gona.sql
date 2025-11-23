/*
 * Projekt 1 Jakub Goňa
 */

/*
 *
 * TABUĽKA 1 - Ceny potravín a priemerné mzdy v ČR zjednotíme na rovnaké porovnateľné obdobie 
 * výsledkom sú spoločné roky (2006–2018)
 *
 */

SELECT * FROM czechia_price ORDER BY date_from;
SELECT * FROM czechia_payroll ORDER BY payroll_year;  

-- Tabuľky cien potravín a priemerných miezd sa prekrývajú v rokoch 2006 - 2018

-- Zmažeme existujúcu tabuľku, ak už existuje.
DROP TABLE IF EXISTS t_jakub_gona_project_sql_primary_final;

-- Vytvoríme novú tabuľku
CREATE TABLE t_jakub_gona_project_sql_primary_final AS 
SELECT 
	cpc.name AS food_category,
	cpc.price_value,
	cpc.price_unit,
	cp.value AS price,
	cp.date_from,
	cp.date_to,
	cpay.payroll_year ,
	cpay.value AS avg_wages,
	cpib.name AS industry_branch
FROM czechia_price cp
JOIN czechia_payroll cpay 
	ON EXTRACT(YEAR FROM cp.date_from) = cpay.payroll_year
	AND cpay.value_type_code = 5958
	AND cp.region_code IS NULL
JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code 
JOIN czechia_payroll_industry_branch cpib 
	ON cpay.industry_branch_code = cpib.code;

SELECT * FROM t_jakub_gona_project_sql_primary_final
ORDER BY date_from, food_category;


/*
 *
 * TABUĽKA 2 - Dodatočné údaje o ďalších európskych štátoch (2006–2018)
 *
 */


-- Zmažeme existujúcu tabuľku, ak už existuje
DROP TABLE IF EXISTS t_jakub_gona_project_sql_secondary_final;

-- Vytvoríme novú tabuľku
CREATE TABLE t_jakub_gona_project_sql_secondary_final AS 
SELECT 
	c.country,
	e."year",
	e.population, 
	e.gini,
	e.GDP	
FROM countries c
JOIN economies e ON e.country = c.country
	WHERE c.continent = 'Europe'
		AND e."year" BETWEEN 2006 AND 2018
ORDER BY c."country", e."year";

SELECT * FROM t_jakub_gona_project_sql_secondary_final;


/*
 * 
 * 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 * 
 */


-- Tabuľka Průměrné mzdy podľa odvetvia a rokov
-- Zmažeme existujúcu tabuľku, ak existuje
DROP TABLE IF EXISTS t_jakub_gona_project_avg_wages_by_sector_and_year;

-- Vytvoríme novú temp tabuľku pre průměrné mzdy
CREATE TEMP TABLE t_jakub_gona_project_avg_wages_by_sector_and_year AS
SELECT 
	industry_branch,
	payroll_year,
	round(avg(avg_wages)) AS avg_wages_CZK
FROM t_jakub_gona_project_sql_primary_final
GROUP BY industry_branch, payroll_year
ORDER BY industry_branch;

SELECT * FROM t_jakub_gona_project_avg_wages_by_sector_and_year;

-- Tabuľka Trend rastu miezd podľa odvetvia a rokov v CZK a v %
-- Zmažeme existujúcu tabuľku, ak existuje
DROP TABLE IF EXISTS t_jakub_gona_project_wages_growth_trend_by_sector_and_year;

-- Vytvoríme novú temp tabuľku pre trend miezd
CREATE TEMP TABLE t_jakub_gona_project_wages_growth_trend_by_sector_and_year AS
SELECT
	newer_avg.industry_branch, 
	older_avg.payroll_year AS older_year,
	older_avg.avg_wages_CZK AS older_wages,
	newer_avg.payroll_year AS newer_year,
	newer_avg.avg_wages_CZK AS newer_wages,
	newer_avg.avg_wages_CZK - older_avg.avg_wages_CZK AS wages_difference_czk,
	round(newer_avg.avg_wages_CZK * 100 / older_avg.avg_wages_CZK, 2) - 100 AS wages_difference_percentage,
	CASE
		WHEN newer_avg.avg_wages_CZK > older_avg.avg_wages_CZK
			THEN 'Narast'
			ELSE 'Pokles'
	END AS wages_trend
FROM t_jakub_gona_project_avg_wages_by_sector_and_year AS newer_avg
JOIN t_jakub_gona_project_avg_wages_by_sector_and_year AS older_avg
	ON newer_avg.industry_branch = older_avg.industry_branch
	AND newer_avg.payroll_year = older_avg.payroll_year + 1
ORDER BY industry_branch;

SELECT * FROM t_jakub_gona_project_wages_growth_trend_by_sector_and_year;

-- Mzdy vo všetkých sledovaných odvetviach rastú. Avšak rast miezd nebol lineárny a v niektorých rokoch bol zaznamenaný medziročný pokles.

-- Medziročný pokles cien.
SELECT *
FROM t_jakub_gona_project_wages_growth_trend_by_sector_and_year
WHERE wages_trend = 'Pokles'
ORDER BY wages_difference_percentage;

-- Najväčší medziročný pokles zaznamenalo odvetvie Peněžnictví a pojišťovnictví v roku 2013, kedy sa priemerná mzda znížila o -8,91 % z 50 254 Kč v roku 2012 na 45 775 Kč v roku 2013.
-- Z celkových 228 meraní bol pokles mzdy zaznamenaný u 23 výsledkov, čo predstavuje približne 10 % zo všetkých meraní.

-- Mzdový nárast od roku 2006 do roku 2018 podľa odvetvia v %
SELECT
	newer_avg.industry_branch, 
	older_avg.payroll_year AS older_year,
	older_avg.avg_wages_CZK AS older_wages,
	newer_avg.payroll_year AS newer_year,
	newer_avg.avg_wages_CZK AS newer_wages,
	newer_avg.avg_wages_CZK - older_avg.avg_wages_CZK AS wages_difference_czk,
	round(newer_avg.avg_wages_CZK * 100 / older_avg.avg_wages_CZK, 2) - 100 AS wages_difference_percentage
FROM t_jakub_gona_project_avg_wages_by_sector_and_year AS newer_avg
JOIN t_jakub_gona_project_avg_wages_by_sector_and_year AS older_avg
	ON newer_avg.industry_branch = older_avg.industry_branch
	WHERE older_avg.payroll_year = 2006 
		AND newer_avg.payroll_year = 2018
ORDER BY round(newer_avg.avg_wages_CZK * 100 / older_avg.avg_wages_CZK, 2) - 100 DESC;

-- Najväčší nárast miezd zaznamenalo odvetvie Zdravotní a sociální péče, kde bola v roku 2018 priemerná mzda o 76,9 % vyššia ako v roku 2006. Najmenší nárast miezd bol zaznamenaný v odvetví Peněžnictví a pojišťovnictví, kde bola v roku 2018 priemerná mzda o 36,3 % vyššia ako v roku 2006.


/*
 * 
 * 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 * 
 */


-- Kúpna sila obyvateľov pre ČR v rokoch 2006 a 2018 vzhľadom na ceny chleba a mlieka.
SELECT
	food_category, 
	round(avg(price)::numeric, 2) AS avg_price,
	price_value, 
	price_unit, 
	payroll_year,
	round(avg(avg_wages)::numeric, 2) AS avg_wages,
	round((round(avg(avg_wages)::numeric, 2)) / (round(avg(price)::numeric, 2))) AS avg_purchasing_power
FROM t_jakub_gona_project_sql_primary_final
WHERE payroll_year IN(2006, 2018)
	AND food_category IN('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY food_category, price_value, price_unit, payroll_year;

-- V roku 2006 bolo za priemernú cenu chleba 16,12 Kč a priemernú mzdu 20 753,78 Kč možné kúpiť 1 287,18 kg chleba a 1 437 litrov mlieka za cenu 14,44 Kč. V roku 2018 bolo za cenu 24,24 Kč a priemernú mzdu 32 536 Kč možné kúpiť 1 342 kg chleba a 1 642 litrov mlieka za priemernú cenu 19,82 Kč.


/*
 * 
 * 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * 
 */


-- Ročný priemerný cenový vývoj potravín
CREATE TEMP TABLE t_jakub_gona_project_avg_food_price_by_year AS
SELECT 
	DISTINCT food_category,
	price_value AS value, 
	price_unit AS unit, 
	payroll_year AS year, 
	round(avg(price)::numeric, 2) AS avg_price
FROM t_jakub_gona_project_sql_primary_final
GROUP BY food_category, price_value, price_unit, payroll_year;

SELECT * FROM t_jakub_gona_project_avg_food_price_by_year;

-- Cenový trend potravín od roku 2006 do roku 2018
CREATE TEMP TABLE t_jakub_gona_project_food_price_trend AS
SELECT 
	older_year.food_category, 
	older_year.value,
	older_year.unit,
	older_year.year AS older_year,
	older_year.avg_price AS older_price,
	newer_year.year AS newer_year,
	newer_year.avg_price AS newer_price, 
	newer_year.avg_price - older_year.avg_price AS price_difference_czk,
	round((newer_year.avg_price - older_year.avg_price) / older_year.avg_price * 100, 2) AS price_diff_percentage,
	CASE
		WHEN newer_year.avg_price > older_year.avg_price
		THEN 'Narast'
		ELSE 'Pokles'
	END AS price_trend
FROM t_jakub_gona_project_avg_food_price_by_year AS older_year
JOIN t_jakub_gona_project_avg_food_price_by_year AS newer_year 
	ON older_year.food_category = newer_year.food_category
		AND newer_year.year = older_year.year + 1
ORDER BY food_category, older_year.year;

SELECT * FROM t_jakub_gona_project_food_price_trend;

-- Priemerný medziročný nárast cien potravín
SELECT 
	food_category,
	round(avg(price_diff_percentage)::numeric, 2) AS avg_annual_price_growth_in_percentage
FROM t_jakub_gona_project_food_price_trend
GROUP BY food_category
ORDER BY round(avg(price_diff_percentage)::numeric, 2);

-- Prípadné porovnanie cien potravín medzi rokmi 2006 a 2018
CREATE TEMP TABLE t_jakub_gona_project_food_price_2006_compare_2018 AS 
SELECT 
	older_year.food_category,
	older_year.value,
	older_year.unit,
	older_year.year AS older_year,
	older_year.avg_price AS older_price,
	newer_year.year AS newer_year,
	newer_year.avg_price AS newer_price,
	newer_year.avg_price - older_year.avg_price AS price_diff_czk,
	round((newer_year.avg_price - older_year.avg_price) / older_year.avg_price * 100, 2) AS price_diff_percentage
FROM t_jakub_gona_project_avg_food_price_by_year AS older_year
JOIN t_jakub_gona_project_avg_food_price_by_year AS newer_year
	ON older_year.food_category = newer_year.food_category

SELECT * FROM t_jakub_gona_project_food_price_2006_compare_2018
ORDER BY price_diff_percentage ASC;

-- Zobrazenie najmenej zdražujúcej sa kategórie z dát
SELECT 
	food_category,
	round(avg(price_diff_percentage)::numeric, 2) AS avg_annual_price_growth_in_percentage
FROM t_jakub_gona_project_food_price_trend
GROUP BY food_category
ORDER BY round(avg(price_diff_percentage)::numeric, 2);

-- Kategória s menom Cukr krystalový patrí medzi tie, ktorých cena sa zvyšovala najpomalšie. Výsledky ukazujú, že cena tejto kategórie sa medziročne dokonca znižovala, a to v priemere o -1,92 %.

-- Najvyšší percentuálny nárast ceny potravín, pri porovnaní rokov 2006 a 2018, bol zaznamenaný u masla, nárast o 98,37 %. Nasledujú vaječné cestoviny s 83,45 %, paprika s 71,25 % a ryža s 69,94 %. K výraznému zlacneniu v období rokov 2006 až 2018 došlo u cukru a rajských jablk, s poklesom cien o -27,52 % a -23,07 %.


/*
 * 
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 * 
 */


-- TEMPORÁRNA TABUĽKA Priemerné mzdy v ČR za všetky roky (priemer zo všetkých odvetví dokopy)
CREATE TEMP TABLE t_jakub_gona_project_avg_wages_cr_2006_2018 AS 
SELECT 
	industry_branch, -- stĺpec industry_branch je tu len kvôli prepojeniu v ďalšej tabuľke
	payroll_year, 
	round(avg(avg_wages_CZK)) AS avg_wages_CR_CZK
FROM t_jakub_gona_project_avg_wages_by_sector_and_year
GROUP BY payroll_year, industry_branch;

SELECT * FROM t_jakub_gona_project_avg_wages_cr_2006_2018;

-- Trend vývoja rastu miezd v ČR v rokoch 2006 - 2018
CREATE TEMP TABLE t_jakub_gona_project_avg_wages_trend_diff_cr_2006_2018 AS 
SELECT
	awcr1.payroll_year AS older_year, 
	awcr1.avg_wages_CR_CZK AS older_wages,
	awcr2.payroll_year AS newer_year,
	awcr2.avg_wages_CR_CZK AS newer_wages,
	round((awcr2.avg_wages_CR_CZK - awcr1.avg_wages_CR_CZK) / awcr1.avg_wages_CR_CZK * 100, 2) AS avg_wages_diff_percentage
FROM t_jakub_gona_project_avg_wages_cr_2006_2018 AS awcr1
JOIN t_jakub_gona_project_avg_wages_cr_2006_2018 AS awcr2
	ON awcr2.industry_branch = awcr1.industry_branch 
		AND awcr2.payroll_year = awcr1.payroll_year + 1;

SELECT * FROM t_jakub_gona_project_avg_wages_trend_diff_cr_2006_2018;

-- Priemerné ceny potravín v ČR v rokoch 2006 - 2018 (priemer zo všetkých kategórií dokopy)
CREATE TEMP TABLE t_jakub_gona_project_avg_food_price_cr_2006_2018 AS 
SELECT 
	"year",
	round(avg(avg_price), 2) AS avg_food_price_cr_czk
FROM t_jakub_gona_project_avg_food_price_by_year
GROUP BY "year";

SELECT * FROM t_jakub_gona_project_avg_food_price_cr_2006_2018;

-- Rast cien potravín v ČR v rokoch 2006 - 2018
CREATE TEMP TABLE t_jakub_gona_project_avg_food_price_trend_diff_cr_2006_2018 AS 
SELECT 
	afp1."year" AS older_year, 
	afp1.avg_food_price_cr_czk AS older_price, 
	afp2."year" AS newer_year, 
	afp2.avg_food_price_cr_czk AS newer_price,
	afp2.avg_food_price_cr_czk - afp1.avg_food_price_cr_czk AS avg_wages_diff_czk,
	round((afp2.avg_food_price_cr_czk - afp1.avg_food_price_cr_czk) / afp1.avg_food_price_cr_czk * 100, 2) AS avg_price_diff_percentage
FROM t_jakub_gona_project_avg_food_price_cr_2006_2018 AS afp1
JOIN t_jakub_gona_project_avg_food_price_cr_2006_2018 AS afp2 
	ON afp2."year" = afp1."year" + 1
GROUP BY afp1."year", afp1.avg_food_price_cr_czk, afp2."year", afp2.avg_food_price_cr_czk;

-- Porovnanie medziročného nárastu priemerných cien a miezd v ČR
CREATE TEMP TABLE t_jakub_gona_project_yoy_growth_prices_and_wages_comparison_in_CR AS 
SELECT 
	afptd.older_year, 
	awtd.newer_year,
	awtd.avg_wages_diff_percentage,
	afptd.avg_price_diff_percentage,
	afptd.avg_price_diff_percentage - awtd.avg_wages_diff_percentage AS price_wages_diff
FROM t_jakub_gona_project_avg_food_price_trend_diff_cr_2006_2018 AS afptd
JOIN t_jakub_gona_project_avg_wages_trend_diff_cr_2006_2018 AS awtd 
	ON awtd.older_year = afptd.older_year
GROUP BY afptd.older_year, awtd.newer_year, awtd.avg_wages_diff_percentage, afptd.avg_price_diff_percentage
ORDER BY afptd.avg_price_diff_percentage DESC;

SELECT * FROM t_jakub_gona_project_yoy_growth_prices_and_wages_comparison_in_CR
ORDER BY price_wages_diff DESC;

-- Počas roka 2012 ( Teda od 2012 až 2013 ) klesol priemerný nárast platu o 8,91 %, pričom ale ceny stúpli o priemerne 5,1 %, čo vo výsledku robí rozdiel 14,01 % v celom porovnaní.
-- Tento rodziel bol teda vyšší ako 10 % podľa zadania.


/*
 * 
 * 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 * 
 */


-- Vytvorte dočasnú tabuľku pre HDP v ČR v rokoch 2006 - 2018
CREATE TEMP TABLE t_jakub_gona_project_gdp_cr_2006_2018 AS 
SELECT * FROM t_jakub_gona_project_sql_secondary_final
WHERE country = 'Czech Republic';

SELECT * FROM t_jakub_gona_project_gdp_cr_2006_2018;

-- Vytvorte dočasnú tabuľku pre trend HDP - medziročný vývoj
CREATE TEMP TABLE t_jakub_gona_project_yoy_gdp_trend_diff_cr_2006_2018 AS 
SELECT 
    gdp1."year" AS older_year, 
    gdp1.GDP AS older_gdp, 
    gdp2."year" AS newer_year, 
    gdp2.GDP AS newer_gdp,
    round(((gdp2.GDP - gdp1.GDP) / gdp1.GDP * 100)::numeric, 2) AS gdp_diff_percentage
FROM t_jakub_gona_project_gdp_cr_2006_2018 AS gdp1
JOIN t_jakub_gona_project_gdp_cr_2006_2018 AS gdp2
    ON gdp2.country = gdp1.country
    AND gdp2."year" = gdp1."year" + 1
GROUP BY gdp1."year", gdp1.GDP, gdp2."year", gdp2.GDP;

SELECT * FROM t_jakub_gona_project_yoy_gdp_trend_diff_cr_2006_2018;

-- Vytvorte dočasnú tabuľku pre medziročný vývoj cien potravín, miezd a HDP v ČR 2006-2018
CREATE TEMP TABLE t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS 
SELECT 
	gdp.older_year, 
	gdp.newer_year, 
	fpt.avg_price_diff_percentage, 
	wag.avg_wages_diff_percentage, 
	gdp.gdp_diff_percentage
FROM t_jakub_gona_project_yoy_gdp_trend_diff_cr_2006_2018 AS gdp
JOIN t_jakub_gona_project_avg_wages_trend_diff_cr_2006_2018 AS wag
	ON wag.older_year = gdp.older_year
JOIN t_jakub_gona_project_avg_food_price_trend_diff_cr_2006_2018 AS fpt 
	ON fpt.older_year = gdp.older_year;

SELECT * FROM t_jakub_gona_project_yoy_foodprice_wages_gdp_trend;

-- Priemerný medziročný rast cien, miezd a HDP za celé obdobie
SELECT 
    fpt.older_year AS year_from,
    max(fpt.newer_year) AS year_to,
    round(avg(fpt.avg_price_diff_percentage)::numeric, 2) AS avg_foodprice_growth_trend_percentage, 
    round(avg(wag.avg_wages_diff_percentage)::numeric, 2) AS avg_wages_growth_trend_percentage, 
    round(avg(gdp.gdp_diff_percentage)::numeric, 2) AS avg_gdp_growth_trend_percentage
FROM t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS fpt
JOIN t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS wag
    ON wag.older_year = fpt.older_year
JOIN t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS gdp 
    ON gdp.older_year = fpt.older_year
GROUP BY fpt.older_year;

-- Nárast cien
SELECT 
    fpt.older_year AS year_from,
    max(fpt.newer_year) AS year_to,
    round(sum(fpt.avg_price_diff_percentage)::numeric, 2) AS avg_foodprice_growth_trend_percentage, 
    round(sum(wag.avg_wages_diff_percentage)::numeric, 2) AS avg_wages_growth_trend_percentage, 
    round(sum(gdp.gdp_diff_percentage)::numeric, 2) AS avg_gdp_growth_trend_percentage
FROM t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS fpt
JOIN t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS wag
    ON wag.older_year = fpt.older_year
JOIN t_jakub_gona_project_yoy_foodprice_wages_gdp_trend AS gdp 
    ON gdp.older_year = fpt.older_year
GROUP BY fpt.older_year;

-- Na základe analýzy priemerného rastu cien potravín, miezd a HDP v rokoch 2006–2018 nie je možné s istotou potvrdiť ani vyvrátiť danú hypotézu. Aj keď existuje určitá kauzalita, táto závislosť sa prejavila nepravidelne a nie je jednoznačná pre všetky roky.
-- Napríklad v roku 2015 je patrný výrazný rast HDP o 5,39 %, ale priemerné ceny potravín v rovnakom aj nasledujúcom roku klesali. Na druhej strane v roku 2012 došlo k zníženiu HDP, ale ceny potravín aj mzdy v nasledujúcich rokoch rástli. V roku 2013 je viditeľný menší pokles HDP o -0,05 %, ale ceny potravín vzrástli a mzdy klesli. V roku 2009 došlo k výraznému poklesu HDP o -4,66 %, ale ceny potravín sa naopak znížili a mzdy rástli.
-- Z dostupných dát teda možno vyvodiť, že výška HDP nemá jednoznačný vplyv na zmeny cien potravín alebo platov. Priemerné ceny potravín, rovnako ako priemerné mzdy, môžu rásť aj klesať nezávisle na vývoji HDP. 
-- V období od roku 2006 do 2018 prevládali medzi všetkými sledovanými kategóriami hodnoty medziročného rastu nad ich poklesom. V prípade HDP došlo k trom medziročným poklesom, ceny potravín klesli v dvoch prípadoch a mzdy klesli iba v jednom roku. 
-- Priemerná ročná rýchlosť rastu HDP medzi rokmi 2006 a 2018 bola 2,13 % a celkový nárast za toto obdobie činil 25,51 %. Ceny potravín rástli priemerne o 2,87 % ročne a celkovo sa zvýšili o 34,44 %. Mzdy potom rástli priemerne o 3,85 % ročne, celkovo vzrástli o 46,22 %.

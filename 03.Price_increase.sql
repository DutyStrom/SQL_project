/*
 * QUESTION:
 * Which food category has the lowest price growth? (percentage)
 * 
 * source TABLE:
 * t_petr_bocek_project_sql_primary_final
 */

-- Price data view
CREATE OR REPLACE VIEW v_price_data AS (
	SELECT DISTINCT
		  tprifi.`year`
		, tprifi.category_name
		, tprifi.category_code
		, tprifi.unit_value
		, tprifi.price_unit
		, tprifi.price_value
	FROM t_petr_bocek_project_sql_primary_final AS tprifi
	WHERE tprifi.category_code IS NOT NULL
	ORDER BY tprifi.category_code, tprifi.`year`
	)
;


-- Percentage price increase in all food categories in the monitored period
SELECT 
	  vprd.`year`
	, vprd.category_name
	, vprd.price_value
	, ROUND(((vprd.price_value - 
			  LAG(vprd.price_value) OVER (PARTITION BY vprd.category_name ORDER BY vprd.`year`)) * 
			  100) /
			  LAG(vprd.price_value) OVER (PARTITION BY vprd.category_name ORDER BY vprd.`year`),
			  2) AS pct_increase
FROM v_price_data AS vprd
WHERE 1 = 1
	AND vprd.`year` IN (2006, 2018)
;

-- Lowest percentage price increase
WITH cte_price_inc AS (
	SELECT 
	  vprd.`year`
	, vprd.category_name
	, vprd.price_value
	, ROUND(((vprd.price_value - 
			  LAG(vprd.price_value) OVER (PARTITION BY vprd.category_name ORDER BY vprd.`year`)) * 
			  100) /
			  LAG(vprd.price_value) OVER (PARTITION BY vprd.category_name ORDER BY vprd.`year`),
			  2) AS pct_increase
	FROM v_price_data AS vprd
	WHERE 1 = 1
		AND vprd.`year` IN (2006, 2018)
	)
SELECT
	  `year`
	, category_name 
	, pct_increase AS lowest_pct_increase
FROM cte_price_inc 
WHERE 1 = 1
	AND pct_increase IS NOT NULL 
ORDER BY pct_increase 
LIMIT 1
;
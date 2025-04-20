/*
 * QUESTION:
 * Which food category has the lowest price increase? (percentage)
 * 
 * source TABLE:
 * t_petr_bocek_project_sql_primary_final
 * 
 */

CREATE OR REPLACE VIEW v_price_increase AS (
	SELECT DISTINCT 
		  tprifi.`year`
		, tprifi.category_name
		, tprifi.category_code
		, tprifi.unit_value
		, tprifi.price_unit
		, tprifi.price_value
	FROM engeto_db.t_petr_bocek_project_sql_primary_final AS tprifi
	WHERE category_code IS NOT NULL 
	ORDER BY tprifi.category_code, tprifi.`year`
	)
;

-- Percentage price increase in all food categories in the monitored period
SELECT 
	  vpi.`year`
	, vpi.category_name
	, vpi.price_value
	, ROUND(((vpi.price_value - 
			  LAG(vpi.price_value) OVER (PARTITION BY vpi.category_name ORDER BY vpi.`year`)) * 
			  100) /
			  LAG(vpi.price_value) OVER (PARTITION BY vpi.category_name ORDER BY vpi.`year`),
			  2) AS pct_increase
FROM v_price_increase AS vpi
WHERE 1 = 1
	AND vpi.`year` IN (2006, 2018)
;

-- Lowest percentage price increase
WITH cte_price_inc AS (
	SELECT 
	  vpi.`year`
	, vpi.category_name
	, vpi.price_value
	, ROUND(((vpi.price_value - 
			  LAG(vpi.price_value) OVER (PARTITION BY vpi.category_name ORDER BY vpi.`year`)) * 
			  100) /
			  LAG(vpi.price_value) OVER (PARTITION BY vpi.category_name ORDER BY vpi.`year`),
			  2) AS pct_increase
	FROM v_price_increase AS vpi
	WHERE 1 = 1
		AND vpi.`year` IN (2006, 2018)
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

/*
 * QUESTION:
 * Was there a year in which the annual increase in food prices 
 * was significantly higher than payroll growth (more than 10%)?
 * 
 * source TABLES:
 * t_petr_bocek_project_sql_primary_final
 */

-- Payroll data view
CREATE OR REPLACE VIEW v_payroll_data AS (
	SELECT DISTINCT
		  tprifi.`year`
		, tprifi.industry_branch_name
		, tprifi.branch_code
		, tprifi.payroll_value
	FROM t_petr_bocek_project_sql_primary_final AS tprifi
	ORDER BY tprifi.branch_code, `year`
	)
;

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


-- Percentage comparsion of the year-on-year difference in payroll and food prices growth.
WITH cte_payrolls AS (
		SELECT
			  vpad.`year` 
			, ROUND(AVG(vpad.payroll_value), 2) AS avg_yearly_payroll
			, ROUND(((AVG(vpad.payroll_value) - 
					LAG(AVG(vpad.payroll_value)) OVER (ORDER BY vpad.`year`)) *
					100) /
					LAG(AVG(vpad.payroll_value)) OVER (ORDER BY vpad.`year`),
					2) AS pct_payroll_trend
		FROM v_payroll_data AS vpad
		GROUP BY vpad.`year`
		),
	cte_prices AS (
		SELECT 
			  vprd.`year`
			, ROUND(AVG(vprd.price_value), 2) AS avg_yearly_price
			, ROUND(((AVG(vprd.price_value) - 
					  LAG(AVG(vprd.price_value)) OVER (ORDER BY vprd.`year`)) * 
					  100) /
					  LAG(AVG(vprd.price_value)) OVER (ORDER BY vprd.`year`),
					  2) AS pct_price_trend
		FROM v_price_data AS vprd
		GROUP BY vprd.`year`
		)
SELECT 
	  cte_prices.`year`
	, cte_prices.pct_price_trend
	, cte_payrolls.pct_payroll_trend
	, cte_prices.pct_price_trend - cte_payrolls.pct_payroll_trend AS price_payroll_pct_diff
FROM cte_payrolls 
LEFT JOIN cte_prices 
	ON cte_payrolls.`year` = cte_prices.`year`
WHERE 1 = 1
	AND cte_prices.`year` IS NOT NULL
ORDER BY price_payroll_pct_diff DESC
;


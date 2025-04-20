/*
 * QUESTION:
 * Was there a year in which the annual increase in food prices 
 * was significantly higher than payroll growth (more than 10%)?
 * 
 * source TABLES:
 * t_petr_bocek_project_sql_primary_final
 * 
 */

-- Percentage comparsion of the year-on-year difference in payroll and food prices growth.
WITH cte_payrolls AS (
		SELECT
			  vpt.`year` 
			, ROUND(AVG(vpt.payroll_value), 2) AS avg_yearly_payroll
			, ROUND(((AVG(vpt.payroll_value) - 
					LAG(AVG(vpt.payroll_value)) OVER (ORDER BY vpt.`year`)) *
					100) /
					LAG(AVG(vpt.payroll_value)) OVER (ORDER BY vpt.`year`),
					2) AS pct_payroll_trend
		FROM v_payroll_trend AS vpt
		GROUP BY vpt.`year`
		),
	cte_prices AS (
		SELECT 
			  vpi.`year`
			, ROUND(AVG(vpi.price_value), 2) AS avg_yearly_price
			, ROUND(((AVG(vpi.price_value) - 
					  LAG(AVG(vpi.price_value)) OVER (ORDER BY vpi.`year`)) * 
					  100) /
					  LAG(AVG(vpi.price_value)) OVER (ORDER BY vpi.`year`),
					  2) AS pct_price_trend
		FROM v_price_increase AS vpi
		GROUP BY vpi.`year`
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


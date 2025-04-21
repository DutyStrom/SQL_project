/* 
 *  
 * QUESTION:
 * Does the level of GDP affect changes in payrolls and food prices?
 * Or, if GDP increases more significantly in one year,
 * will this be reflected in a more significant increase in 
 * food prices or payrolls in the same or the following year?
 * 
 * source TABLES:
 *  t_petr_bocek_project_sql_primary_final
 *  t_petr_bocek_project_sql_secondary_final
 */


CREATE OR REPLACE VIEW v_GDP_trend AS (
	SELECT
		  tsecfi.`year`
		, tsecfi.GDP
		, tsecfi.gini
		, tsecfi.population
		, ROUND((tsecfi.GDP - 
				 LAG(tsecfi.GDP) OVER (ORDER BY tsecfi.`year`)) * 
				 100 / 
				 LAG(tsecfi.GDP) OVER (ORDER BY tsecfi.`year`),
				 2) AS pct_GDP_trend
	FROM t_petr_bocek_project_sql_secondary_final AS tsecfi
	WHERE 1 = 1
		AND tsecfi.country = 'Czech Republic'
	)
;

-- Impact of GDP on payrolls and food prices
WITH cte_avg_payroll AS (
	SELECT 
		  vpt.`year`
		, ROUND((AVG(vpt.payroll_value) - 
				 LAG(AVG(vpt.payroll_value)) OVER (ORDER BY vpt.`year`)) * 
				 100 /
				 LAG(AVG(vpt.payroll_value)) OVER (ORDER BY vpt.`year`),
				 2) AS avg_yearly_payroll_trend
	FROM v_payroll_trend AS vpt
	GROUP BY vpt.`year`
	),
	cte_avg_price AS (
	SELECT 
		  vpi.`year`
		, ROUND((AVG(vpi.price_value) - LAG(AVG(vpi.price_value )) OVER (ORDER BY vpi.`year`)) *
		  100 /
		  LAG(AVG(vpi.price_value)) OVER (ORDER BY vpi.`year`),
		  2) AS avg_yearly_price_trend
	FROM v_price_increase AS vpi 
	GROUP BY vpi.`year`
	)
SELECT 
	  vgt.`year`
	, vgt.GDP
	, vgt.pct_GDP_trend
	, capa.avg_yearly_payroll_trend
	, capr.avg_yearly_price_trend
FROM cte_avg_price AS capr
LEFT JOIN cte_avg_payroll AS capa
	ON capr.`year` = capa.`year`
LEFT JOIN v_gdp_trend AS vgt 
	ON capr.`year` = vgt.`year`
;

/* 
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

-- GDP data view
CREATE OR REPLACE VIEW v_GDP_data AS (
	SELECT
		  tsecfi.`year`
		, tsecfi.GDP
		, tsecfi.gini
		, tsecfi.population
	FROM t_petr_bocek_project_sql_secondary_final AS tsecfi
	WHERE tsecfi.country = 'Czech Republic'
	)
;

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


-- Impact of GDP on payrolls and food prices
WITH cte_avg_payroll AS (
	SELECT 
		  vpad.`year`
		, ROUND((AVG(vpad.payroll_value) - 
				 LAG(AVG(vpad.payroll_value)) OVER (ORDER BY vpad.`year`)) * 
				 100 /
				 LAG(AVG(vpad.payroll_value)) OVER (ORDER BY vpad.`year`),
				 2) AS avg_yearly_payroll_trend
	FROM v_payroll_data AS vpad
	GROUP BY vpad.`year`
	),
	cte_avg_price AS (
	SELECT 
		  vprd.`year`
		, ROUND((AVG(vprd.price_value) -
		  LAG(AVG(vprd.price_value )) OVER (ORDER BY vprd.`year`)) *
		  100 /
		  LAG(AVG(vprd.price_value)) OVER (ORDER BY vprd.`year`),
		  2) AS avg_yearly_price_trend
	FROM v_price_data AS vprd 
	GROUP BY vprd.`year`
	)
SELECT 
	  vgd.`year`
	, vgd.GDP
	, ROUND((vgd.GDP - 
			 LAG(vgd.GDP) OVER (ORDER BY vgd.`year`)) * 
			 100 / 
			 LAG(vgd.GDP) OVER (ORDER BY vgd.`year`),
			 2) AS pct_GDP_trend
	, capa.avg_yearly_payroll_trend
	, capr.avg_yearly_price_trend
FROM cte_avg_price AS capr
LEFT JOIN cte_avg_payroll AS capa
	ON capr.`year` = capa.`year`
LEFT JOIN v_GDP_data AS vgd 
	ON capr.`year` = vgd.`year`
;

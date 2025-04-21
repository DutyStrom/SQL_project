/*
 * QUESTION:
 * How many liters of milk and kilograms of bread can be purchased 
 * for the first and last comparable periods in the available price and wage data?
 * 
 * 
 * source TABLE:
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

-- "Chléb konzumní kmínový" = 111301 -> 1 kg
-- "Mléko polutučné pasterované" = 114201 -> 1 l
-- 2006 - 2018

-- Purchasing power in years 2006 and 2018 across the industry branches
SELECT 
	  vpad.`year`
	, vpad.industry_branch_name
	, vpad.payroll_value
	, vprd.category_name
	, vprd.price_value
	, ROUND(vpad.payroll_value / vprd.price_value) AS purchasable_quantity
	, vprd.price_unit AS quantity_unit
FROM v_payroll_data AS vpad
JOIN v_price_data AS vprd 
	ON vpad.`year` = vprd.`year`
WHERE 1 = 1
	AND vpad.`year` IN (2006, 2018)
	AND vprd.category_code IN (111301, 114201)
ORDER BY vpad.`year`, vpad.payroll_value DESC
;


-- Average purchasing power in years 2006 and 2018 from all industry branches
SELECT 
	  vpad.`year`
	, ROUND(AVG(vpad.payroll_value), 2) AS average_payroll
	, vprd.category_name
	, vprd.price_value
	, ROUND(vpad.payroll_value / vprd.price_value) AS purchasable_quantity
	, vprd.price_unit AS quantity_unit
FROM v_payroll_data AS vpad
JOIN v_price_data AS vprd 
	ON vpad.`year` = vprd.`year`
WHERE 1 = 1
	AND vpad.`year` IN (2006, 2018)
	AND vprd.category_code IN (111301, 114201)
GROUP BY vpad.`year`, vprd.category_name 
ORDER BY vpad.`year`
;
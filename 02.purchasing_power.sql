/*
 * QUESTION:
 * How many liters of milk and kilograms of bread can be purchased 
 * for the first and last comparable periods in the available price and wage data?
 * 
 * 
 * source TABLE:
 * t_petr_bocek_project_sql_primary_final
 */

CREATE OR REPLACE VIEW v_purchasing_power AS (
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
-- "Mléko polotučné pasterované" = 114201 -> 1 l
-- 2006 - 2018

-- Purchasing power in years 2006 and 2018 across the industry branches
SELECT 
	  vpt.`year`
	, vpt.industry_branch_name
	, vpt.payroll_value
	, vpp.category_name
	, vpp.price_value
	, ROUND(vpt.payroll_value / vpp.price_value) AS purchasable_quantity
	, vpp.price_unit AS quantity_unit
FROM v_payroll_trend AS vpt
JOIN v_purchasing_power AS vpp 
	ON vpt.`year` = vpp.`year`
WHERE 1 = 1
	AND vpt.`year` IN (2006, 2018)
	AND vpp.category_code IN (111301, 114201)
ORDER BY vpt.`year`, vpt.payroll_value DESC
;


-- Average purchasing power in years 2006 and 2018 from all industry branches
SELECT 
	  vpt.`year`
	, ROUND(AVG(vpt.payroll_value), 2) AS average_payroll
	, vpp.category_name
	, vpp.price_value
	, ROUND(vpt.payroll_value / vpp.price_value) AS purchasable_quantity
	, vpp.price_unit AS quantity_unit
FROM v_payroll_trend AS vpt
JOIN v_purchasing_power AS vpp 
	ON vpt.`year` = vpp.`year`
WHERE 1 = 1
	AND vpt.`year` IN (2006, 2018)
	AND vpp.category_code IN (111301, 114201)
GROUP BY vpt.`year`, vpp.category_name 
ORDER BY vpt.`year`
;
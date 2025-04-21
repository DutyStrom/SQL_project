/* 
 * Question:
 * WHAT IS PAYROLL TREND IN THE MONITORED YEARS?
 *
 * Source table:
 * engeto_db.t_petr_bocek_project_sql_primary_final
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

-- Interannual payroll trend in monitored years
SELECT
	  vpad.*
	, ROUND((vpad.payroll_value - 
		     LAG(vpad.payroll_value) OVER (PARTITION BY vpad.branch_code ORDER BY vpad.`year`)),
		     2) AS payroll_trend
	, ROUND((vpad.payroll_value - 
			 LAG(vpad.payroll_value) OVER (PARTITION BY vpad.branch_code ORDER BY vpad.`year`)) * 
			 100 / 
			 LAG(vpad.payroll_value) OVER (PARTITION BY vpad.branch_code ORDER BY vpad.`year`),
			 2) AS pct_payroll_trend
FROM v_payroll_data AS vpad
;
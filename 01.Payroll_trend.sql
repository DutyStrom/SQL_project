/* 
 * 
 * Question:
 * WHAT IS PAYROLL TREND IN THE MONITORED YEARS?
 *
 * Source table:
 * engeto_db.t_petr_bocek_project_sql_primary_final
 * 
*/


CREATE OR REPLACE VIEW v_payroll_trend AS (
	SELECT DISTINCT
		  tprifi.`year`
		, tprifi.industry_branch_name
		, tprifi.branch_code
		, tprifi.payroll_value
	FROM engeto_db.t_petr_bocek_project_sql_primary_final AS tprifi
	ORDER BY tprifi.branch_code, `year`
	)
;

SELECT
	  vpt.*
	, ROUND((vpt.payroll_value - 
		   (LAG(vpt.payroll_value) OVER (PARTITION BY vpt.branch_code ORDER BY vpt.`year`))),
		   2) AS payroll_trend
FROM v_payroll_trend AS vpt
;
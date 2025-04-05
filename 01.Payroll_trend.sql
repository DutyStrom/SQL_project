/* 
 * 
 * Question:
 * WHAT IS PAYROLL TREND IN THE MONITORED YEARS?

 * Source tables:
 * engeto_09_2024.t_petr_bocek_project_sql_primary_final
 * 
*/

SELECT 
	*
FROM engeto_09_2024.t_petr_bocek_project_sql_primary_final AS tpbpspf
;

SELECT DISTINCT
	  tpbpspf.`year` 
	, tpbpspf.industry_branch_name 
	, tpbpspf.branch_code 
	, tpbpspf.payroll_value
	, ROUND((tpbpspf.payroll_value - (LAG(tpbpspf.payroll_value) OVER (PARTITION BY tpbpspf.branch_code ORDER BY tpbpspf.`year`))), 2) AS flag
FROM engeto_09_2024.t_petr_bocek_project_sql_primary_final AS tpbpspf
ORDER BY tpbpspf.branch_code, tpbpspf.`year`  
;
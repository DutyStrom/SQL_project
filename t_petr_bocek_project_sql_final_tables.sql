/*
 * author: Petr Boček
 * email: bocek2@seznam.cz
 * discord: Seth_Cz#8510
*/

/*
PRIMARY TABLES
 czechia_payroll AS cp 
 czechia_payroll_calculation AS cpc 
 czechia_payroll_industry_branch AS cpib 
 czechia_payroll_unit AS cpu 
 czechia_payroll_value_type AS cpvt 
 czechia_price AS cp 
 czechia_price_category AS cpc

CZECHIA REGION AND DISTRICT LOOKUP TABLES
 czechia_region AS cr 
 czechia_district AS cd 

ADDITIONAL TABLES
 countries AS c 
 economies AS e 

PROJECT OUTPUT
t_petr_bocek_project_sql_primary_final (Czech Republic)
t_petr_bocek_project_sql_secondary_final (Other European countries)
*/

-- Temporary auxiliary tables
-- czechia_payroll_final_temporary
CREATE OR REPLACE TEMPORARY TABLE t_payroll_final (
	  average_payroll_value DECIMAL(14,4)
	, payroll_industry_branch_code CHAR(1)
	, payroll_industry_branch_name VARCHAR(255)
	, payroll_year INT(11)
	)
SELECT 
	  AVG(cpr.value) AS average_payroll_value
	, cpr.industry_branch_code AS payroll_industry_branch_code
	, cpib.name AS payroll_industry_branch_name
	, cpr.payroll_year 
FROM engeto_db.czechia_payroll AS cpr
JOIN engeto_db.czechia_payroll_industry_branch AS cpib
	ON cpr.industry_branch_code = cpib.code
WHERE cpr.value_type_code = 5958
	AND cpr.unit_code = 200
	AND cpr.calculation_code = 100
GROUP BY cpr.payroll_year, cpr.industry_branch_code
;

-- czechia_price_final_temporary
CREATE OR REPLACE TEMPORARY TABLE t_price_final (
	  average_price_value DOUBLE
	, category_code INT(11)
	, category_name VARCHAR(50)
	, unit_value DOUBLE
	, price_unit VARCHAR(2)
	, price_year INT
	)
SELECT 
	    ROUND(AVG(cp.value), 2) AS average_price_value
	  , cp.category_code AS category_code
	  , cpc.name AS category_name
	  , cpc.price_value AS unit_value
	  , cpc. price_unit AS price_unit
	  , YEAR(cp.date_from) AS price_year
FROM engeto_db.czechia_price AS cp
JOIN engeto_db.czechia_price_category AS cpc
	ON cp.category_code = cpc.code 
WHERE cp.region_code IS NOT NULL
GROUP BY price_year, cp.category_code
;


-- Creating two final tables.

-- t_petr_bocek_project_sql_primary_final
CREATE OR REPLACE TABLE t_petr_bocek_project_sql_primary_final (
	  year INT(8)
	, industry_branch_name VARCHAR(255)
	, branch_code CHAR(1)
	, payroll_value DECIMAL(14,4)
	, category_name VARCHAR(50)
	, category_code INT(11)
	, unit_value DOUBLE
	, price_unit VARCHAR(2)
	, price_value DOUBLE
	)
SELECT
	  tpayf.payroll_year AS 'year'
	, tpayf.payroll_industry_branch_name AS industry_branch_name
	, tpayf.payroll_industry_branch_code AS branch_code
	, tpayf.average_payroll_value AS payroll_value
	, tprif.category_name 
	, tprif.category_code
	, tprif.unit_value
	, tprif.price_unit
	, tprif.average_price_value AS price_value
FROM t_payroll_final AS tpayf
LEFT JOIN t_price_final AS tprif
	ON tpayf.payroll_year = tprif.price_year
;

-- t_petr_bocek_project_sql_secondary_final
CREATE OR REPLACE TABLE t_petr_bocek_project_sql_secondary_final (
	  `year` INT(11)
	, country VARCHAR(255)
	, GDP DOUBLE
	, gini DOUBLE
	, population DOUBLE
	)
SELECT
	  e.`year`
	, e.country  
	, e.GDP 
	, e.gini 
	, e.population  
FROM economies AS e 
WHERE 
	e.`year` IN (
			SELECT DISTINCT
				tpbpspf.`year` 
			FROM t_petr_bocek_project_sql_primary_final AS tpbpspf 
			)
	AND
	e.country IN (
			SELECT DISTINCT
				c.country
			FROM countries AS c 
			)
;
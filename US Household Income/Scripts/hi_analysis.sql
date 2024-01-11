/*
HOUSEHOLD INCOME AND EMPLOYMENT IN THE UNITED STATES

ANALYST: ALAN SAMPEDRO
DATE 2024-01-08
*/



-- Top 10 largest US States by land area
SELECT state_name,
	   SUM(a_land) AS total_a_land,
	   SUM(a_water) AS total_a_water
  FROM us_household_income
 GROUP BY state_name
 ORDER BY total_a_land DESC
 LIMIT 10
;


-- Top 10 US States by water area
SELECT state_name,
	   SUM(a_water) AS total_a_water
  FROM us_household_income
 GROUP BY state_name
 ORDER BY total_a_water DESC
 LIMIT 10
;


-- Top 10 lowest median household income states
SELECT state_name,
	   ROUND(CAST(AVG(mean) AS NUMERIC), 1) AS avg_household_income,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY median) AS NUMERIC), 1) AS median_household_income
  FROM us_household_income
 WHERE mean != 0
 GROUP BY state_name
 ORDER BY median_household_income
 LIMIT 10
;


-- Top 10 highest median household income states
SELECT state_name,
	   ROUND(CAST(AVG(mean) AS NUMERIC), 1) AS avg_household_income,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY median) AS NUMERIC), 1) AS median_household_income
  FROM us_household_income
 WHERE mean != 0
 GROUP BY state_name
 ORDER BY median_household_income DESC
 LIMIT 10
;


-- Top 10 highest median cost of living index income states
SELECT a.state_name,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.coli) AS NUMERIC), 1) AS median_coli
  FROM us_household a
  	   JOIN cost_living_index b
	     ON a.state_ab = b.state
 GROUP BY a.state_name
 ORDER BY median_coli DESC
 LIMIT 10
;


-- Top 10 lowest median cost of living index income states
SELECT a.state_name,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.coli) AS NUMERIC), 1) AS median_coli
  FROM us_household a
  	   JOIN cost_living_index b
	     ON a.state_ab = b.state
 GROUP BY a.state_name
 ORDER BY median_coli
 LIMIT 10
;


-- Top 10 highest median employed civilians states in 2022
SELECT area,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY non_inst) AS NUMERIC), 1) AS median_non_inst,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY employed) AS NUMERIC), 1) AS median_employed,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY employed_ratio) AS NUMERIC), 1) AS median_employed_ratio
  FROM us_unemployment
 WHERE year = 2022
 GROUP BY area
 ORDER BY median_employed_ratio DESC
 LIMIT 10
;


-- Top 10 lowest median employed civilians states in 2022
SELECT area,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY non_inst) AS NUMERIC), 1) AS median_non_inst,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY employed) AS NUMERIC), 1) AS median_employed,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY employed_ratio) AS NUMERIC), 1) AS median_employed_ratio
  FROM us_unemployment
 WHERE year = 2022
 GROUP BY area
 ORDER BY median_employed_ratio
 LIMIT 10
;


-- Top 10 highest median unemployed civilians states in 2022
SELECT area,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY non_inst) AS NUMERIC), 1) AS median_non_inst,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unemployed) AS NUMERIC), 1) AS median_unemployed,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unemployed_ratio) AS NUMERIC), 1) AS median_unemployed_ratio
  FROM us_unemployment
 WHERE year = 2022
 GROUP BY area
 ORDER BY median_unemployed_ratio DESC
 LIMIT 10
;


-- Top 10 lowest median unemployed civilians states in 2022
SELECT area,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY non_inst) AS NUMERIC), 1) AS median_non_inst,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unemployed) AS NUMERIC), 1) AS median_unemployed,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unemployed_ratio) AS NUMERIC), 1) AS median_unemployed_ratio
  FROM us_unemployment
 WHERE year = 2022
 GROUP BY area
 ORDER BY median_unemployed_ratio
 LIMIT 10
;


-- Household income, cost of living, and employment by state
WITH
cost_living_state AS (
SELECT state,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY coli) AS NUMERIC), 1) AS coli
  FROM cost_living_index
 GROUP BY state
),

household_income_state AS (
SELECT a.state_ab, a.state_name,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.median) AS NUMERIC), 1) AS median_hh_income
  FROM us_household a
  	   JOIN us_household_income b
	   	 ON a.id = b.id
 WHERE median != 0
 GROUP BY a.state_ab, a.state_name
),

unemployment_state AS (
SELECT area,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY non_inst) AS NUMERIC), 1) AS non_institutional,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY labor_force_ratio) AS NUMERIC), 1) AS labor_force_ratio,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY employed_ratio) AS NUMERIC), 1) AS employed_ratio,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY unemployed_ratio) AS NUMERIC), 1) AS unemployed_ratio
  FROM us_unemployment
 WHERE year = 2022
 GROUP BY area
)

SELECT his.state_name AS state,
	   CAST(his.median_hh_income AS INTEGER),
	   cls.coli,
	   CAST(ues.non_institutional AS INTEGER), 
	   ues.labor_force_ratio, ues.employed_ratio, ues.unemployed_ratio
  FROM household_income_state his
  	   JOIN cost_living_state cls
	   	 ON his.state_ab = cls.state
	   JOIN unemployment_state ues
	     ON his.state_name = ues.area
;


-- New York median household income and cost of living index by city
WITH
household_income_ny AS (
SELECT a.state_ab, a.state_name, a.city,
	   ROUND(CAST(AVG(b.median) AS NUMERIC), 1 ) AS median_household_income
  FROM us_household a
  	   JOIN us_household_income b
	   	 ON a.id = b.id
 WHERE median != 0
   AND state_ab = 'NY'
 GROUP BY a.state_ab, a.state_name, a.city
)

SELECT a.state_name, a.city, a.median_household_income, b.coli
  FROM household_income_ny a
  LEFT JOIN (SELECT state, city, coli
  			   FROM cost_living_index
 			  WHERE state = 'NY'
			 ) b
		 ON a.state_ab = b.state
		AND a.city = b.city
 WHERE median_household_income != 300000.0 --> Filler values
 ORDER BY median_household_income DESC
;
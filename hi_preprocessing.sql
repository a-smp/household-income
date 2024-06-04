

-- US HOUSEHOLD INCOME DATASET


-- Evaluate for duplicated records
SELECT id, COUNT(id)
  FROM us_household_income
 GROUP BY id
HAVING COUNT(id) > 1


-- Identify row_id number for duplicated records
SELECT *
FROM (SELECT row_id, id,
	         ROW_NUMBER() OVER(PARTITION BY id
						 ORDER BY id) AS row_num
  		FROM us_household_income) AS duplicates
WHERE row_num > 1
;


-- Remove duplicated records
DELETE FROM us_household_income
 WHERE row_id IN (SELECT row_id
 	 				FROM (SELECT row_id, id,
	           					 ROW_NUMBER() OVER(PARTITION BY id
									 			   ORDER BY id) AS row_num
  		  					FROM us_household_income
	    				  ) AS duplicates
				   WHERE row_num > 1
				  )
;

-- Evaluate for inconsistencies in state_name
SELECT DISTINCT state_name AS unique_state
  FROM us_household_income
 ORDER BY unique_state
;


-- Standardize inconsistent values in state_name
UPDATE us_household_income
   SET state_name = 'Georgia'
  WHERE state_name = 'georia'
;

UPDATE us_household_income
   SET state_name = 'Alabama'
  WHERE state_name = 'alabama'
;


-- Evaluate for inconsistencies in state_ab
SELECT DISTINCT state_ab AS unique_stateab
  FROM us_household_income
 ORDER BY unique_stateab
;


-- Evaluate for missing values in place
SELECT *
  FROM us_household_income
 WHERE place IS NULL
 ORDER BY row_id
;


-- Impute missing value based on county and city values for the same record
UPDATE us_household_income
   SET place = 'Autaugaville'
 WHERE county = 'Autauga County'
   AND city = 'Vinemont'
;


-- Evaluate for inconsistencies in type 
SELECT type,
	   COUNT(type) AS type_tally
  FROM us_household_income
 GROUP BY type
 ORDER BY type
;


-- Standardize values in type
UPDATE us_household_income
   SET type = 'Borough'
 WHERE type = 'Boroughs'
;

UPDATE us_household_income
   SET type = 'Village'
 WHERE type = 'village'
;

UPDATE us_household_income
   SET type = 'City'
 WHERE type = 'CITY'
;


-- Evaluate for inconsistencies in a_land and a_water
SELECT a_land, a_water
  FROM us_household_income
   WHERE (a_land = 0 OR a_land IS NULL)
;

SELECT a_land, a_water
  FROM us_household_income
 WHERE (a_water = 0 OR a_water IS NULL)
;

SELECT a_land, a_water
  FROM us_household_income
 WHERE (a_land = 0 OR a_land IS NULL)
   AND (a_water = 0 OR a_water IS NULL)
;






-- US HOUSEHOLD INCOME STATS DATASET


-- Evaluate for duplicated records (us_household_income_stats)
SELECT id, COUNT(id)
  FROM us_household_income_stats
 GROUP BY id
HAVING COUNT(id) > 1
;



-- US UNEMPLOYMENT DATASET


-- Evaluate for inconsistencies in area
SELECT DISTINCT area
  FROM us_unemployment
;

--Standardize values in area
UPDATE us_unemployment
   SET area = 'New York'
 WHERE area = 'New York city'
;

UPDATE us_unemployment
   SET area = 'California'
 WHERE area = 'Los Angeles County'
;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
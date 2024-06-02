-- MYSQL DATA CLEANING PROJECT
-- CSV:	data_cleaning_family.csv

-- Step 1
-- Import data from csv into family_raw table

	CREATE DATABASE family;
    USE family;

	CREATE TABLE family_raw
	(
	num INT,
	id INT,
	gender VARCHAR(1),
	name VARCHAR(100),
	relationship VARCHAR(100),
	birth_date VARCHAR(50),
	birth_place VARCHAR(200),
	death_date VARCHAR(50),
	death_place VARCHAR(200)
	);

	-- use MySQL Workbench data import wizard to import csv to family_raw
	
    -- look at raw data
	SELECT * FROM family_raw;


-- Step 2

	-- Create copy of family_raw table
	CREATE TABLE family_staging
	LIKE family_raw;

	-- Copy raw data into staging table
	INSERT family_staging
	SELECT * FROM family_raw;

-- Step 3  FIND AND DELETE DUPLICATE RECORDS

WITH duplicate_cte AS
(
SELECT 
*, 
ROW_NUMBER() OVER (PARTITION BY `name`, birth_date, birth_place, death_date, death_place) AS row_num
FROM family_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- check duplicates out
SELECT * FROM family_staging WHERE name = "Doris Maud Day";

-- create copy of table with row_num column

CREATE TABLE `family_staging2` (
  `num` int DEFAULT NULL,
  `id` int DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `birth_date` varchar(50) DEFAULT NULL,
  `birth_place` varchar(200) DEFAULT NULL,
  `death_date` varchar(50) DEFAULT NULL,
  `death_place` varchar(200) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- insert data into new table
INSERT INTO family_staging2
SELECT 
*, 
ROW_NUMBER() OVER (PARTITION BY `name`, birth_date, birth_place, death_date, death_place) AS row_num
FROM family_staging;

-- delete the duplicates
DELETE FROM family_staging2
WHERE row_num > 1;

-- STANDARDIZING DATA

	-- technique for trimming characters from the end
	-- here I'm getting rid of names ending in ", Jr" or ", Sr"

SELECT name FROM family_staging2
WHERE name LIKE '%, Jr%';

UPDATE
family_staging2
SET name = TRIM(TRAILING ', Jr' FROM name)
WHERE name LIKE '%Fussey%';

	-- changing date string to date format
	-- STR_TO_DATE(column, format)
	-- all very well when the string is in date format already but that's not the case here!

   -- STORED FUNCTION 
	-- year_extractor
    -- extracts year from string and casts as integer

DELIMITER //
CREATE FUNCTION year_extractor(date_string VARCHAR(50)) 
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE extracted_year INT;
    IF date_string REGEXP '-|/[0-9]{2}$' THEN
    SET extracted_year = CAST(CONCAT("19",REGEXP_SUBSTR(date_string, '[0-9]{2}$')) AS SIGNED);
    -- extracts 4 digit group from within string and casts as integer
    ELSEIF date_string REGEXP '[0-9]{4}' THEN
    SET extracted_year = CAST(REGEXP_SUBSTR(date_string,'[0-9]{4}') AS SIGNED);
    ELSE
    SET extracted_year = date_string;
 END IF;
    RETURN extracted_year;
END//
DELIMITER ;

-- NULL & BLANK VALUES
	-- populate if possible
    -- turn blanks into null

SELECT * FROM family_staging2
WHERE birth_date IS NULL;
-- birth_date can't be populated where it's null but make sure it's null and not blank

SELECT * FROM family_staging2
WHERE death_date IS NULL;

-- check and correct rogue blanks that aren't null
SELECT * FROM family_staging2
WHERE LENGTH(death_date) < 1;

UPDATE family_staging2
SET death_date = NULL
WHERE LENGTH(death_date) < 1;

UPDATE family_staging2
SET birth_date = NULL
WHERE LENGTH(birth_date) < 1;

SELECT * FROM family_staging2
WHERE LENGTH(gender) < 1;

UPDATE family_staging2
SET gender = NULL
WHERE LENGTH(gender) < 1;

SELECT num, name, gender FROM family_staging2
WHERE gender IS NULL;

-- set blank birth and death place to NULL
SELECT * FROM family_staging2
WHERE LENGTH(birth_place) < 1;

UPDATE family_staging2
SET birth_place = NULL
WHERE LENGTH(birth_place) < 1;

SELECT * FROM family_staging2
WHERE LENGTH(death_place) < 1;

UPDATE family_staging2
SET death_place = NULL
WHERE LENGTH(death_place) < 1;

-- the only way to populate null values in GENDER column is manually going off name which is possible with a small number of records
-- update gender where null for the males
UPDATE family_staging2
SET gender = "M" 
WHERE num IN (293,505,577,479,567,568,671,724,148,696,478,712,8,151,591,569,480);

-- then the rest of the nulls are F
UPDATE family_staging2
SET gender = "F"
WHERE gender IS NULL;

-- if you can populate from another row use self join to do it (N/A for this data)

-- REMOVE REDUNDANT COLUMNS AND ROWS

-- remove the row_num column we used to remove duplicates
ALTER TABLE family_staging2
DROP COLUMN row_num;


-- CREATE NEW TABLE TO RECEIVE DATA FROM family_staging2
	-- Need to extract birth and death years as integers and split first and last names

CREATE TABLE family_cleaned
(	
	person_id INT AUTO_INCREMENT,
    num INT,
    id INT,
	lastname VARCHAR(50),
    firstname VARCHAR(50),
    birth_date VARCHAR(50),
    birth_year INT,
    birth_place VARCHAR(100),
    death_date VARCHAR(50),
    death_year INT,
    death_place VARCHAR(100),
    sex VARCHAR(1),
    relationship VARCHAR(100),
    PRIMARY KEY (person_id)
);

-- INSERT CLEANED DATA INTO family_cleaned TABLE
	-- see below for stored function which extracts year as integer from string

INSERT INTO family_cleaned (num, id, lastname, firstname, birth_date, birth_year, birth_place, death_date, death_year, death_place, sex, relationship)
	SELECT
		num,
        id,
        SUBSTRING_INDEX( name, " ", -1 ),
        SUBSTRING(name,1,CHARACTER_LENGTH(name)-CHARACTER_LENGTH(SUBSTRING_INDEX( name, " ", -1 ))),
        birth_date,
        year_extractor(birth_date),
        birth_place,
        death_date,
        CASE
		WHEN year_extractor(death_date) < year_extractor(birth_date) THEN year_extractor(death_date) + 100 
		ELSE year_extractor(death_date)
		END AS death_year,
        death_place,
        gender,
        relationship
	FROM family_staging2;
    
    SELECT * FROM family_cleaned ORDER BY num;
    
    -- get rid of redundant id column (now we have person_id instead)
    ALTER TABLE family_cleaned
    DROP COLUMN id;
    
    SELECT * FROM family_cleaned ORDER BY num;
    

    
    
    


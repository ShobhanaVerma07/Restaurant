-- Creating Table 

CREATE TABLE restaurant_data (
    Restaurant_Name TEXT,
    Cuisine TEXT,
    Rating TEXT,
    Number_of_Ratings TEXT,
    Average_Price TEXT,
    Number_of_Offers TEXT,
    Offer_Name TEXT,
    Area TEXT,
    Pure_Veg TEXT,
    Location TEXT
);

-- loading data (large file)

LOAD DATA INFILE 'C:/Projects/Restaurant_project/swiggy_file.csv'
INTO TABLE restaurant_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Preprocessing of Data

SET SQL_SAFE_UPDATES = 0;

-- Handlimg Null Values
-- null values count automatically
DELIMITER //

-- CREATE PROCEDURE count_null_rows()
-- BEGIN
--     DECLARE sql_query TEXT;

--     SELECT 
--         GROUP_CONCAT(
--             CONCAT('SUM(CASE WHEN `', column_name, '` IS NULL THEN 1 ELSE 0 END) AS `', column_name, '`')
--         ) INTO sql_query
--     FROM information_schema.columns 
--     WHERE table_name = 'restaurant_data' AND table_schema = DATABASE();  -- Ensure you are in the correct database

--     SET @sql = CONCAT('SELECT ', sql_query, ' FROM restaurant_data');
--     PREPARE stmt FROM @sql;  -- Prepare the SQL statement
--     EXECUTE stmt;            -- Execute the prepared statement
--     DEALLOCATE PREPARE stmt; -- Clean up the prepared statement
-- END //

-- DELIMITER ;

-- call count_null_rows();

-- Identifying null values manually
-- SELECT 
--     SUM(CASE WHEN TRIM(Restaurant_Name) IS NULL OR TRIM(Restaurant_Name) = '' THEN 1 ELSE 0 END) AS Null_Restaurant_Name,
--     SUM(CASE WHEN TRIM(Cuisine) IS NULL OR TRIM(Cuisine) = '' THEN 1 ELSE 0 END) AS Null_Cuisine,
--     SUM(CASE WHEN TRIM(Rating) IS NULL OR TRIM(Rating) = '' THEN 1 ELSE 0 END) AS Null_Rating,
--     SUM(CASE WHEN TRIM(Number_of_Ratings) IS NULL OR TRIM(Number_of_Ratings) = '' THEN 1 ELSE 0 END) AS Null_Number_of_Ratings,
--     SUM(CASE WHEN TRIM(Average_Price) IS NULL OR TRIM(Average_Price) = '' THEN 1 ELSE 0 END) AS Null_Average_Price,
--     SUM(CASE WHEN TRIM(Number_of_Offers) IS NULL OR TRIM(Number_of_Offers) = '' THEN 1 ELSE 0 END) AS Null_Number_of_Offers,
--     SUM(CASE WHEN TRIM(Offer_Name) IS NULL OR TRIM(Offer_Name) = '' THEN 1 ELSE 0 END) AS Null_Offer_Name,
--     SUM(CASE WHEN TRIM(Area) IS NULL OR TRIM(Area) = '' THEN 1 ELSE 0 END) AS Null_Area,
--     SUM(CASE WHEN TRIM(Pure_Veg) IS NULL OR TRIM(Pure_Veg) = '' THEN 1 ELSE 0 END) AS Null_Pure_Veg,
--     SUM(CASE WHEN TRIM(Location) IS NULL OR TRIM(Location) = '' THEN 1 ELSE 0 END) AS Null_Location
-- FROM restaurant_data;
-- "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
-- Cleaning Restaurant_Name column

-- converting name to lower case
UPDATE restaurant_data
SET Restaurant_Name = LOWER(TRIM(Restaurant_Name));

-- checking for the null values
SELECT * FROM restaurant_data
WHERE TRIM(Restaurant_Name) IS NULL OR TRIM(Restaurant_Name) = '';

-- Unique Restaurant_Name
SELECT 
    Restaurant_Name, COUNT(*) AS occurrences
FROM restaurant_data
GROUP BY Restaurant_Name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Cuisine

-- Converting to lower case
UPDATE restaurant_data
SET Cuisine = LOWER(TRIM(Cuisine));

-- checking for the null values
SELECT * FROM restaurant_data
WHERE TRIM(Cuisine) IS NULL OR TRIM(Cuisine) = '';

-- Filling null values that matches.
CREATE TEMPORARY TABLE temp_restaurant_data AS
SELECT Restaurant_Name, Average_Price,Cuisine,Rating
FROM restaurant_data
WHERE Restaurant_Name IN (
    SELECT Restaurant_Name 
    FROM restaurant_data
    WHERE TRIM(Cuisine) IS NULL OR TRIM(Cuisine) = ''
)
GROUP BY Restaurant_Name, Average_Price,Cuisine,Rating;

DESCRIBE temp_restaurant_data;

UPDATE restaurant_data rd
JOIN temp_restaurant_data temp
    ON rd.Restaurant_Name = temp.Restaurant_Name 
    AND rd.Average_Price = temp.Average_Price
SET 
    rd.Rating = temp.Rating,
    rd.Cuisine = temp.Cuisine
WHERE TRIM(rd.Cuisine) IS NULL OR TRIM(rd.Cuisine) = '';


-- "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Rating Column 

-- Idntifyinh rows with NEW entry
SELECT * FROM Restaurant_data
WHERE Rating ="NEW";

-- Changing it to 0 
UPDATE Restaurant_data
SET Rating=0
WHERE Rating ="NEW";
SELECT * FROM Restaurant_data;

-- changing -- values to null
SELECT * FROM Restaurant_data
WHERE Rating ="--";
UPDATE restaurant_data
SET rating = NULL
WHERE rating = '--';

-- "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Average_Price column 
-- changing column name
ALTER TABLE restaurant_data
CHANGE COLUMN Average_Price Average_Price_fortwo text;

-- extracting only price 
UPDATE restaurant_data
SET Average_Price_fortwo = CAST(REGEXP_REPLACE(Average_Price_fortwo, '[^0-9]', '') AS UNSIGNED)
WHERE Average_Price_fortwo IS NOT NULL;

-- replace blank value with null 
UPDATE restaurant_data
SET Average_Price_fortwo = NULL
WHERE Average_Price_fortwo = '';

SELECT * FROM restaurant_data
WHERE Average_Price_fortwo = '';

-- "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Number_of_Offers column
 -- null values
 SELECT * FROM restaurant_data
 WHERE TRIM(Number_of_Offers)=" "; -- no null values

-- "------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Area column 

 -- null values
 SELECT * FROM restaurant_data
 WHERE TRIM(Area)="" OR TRIM(Area) IS NULL; 
 -- there are only two null values and it can be filled manually
 UPDATE restaurant_data 
 SET AREA ="Laitumkhrah"
 WHERE Restaurant_Name="shawarma wrap";
 UPDATE restaurant_data 
 SET AREA ="Laitumkhrah"
 WHERE Restaurant_Name="senpai";
 -- now there are no null values
 
-- converting name to lower case
UPDATE restaurant_data
SET AREA = LOWER(TRIM(Area));

-- "----------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Pure_Veg column
 -- null values
 SELECT * FROM restaurant_data
 WHERE TRIM(Pure_Veg)="" OR TRIM(Pure_Veg) IS NULL ; -- no null values
 
 -- converting to lower case
UPDATE restaurant_data
SET Pure_Veg = LOWER(TRIM(Pure_Veg));

-- "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Pure_Veg column
 -- null values
 SELECT * FROM restaurant_data
 WHERE TRIM(Location)="" OR TRIM(Location) IS NULL ; -- no null values
 
 -- converting to lower case
UPDATE restaurant_data
SET Location = LOWER(TRIM(Location));


-- Cleaning Nummber_of_Ratings column 

-- replace blank value with null 
UPDATE restaurant_data
SET Number_of_Ratings = NULL
WHERE Number_of_Ratings = '';

SELECT * FROM restaurant_data
WHERE Number_of_Ratings IS NULL;


-- Cleaning Nummber_of_Ratings column 

-- replace blank value with null 
UPDATE restaurant_data
SET Number_of_Ratings = NULL
WHERE Number_of_Ratings = '';

SELECT * FROM restaurant_data
WHERE Number_of_Ratings IS NULL;

-- Cleaning Nummber_of_Ratings column 

-- replace blank value with null 
UPDATE restaurant_data
SET Number_of_Ratings = NULL
WHERE Number_of_Ratings = '';

SELECT * FROM restaurant_data
WHERE Number_of_Ratings IS NULL;

-- "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Nummber_of_Ratings column 

-- replace blank value with null 
UPDATE restaurant_data
SET Number_of_Ratings = NULL
WHERE Number_of_Ratings = '';

SELECT * FROM restaurant_data
WHERE Number_of_Ratings IS NULL;

-- "------------------------------------------------------------------------------------------------------------------------------------------------------------------"

-- Cleaning Offer_Name column 

-- replace blank value with null 
UPDATE restaurant_data
SET Offer_Name = NULL
WHERE Offer_Name ='';

SELECT * FROM restaurant_data
WHERE Offer_Name IS NULL;













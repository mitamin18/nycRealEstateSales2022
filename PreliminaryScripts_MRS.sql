use DA_Project
#Data Manipulation Language

#General Views

#A) For Creating a Map View of all neighborhood & area data
SELECT Area, NEIGHBORHOOD , EXTRACT(MONTH FROM `SALE DATE`) AS Month, SUM(`SALE PRICE`) AS total_sales
    FROM Manhattan_RS
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

#B) For creating building sales view
SELECT EXTRACT(MONTH FROM `SALE DATE`) AS Month, Area, GeneralBuildingCategory, SUM(`SALE PRICE`)
FROM Manhattan_RS
GROUP BY 3,2,1
ORDER BY 3,2,1

#C) For analyzing sale price per square foot rate among building classes
SELECT GeneralBuildingCategory AS Building_Type, LEFT(`BUILDING CLASS AT TIME OF SALE`, 1) AS Building_Class,
       EXTRACT(Week FROM `SALE DATE`) AS Week, GeneralBuildingCategory,
       SUM(`SALE PRICE`) AS sales,
       COUNT(`SALE PRICE`) AS transactions,
       AVG(`GROSS SQUARE FEET`) AS avg_sq_ft
FROM Manhattan_RS
GROUP BY 1,2,3
ORDER BY 1,2,3;

#D) For time series data
SELECT `SALE DATE`,
       EXTRACT(month from `SALE DATE`) AS month,
       EXTRACT(day from `SALE DATE`) AS day,
       `SALE PRICE`
FROM Manhattan_RS
ORDER BY 1,2 ASC;

#E) For Most Expensive Properties
SELECT DISTINCT id, `SALE DATE`, area, NEIGHBORHOOD, Full_Address, `ZIP CODE`,
       `BUILDING CLASS CATEGORY`, GeneralBuildingCategory, LEFT(`BUILDING CLASS AT TIME OF SALE`,1),
       `GROSS SQUARE FEET`, decade, `YEAR BUILT`, `SALE PRICE`,
       AVG(`SALE PRICE`) OVER() AS nyc_avgSalePrice
FROM age_quality
ORDER BY `SALE PRICE` DESC;

#F) For building age view
#Age_View
SELECT `SALE DATE`, Area, NEIGHBORHOOD,
       Full_Address, `ZIP CODE`,
       GeneralBuildingCategory AS building_type,
       `BUILDING CLASS CATEGORY` AS building_category,
       LEFT(`BUILDING CLASS AT TIME OF SALE`, 1) AS building_class,
       `SALE PRICE` AS salePrice,
        decade AS decade,
        2022 - `YEAR BUILT` AS age,
        avg(2022-`YEAR BUILT`) OVER() AS nyc_averageAge,
       `GROSS SQUARE FEET` AS sqFeet
FROM age_quality
ORDER BY 1, 2, 3;

#---------------------------------------------------------------------------------------------------------

#1A)Sales & Transaction activity over 2022 on a weekly running basis view [IMPORT]
SELECT DISTINCT `SALE DATE`,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`) OVER(PARTITION BY `SALE DATE`),2)) AS daily_sales,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`) OVER(ORDER BY `SALE DATE` ASC),2)) AS running_sales,
       COUNT(`SALE PRICE`) OVER(PARTITION BY `SALE DATE`) AS daily_transactions,
       COUNT(`SALE PRICE`) OVER(ORDER BY `SALE DATE` ASC) AS running_transactions
FROM Manhattan_RS
WHERE YEAR(`SALE DATE`) != 1900
ORDER BY 1 ASC;

#1B) Statistics for 2022 [IMPORT]
SELECT
       CONCAT('$', FORMAT(MAX(`SALE PRICE`),2)) AS max_sale_price,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`),2)) AS avg_sale_price,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`),2)) AS total_sales,
       COUNT(`SALE PRICE`) AS total_transactions,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`)/COUNT(`SALE PRICE`),2)) AS sale_per_transaction,
       ROUND(AVG(`YEAR BUILT`),0) AS avg_year_built,
       AVG((2022 - `YEAR BUILT`)) AS avg_age
FROM Manhattan_RS;

#1C) Including all statistics on a month view [IMPORT]
SELECT EXTRACT(MONTH FROM `SALE DATE`) AS Month,
       CONCAT('$', FORMAT(MAX(`SALE PRICE`),2)) AS max_sale_price,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`),2)) AS avg_sale_price,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`),2)) AS total_sales,
       COUNT(`SALE PRICE`) AS total_transactions,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`)/COUNT(`SALE PRICE`),2)) AS sale_per_transaction,
       ROUND(AVG(`YEAR BUILT`),0) AS avg_year_built,
       AVG((2022 - `YEAR BUILT`)) AS avg_age
FROM Manhattan_RS
GROUP BY 1
ORDER BY Month ASC;

#1D) Including all statistics on a weekly view [IMPORT]
SELECT EXTRACT(WEEK FROM `SALE DATE`) AS Week,
       CONCAT('$', FORMAT(MAX(`SALE PRICE`),2)) AS max_sale_price,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`),2)) AS avg_sale_price,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`),2)) AS total_sales,
       COUNT(`SALE PRICE`) AS total_transactions,
       CONCAT('$', FORMAT(SUM(`SALE PRICE`)/COUNT(`SALE PRICE`),2)) AS sale_per_transaction
FROM Manhattan_RS
GROUP BY 1
ORDER BY week ASC;

#-------------------------------------------------

/*Comparing sp/sf ratio of neighborhood to entire median nyc rate*/
#2A) Calculating sales price per square foot for each property [GENERAL VIEW]
SELECT id, Full_Address,NEIGHBORHOOD, GeneralBuildingCategory, `BUILDING CLASS CATEGORY`,`SALE PRICE`,
       (`SALE PRICE`/`GROSS SQUARE FEET`) AS sp_per_sqf
FROM Manhattan_RS
ORDER BY sp_per_sqf DESC;

#2B) Calculate sales price per square foot for each neighborhood [GENERAL VIEW]
SELECT NEIGHBORHOOD,
       AVG(`SALE PRICE`/`GROSS SQUARE FEET`) AS sp_per_sqf
FROM Manhattan_RS
WHERE `GROSS SQUARE FEET` IS NOT NULL
GROUP BY NEIGHBORHOOD
ORDER BY sp_per_sqf DESC;

#2C) Calculate sales price per square foot for each area and compare area ratio to entire nyc ratio [IMPORT]
SELECT DISTINCT AREA,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY AREA),2)) AS district_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS nyc_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY AREA) - AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS difference
FROM Manhattan_RS
# WHERE ID NOT IN (15525, 13384) Accounted for outliers
ORDER BY district_ratio DESC;

#2D) Calculate sales price per square foot for each neighborhood and compare area ratio to entire nyc ratio [IMPORT]
SELECT DISTINCT AREA, NEIGHBORHOOD,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY NEIGHBORHOOD),2)) AS neighborhood_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS nyc_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY NEIGHBORHOOD) - AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS difference
FROM Manhattan_RS
ORDER BY neighborhood_ratio DESC;

#2E) Calculate sales price per square foot for each GBC and compare gbc ratio to entire nyc ratio [IMPORT]
SELECT DISTINCT GeneralBuildingCategory AS building_type,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY GeneralBuildingCategory),2)) AS gbc_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS nyc_ratio,
       CONCAT('$', FORMAT(AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(PARTITION BY GeneralBuildingCategory) - AVG(`SALE PRICE`/`GROSS SQUARE FEET`) OVER(),2)) AS difference
FROM Manhattan_RS
# WHERE ID NOT IN (15525, 13384) #Accounted for outliers
ORDER BY difference DESC;

#2F) Calculate sales price per square foot for each GBC in each neighborhood and compare gbc by neighbordhood ratio to entire nyc ratio [IMPORT]
SELECT AREA, Neighborhood, LEFT(`BUILDING CLASS AT TIME OF SALE`,1) AS building_class,
       AVG(`SALE PRICE`/`GROSS SQUARE FEET`) AS sp_per_sqf
FROM Manhattan_RS
WHERE `GROSS SQUARE FEET` IS NOT NULL
GROUP BY 1,2,3
ORDER BY building_class, sp_per_sqf DESC;

#-------------------------------------------------

#3) Analyze the top 25 most expensive properties
#create a view to easily reference rank and price data
CREATE VIEW mega_listing AS
SELECT DISTINCT AREA, NEIGHBORHOOD, Full_Address, BCK,LOT, BCK_LOT, `BUILDING CLASS CATEGORY`,
                `BUILDING CLASS AT TIME OF SALE`, `SALE PRICE` AS sale_price,
       DENSE_RANK() OVER(ORDER BY `SALE PRICE` DESC) AS property_rank,
      (`SALE PRICE`/(select sum(`SALE PRICE`) from Manhattan_RS)) AS per_of_totalsales
FROM Manhattan_RS;

#3A) Grouped by area [IMPORT]
SELECT Area,
       count(sale_price) AS transactions,
       count(sale_price) / (select count(sale_price) from mega_listing where property_rank <=25) * 100 AS per_of_mega_transactions,
       count(sale_price)/(select count(sale_price) from mega_listing) *100 AS per_total_transactions,
       SUM(sale_price) AS sales,
       MAX(sale_price) AS max_sale,
       SUM(sale_price) / (select sum(sale_price) from mega_listing where property_rank <=25) * 100 AS per_mega_sales,
       sum(sale_price)/(select sum(sale_price) from mega_listing) * 100 AS per_total_sales,
       MAX(sale_price)/(select sum(sale_price) from mega_listing where property_rank <=25) * 100 as max_as_per_total_sales
FROM mega_listing
WHERE property_rank <=25
GROUP BY 1
ORDER BY sales DESC;

#3B) Grouped by neighborhood [IMPORT]
SELECT AREA, NEIGHBORHOOD,
       count(sale_price) AS transactions,
       count(sale_price) / (select count(sale_price) from mega_listing where property_rank <=25) * 100 AS per_of_mega_transactions,
       count(sale_price)/(select count(sale_price) from mega_listing) *100 AS per_total_transactions,
       SUM(sale_price) AS sales,
       MAX(sale_price) AS max_sale,
       SUM(sale_price) / (select sum(sale_price) from mega_listing where property_rank <=25) * 100 AS per_mega_sales,
       sum(sale_price)/(select sum(sale_price) from mega_listing) * 100 AS per_total_sales,
       MAX(sale_price)/(select sum(sale_price) from mega_listing where property_rank <=25) * 100 as max_as_per_total_sales
FROM mega_listing
WHERE property_rank <=25
GROUP BY 1,2
ORDER BY transactions DESC;

#3C) Grouped by building class [IMPORT]
SELECT LEFT(`BUILDING CLASS AT TIME OF SALE`, 1) AS building_class,
       count(sale_price) AS transactions,
       count(sale_price) / (select count(sale_price) from mega_listing where property_rank <=25) * 100 AS per_of_mega_transactions,
       count(sale_price)/(select count(sale_price) from mega_listing) *100 AS per_total_transactions,
       SUM(sale_price) AS sales,
       MAX(sale_price) AS max_sale,
       SUM(sale_price) / (select sum(sale_price) from mega_listing where property_rank <=25) * 100 AS per_mega_sales,
       sum(sale_price)/(select sum(sale_price) from mega_listing) * 100 AS per_total_sales,
       MAX(sale_price)/(select sum(sale_price) from mega_listing where property_rank <=25) * 100 as max_as_per_total_sales
FROM mega_listing
WHERE property_rank <= 25
GROUP BY 1
order bY building_class DESC;

#3D) Grouped by area & building class [IMPORT]
SELECT AREA, LEFT(`BUILDING CLASS AT TIME OF SALE`, 1) AS building_class,
       count(sale_price) AS transactions,
       count(sale_price) / (select count(sale_price) from mega_listing where property_rank <=25) * 100 AS per_of_mega_transactions,
       count(sale_price)/(select count(sale_price) from mega_listing) *100 AS per_total_transactions,
       SUM(sale_price) AS sales,
       MAX(sale_price) AS max_sale,
       SUM(sale_price) / (select sum(sale_price) from mega_listing where property_rank <=25) * 100 AS per_mega_sales,
       sum(sale_price)/(select sum(sale_price) from mega_listing) * 100 AS per_total_sales,
       MAX(sale_price)/(select sum(sale_price) from mega_listing where property_rank <=25) * 100 as max_as_per_total_sales
FROM mega_listing
WHERE property_rank <= 25
GROUP BY 1,2
order bY building_class DESC;

#3E) Find the 10 richest neighborhoods in new york city [IMPORT]
SELECT RANK() OVER(ORDER BY avg_sale_price DESC) AS neighborhood_rank,
       NEIGHBORHOOD,
       avg_sale_price,
       nyc_avg_sale_price,
       (avg_sale_price - nyc_avg_sale_price)/ nyc_avg_sale_price AS rate_multiple,
       max_sale_price,
       max_sale_price/total_sales AS max_as_per_of_sales,
       max_sale_price/nyc_total_sales AS max_as_per_of_nyc_sales,
       total_sales,
       total_sales/nyc_total_sales AS per_of_nyc_sales
FROM (
    SELECT DISTINCT NEIGHBORHOOD,
           AVG(`SALE PRICE`) OVER(partition by NEIGHBORHOOD) AS avg_sale_price,
           AVG(`SALE PRICE`) OVER() AS nyc_avg_sale_price,
           MAX(`SALE PRICE`) OVER(partition by NEIGHBORHOOD) AS max_sale_price,
           SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_sales,
           SUM(`SALE PRICE`) OVER() AS nyc_total_sales
    FROM Manhattan_RS) AS wealthy_neighborhoods
LIMIT 10;

#-------------------------------------------------

#4) Analyzing condo sales - highest grossing building class category in total sales*/

#4A) Finding Total sales by building category [IMPORT]
SELECT GeneralBuildingCategory,
       SUM(`SALE PRICE`) AS sale_price #$38,096,467,389 (53% of all sales) | include total sales in importation
FROM Manhattan_RS
Group by 1
ORDER BY sale_price DESC;

#4B) Finding total transactions by building category [IMPORT]
SELECT GeneralBuildingCategory,
       COUNT(`SALE PRICE`) AS transactions #11093 condos | include total transactions in importation
    FROM Manhattan_RS
Group by 1
ORDER BY transactions DESC

#4C) Analyzing condo sales by each neighborhood [IMPORT]
# SELECT *, RANK() OVER(ORDER BY per_of_totalCondoSales DESC) AS per_rank
# FROM (
    SELECT DISTINCT NEIGHBORHOOD,
        COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD) AS condos,
        COUNT(*) OVER() AS totalCondos,
        (select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) AS all_properties,
        (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD))/(COUNT(*) OVER()) *100 AS per_total_condos,
        (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD))/(select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) * 100 AS per_allProperties,
        SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS sales,
        AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_sales_price,
        MAX(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS max_sale_price,
        SUM(`SALE PRICE`) OVER() AS total_condo_sales,
        (select sum(`SALE PRICE`) from Manhattan_RS) AS all_sales,
        (MAX(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD)) * 100 AS max_per_of_totalCondoSales,
        (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / SUM(`SALE PRICE`) OVER()) * 100 AS per_of_totalCondoSales,
        (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / (select sum(`SALE PRICE`) from Manhattan_RS)) *100 AS per_allSales
    FROM Manhattan_RS
    WHERE `BUILDING CLASS CATEGORY` LIKE '%condo%'; #AS condo_stats;
# LIMIT 10;

#4D) Analyzing condo sales by each district [IMPORT]
SELECT DISTINCT AREA,
        COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY AREA) AS condos,
        COUNT(*) OVER() AS totalCondos,
        (select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) AS all_properties,
        (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY AREA))/(COUNT(*) OVER()) *100 AS per_total_condos,
        (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY AREA))/(select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) * 100 AS per_allProperties,
        SUM(`SALE PRICE`) OVER(PARTITION BY AREA) AS sales,
        AVG(`SALE PRICE`) OVER(PARTITION BY AREA) AS avg_sales_price,
        MAX(`SALE PRICE`) OVER(PARTITION BY AREA) AS max_sale_price,
        SUM(`SALE PRICE`) OVER() AS total_condo_sales,
        (select sum(`SALE PRICE`) from Manhattan_RS) AS all_sales,
        (MAX(`SALE PRICE`) OVER(PARTITION BY AREA) / SUM(`SALE PRICE`) OVER(PARTITION BY AREA)) * 100 AS max_per_of_totalCondoSales,
        (SUM(`SALE PRICE`) OVER(PARTITION BY AREA) / SUM(`SALE PRICE`) OVER()) * 100 AS per_of_totalCondoSales,
        (SUM(`SALE PRICE`) OVER(PARTITION BY AREA) / (select sum(`SALE PRICE`) from Manhattan_RS)) *100 AS per_allSales
FROM Manhattan_RS
WHERE `BUILDING CLASS CATEGORY` LIKE '%condo%';

#4E) Analyzing top 3 highest grossing (condo sales) neighborhoods in each area [IMPORT]
SELECT *
FROM (
    SELECT *, RANK() OVER(PARTITION BY AREA ORDER BY per_of_totalCondoSales DESC) AS condo_rank
        FROM (
          SELECT DISTINCT AREA, NEIGHBORHOOD,
            COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD) AS condos,
            COUNT(*) OVER() AS totalCondos,
            (select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) AS all_properties,
            (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD))/(COUNT(*) OVER()) *100 AS per_total_condos,
            (COUNT(`BUILDING CLASS CATEGORY`) OVER(PARTITION BY NEIGHBORHOOD))/(select count(`BUILDING CLASS CATEGORY`) from Manhattan_RS) * 100 AS per_allProperties,
            SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS sales,
            AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_sales_price,
            MAX(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS max_sale_price,
            SUM(`SALE PRICE`) OVER() AS total_condo_sales,
            (select sum(`SALE PRICE`) from Manhattan_RS) AS all_sales,
            (MAX(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / SUM(`SALE PRICE`) OVER(PARTITION BY AREA)) * 100 AS max_per_of_totalCondoSales,
            (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / SUM(`SALE PRICE`) OVER()) * 100 AS per_of_totalCondoSales,
            (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / (select sum(`SALE PRICE`) from Manhattan_RS)) *100 AS per_allSales
          FROM Manhattan_RS
          WHERE `BUILDING CLASS CATEGORY` LIKE '%condo%') AS condo_stats) AS rank_condo_stats
WHERE condo_rank BETWEEN 1 AND 3;

#-------------------------------------------------

#5A)Analyzing frequently sold building categories fdrc (family dwellings, rentals, condos) by neighborhood [IMPORT]
SELECT neighborhood,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
       (select count(`SALE PRICE`)) AS total_transactions,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
       (select sum(`SALE PRICE`)) AS total_sales
FROM Manhattan_RS
GROUP BY 1

#5B) Analyzing fdrc sale per transaction rate against nyc rate grouped by neighborhood. Along with what % of total sales fdrc sales make up [IMPORT]
WITH fdrc AS (
  SELECT neighborhood,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
       (select count(`SALE PRICE`)) AS total_transactions,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
       (select sum(`SALE PRICE`)) AS total_sales
  FROM Manhattan_RS
  GROUP BY 1)

SELECT *
    FROM (
        SELECT neighborhood,
           fdrc_sales,
           AVG(fdrc_sales) OVER() AS avg_fdrc_sales,
           fdrc_sales - AVG(fdrc_sales) OVER() AS avg_diff,
           total_sales,
           SUM(total_sales) OVER() AS nyc_totalSales,
           CONCAT(ROUND((fdrc_sales/total_sales) * 100, 2), '%') AS per_neighborhoodSales,
           (fdrc_sales/SUM(total_sales) OVER()) * 100 AS per_nycSales,
           fdrc_transactions,
           AVG(fdrc_transactions) OVER() AS avg_fdrc_transactions,
           total_transactions,
           SUM(total_transactions) OVER() AS all_nyc_transactions,
           CONCAT(ROUND((fdrc_transactions/total_transactions) * 100, 2), '%') AS per_neighborhoodTransactions,
           (fdrc_transactions/ SUM(total_transactions) OVER()) * 100 AS per_nycTransactions,
           FORMAT(ROUND((fdrc_sales/fdrc_transactions), 2), 2) AS fdrc_sale_per_transaction,
           FORMAT(ROUND((total_sales/total_transactions), 2), 2) AS sale_per_transaction,
           (fdrc_sales/fdrc_transactions) - (total_sales/total_transactions) AS spt_diff,
           FORMAT(ROUND(SUM(total_sales) OVER()/ SUM(total_transactions) OVER()),2) AS nyc_salePerTransaction
        FROM fdrc) AS innerfdrc
WHERE avg_diff > 0 AND spt_diff >0 #filter on neighbordhoods that have recorded higher fdrc sales than the average fdrc rate

#5C) NYC LEVEL | Analyzing fdrc sale per transaction rate against nyc rate. Along with what % of total sales fdrc sales make up [IMPORT]
WITH fdrc1 AS (
    SELECT
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
       (select count(`SALE PRICE`)) AS total_transactions,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
       (select sum(`SALE PRICE`)) AS total_sales
    FROM Manhattan_RS)

SELECT fdrc_sales,
       total_sales,
       fdrc_transactions,
       total_transactions,
       FORMAT(ROUND((fdrc_sales/fdrc_transactions), 2), 2) AS fdrc_spt,
       FORMAT(ROUND((total_sales/total_transactions), 2), 2) AS nyc_spt,
       (fdrc_sales/fdrc_transactions) - (total_sales/total_transactions) AS spt_diff,
       CONCAT(ROUND((fdrc_sales/total_sales) * 100, 2), '%') AS per_nycSales,
       CONCAT(ROUND((fdrc_transactions/total_transactions) * 100, 2), '%') AS per_nycTransactions
FROM fdrc1;

#5D) Same as 5B analyzing data by district [IMPORT]
WITH fdrc2 AS (
 SELECT AREA,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
       (select count(`SALE PRICE`)) AS total_transactions,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
       (select sum(`SALE PRICE`)) AS total_sales
FROM Manhattan_RS
GROUP BY 1)

SELECT AREA,
       fdrc_sales,
       AVG(fdrc_sales) OVER() AS avg_fdrc_sales,
       fdrc_sales - AVG(fdrc_sales) OVER() AS avg_diff,
       total_sales,
       SUM(total_sales) OVER() AS nyc_totalSales,
       CONCAT(ROUND((fdrc_sales/total_sales) * 100, 2), '%') AS per_neighborhoodSales,
       (fdrc_sales/SUM(total_sales) OVER()) * 100 AS per_nycSales,
       fdrc_transactions,
       AVG(fdrc_transactions) OVER() AS avg_fdrc_transactions,
       total_transactions,
       SUM(total_transactions) OVER() AS all_nyc_transactions,
       CONCAT(ROUND((fdrc_transactions/total_transactions) * 100, 2), '%') AS per_neighborhoodTransactions,
       (fdrc_transactions/ SUM(total_transactions) OVER()) * 100 AS per_nycTransactions,
       FORMAT(ROUND((fdrc_sales/fdrc_transactions), 2), 2) AS fdrc_sale_per_transaction,
       FORMAT(ROUND((total_sales/total_transactions), 2), 2) AS sale_per_transaction,
       (fdrc_sales/fdrc_transactions) - (total_sales/total_transactions) AS spt_diff,
       FORMAT(ROUND(SUM(total_sales) OVER()/ SUM(total_transactions) OVER()),2) AS nyc_salePerTransaction
FROM fdrc2;

#5E) Finding top 3 highest grossing (fdrc sales) neighborhoods in each area [IMPORT]
WITH fdrc3 AS (
 SELECT AREA,neighborhood,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
       (select count(`SALE PRICE`)) AS total_transactions,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
       (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
       SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
       (select sum(`SALE PRICE`)) AS total_sales
From Manhattan_RS
GROUP BY 1,2)

SELECT *
    FROM (
    SELECT *, dense_rank() over (PARTITION BY AREA ORDER BY avg_diff DESC) AS sale_rank
        FROM (
            SELECT AREA, NEIGHBORHOOD,
                fdrc_sales,
                AVG(fdrc_sales) OVER() AS avg_fdrc_sales,
                fdrc_sales - AVG(fdrc_sales) OVER() AS avg_diff,
                total_sales,
                SUM(total_sales) OVER() AS nyc_totalSales,
                CONCAT(ROUND((fdrc_sales/total_sales) * 100, 2), '%') AS per_neighborhoodSales,
                (fdrc_sales/SUM(total_sales) OVER()) * 100 AS per_nycSales,
                fdrc_transactions,
                AVG(fdrc_transactions) OVER() AS avg_fdrc_transactions,
                total_transactions,
                SUM(total_transactions) OVER() AS all_nyc_transactions,
                CONCAT(ROUND((fdrc_transactions/total_transactions) * 100, 2), '%') AS per_neighborhoodTransactions,
                (fdrc_transactions/ SUM(total_transactions) OVER()) * 100 AS per_nycTransactions,
                FORMAT(ROUND((fdrc_sales/fdrc_transactions), 2), 2) AS fdrc_sale_per_transaction,
                FORMAT(ROUND((total_sales/total_transactions), 2), 2) AS sale_per_transaction,
                (fdrc_sales/fdrc_transactions) - (total_sales/total_transactions) AS spt_diff,
                FORMAT(ROUND(SUM(total_sales) OVER()/ SUM(total_transactions) OVER()),2) AS nyc_salePerTransaction
            FROM fdrc3) AS innerfdrc3) AS innerinnerfdrc3
WHERE sale_rank <=3;

#-------------------------------------------------

#6) Which district generates the most sales?
#6A) Which building class category in which district generates the most sales [IMPORT]
SELECT AREA, GeneralBuildingCategory,
       SUM(`SALE PRICE`) AS total_sales,
       (select sum(`SALE PRICE`) from Manhattan_RS) AS nyc_sales,
       SUM(((`SALE PRICE`)/(select sum(`SALE PRICE`) from Manhattan_RS)) * 100) AS per_nycSales
FROM Manhattan_RS
group by 1, 2
order by per_nycSales DESC;

#6B) In-depth sales data broken down by district [IMPORT]
SELECT DISTINCT AREA,
       AVG(`SALE PRICE`) OVER(PARTITION BY AREA) AS avg_sale_price,
       AVG(`SALE PRICE`) OVER() AS nyc_avg_sale_price,
       ((AVG(`SALE PRICE`) OVER(PARTITION BY AREA) -  AVG(`SALE PRICE`) OVER())/AVG(`SALE PRICE`) OVER()) * 100 AS avg_multiple,
       COUNT(`SALE PRICE`) OVER(PARTITION BY AREA) AS transactions,
       COUNT(`SALE PRICE`) OVER() AS all_nyc_transactions,
       (COUNT(`SALE PRICE`) OVER(PARTITION BY AREA) / COUNT(`SALE PRICE`) OVER()) * 100 AS per_of_transactions,
       SUM(`SALE PRICE`) OVER(PARTITION BY AREA) AS total_sales,
       SUM(`SALE PRICE`) OVER() AS nyc_total_sales,
    (SUM(`SALE PRICE`) OVER(PARTITION BY AREA)/SUM(`SALE PRICE`) OVER()) * 100 AS per_of_nyc_sales
FROM Manhattan_RS;

#6C) In-depth sales data broken down by general building category [IMPORT]
SELECT DISTINCT GeneralBuildingCategory,
       AVG(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory) AS avg_sale_price,
       AVG(`SALE PRICE`) OVER() AS nyc_avg_sale_price,
       ((AVG(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory) -  AVG(`SALE PRICE`) OVER())/AVG(`SALE PRICE`) OVER()) * 100 AS avg_multiple,
       COUNT(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory) AS transactions,
       COUNT(`SALE PRICE`) OVER() AS all_nyc_transactions,
       (COUNT(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory) / COUNT(`SALE PRICE`) OVER()) * 100 AS per_of_transactions,
       SUM(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory) AS total_sales,
       SUM(`SALE PRICE`) OVER() AS nyc_total_sales,
       (SUM(`SALE PRICE`) OVER(PARTITION BY GeneralBuildingCategory)/SUM(`SALE PRICE`) OVER()) * 100 AS per_of_nyc_sales
FROM Manhattan_RS;

#6D) In-depth sales data broken down by area and neighborhood, building_class [IMPORT]
SELECT DISTINCT AREA, NEIGHBORHOOD, GeneralBuildingCategory,
       AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) AS avg_sale_price,
       AVG(`SALE PRICE`) OVER() AS nyc_avg_sale_price,
       ((AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) -  AVG(`SALE PRICE`) OVER())/AVG(`SALE PRICE`) OVER()) * 100 AS avg_multiple,
       COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) AS transactions,
       COUNT(`SALE PRICE`) OVER() AS all_nyc_transactions,
       (COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) / COUNT(`SALE PRICE`) OVER()) * 100 AS per_of_transactions,
       SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) AS total_sales,
       SUM(`SALE PRICE`) over(PARTITION BY NEIGHBORHOOD) AS neighborhood_sales,
       SUM(`SALE PRICE`) OVER(partition by AREA) as area_sales,
       (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory) / SUM(`SALE PRICE`) OVER(partition by AREA)) * 100 AS per_areaSales,
       SUM(`SALE PRICE`) OVER() AS nyc_total_sales,
       (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD, GeneralBuildingCategory)/SUM(`SALE PRICE`) OVER()) * 100 AS per_of_nyc_sales
FROM Manhattan_RS
ORDER BY area, NEIGHBORHOOD,per_of_nyc_sales DESC;

#6E) Broken down by neighborhood
SELECT DISTINCT AREA, NEIGHBORHOOD,
       AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_sale_price,
       AVG(`SALE PRICE`) OVER() AS nyc_avg_sale_price,
       ((AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) -  AVG(`SALE PRICE`) OVER())/AVG(`SALE PRICE`) OVER()) * 100 AS avg_multiple,
       COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS transactions,
       COUNT(`SALE PRICE`) OVER() AS all_nyc_transactions,
       (COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / COUNT(`SALE PRICE`) OVER()) * 100 AS per_of_transactions,
       SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_sales,
       SUM(`SALE PRICE`) OVER(partition by AREA) as area_sales,
       (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) / SUM(`SALE PRICE`) OVER(partition by AREA)) * 100 AS per_areaSales,
       SUM(`SALE PRICE`) OVER() AS nyc_total_sales,
       (SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD)/SUM(`SALE PRICE`) OVER()) * 100 AS per_of_nyc_sales
FROM Manhattan_RS
ORDER BY area, per_of_nyc_sales DESC;

SELECT NEIGHBORHOOD, SUM(`SALE PRICE`)
FROM Manhattan_RS
GROUP BY 1

#NS_View
SELECT `SALE DATE`, Area, NEIGHBORHOOD,
       Full_Address, `ZIP CODE`,
       GeneralBuildingCategory AS building_type,
       `BUILDING CLASS CATEGORY` AS building_category,
       LEFT(`BUILDING CLASS AT TIME OF SALE`, 1) AS building_class,
       `SALE PRICE` AS salePrice,
       `GROSS SQUARE FEET` AS sqFeet
FROM Manhattan_RS
ORDER BY 1, 2, 3;

#-----------------------------------------------------------------------------------------------------

#7) Analyzing relationship between sale price and number of rental units in rental building classes

#7A) Overview of each rental property's units and sale price [IMPORT LAST]
SELECT NEIGHBORHOOD, Full_Address,GeneralBuildingCategory, `TOTAL UNITS`, `SALE PRICE`
    FROM Manhattan_RS
    WHERE GeneralBuildingCategory LIKE '%rental%';

#7B) Calculating avg sale price per unit broken down by each neighborhood [IMPORT]
SELECT NEIGHBORHOOD,
       AVG(`TOTAL UNITS`) AS avg_units, avg(`SALE PRICE`) AS avg_sale_price,
       avg(`SALE PRICE`/`TOTAL UNITS`) AS avg_spu
       #(select(avg(`SALE PRICE`/`TOTAL UNITS`)) from Manhattan_RS) AS nyc_avg_p_per_unit
from Manhattan_RS
    WHERE GeneralBuildingCategory LIKE '%rental%'
group by 1
ORDER BY avg_spu DESC;

#7C) Calculating avg sale price per unit broken down by each area [IMPORT -- Revisit]
SELECT AREA, AVG(`TOTAL UNITS`) AS avg_units,
       avg(`SALE PRICE`) AS avg_sale_price,
       avg(`SALE PRICE`/`TOTAL UNITS`) AS avg_spu
from Manhattan_RS
    WHERE GeneralBuildingCategory LIKE '%rental%'
group by 1
ORDER BY avg_spu DESC;

#-----------------------------------------------------------------------------------------------------

#8) Analyzing the quality of buildings sold through age and analyzing relationship between age and sale_price

#8A) overview #dual axis combo
SELECT DISTINCT Area,
       EXTRACT(month FROM `SALE DATE`) AS month,
       SUM(`SALE PRICE`) OVER(PARTITION BY AREA, EXTRACT(month FROM `SALE DATE`)) AS total_sales,
       AVG(`SALE PRICE`) OVER(PARTITION BY AREA, EXTRACT(month FROM `SALE DATE`)) AS avg_sales,
       AVG(`YEAR BUILT`) OVER(PARTITION BY AREA, EXTRACT(month FROM `SALE DATE`)) AS avg_year_built,
       AVG(2022 - `YEAR BUILT`) OVER(PARTITION BY AREA, EXTRACT(month FROM `SALE DATE`)) AS avg_age,
       AVG(`SALE PRICE`) OVER() AS nyc_average_sales,
       avg(2022-`YEAR BUILT`) OVER() AS nyc_averageAge
FROM Manhattan_RS
WHERE YEAR(`SALE DATE`) !=1900
ORDER BY Area, month ASC;

#8B) Calculating avg age and avg sale price of properties for each month [IMPORT]
SELECT EXTRACT(month from `SALE DATE`) AS month,
       ROUND(AVG(`YEAR BUILT`),0) AS year_built,
       AVG((2022 - `YEAR BUILT`)) AS avg_age,
       AVG(`SALE PRICE`) AS avg_sale_price
FROM Manhattan_RS
GROUP BY 1
ORDER BY 4 DESC;

#create a view to store decade info
CREATE VIEW age_quality AS
SELECT *,
       CASE WHEN `YEAR BUILT` BETWEEN 1800 AND 1809 THEN "1800"
            WHEN `YEAR BUILT` BETWEEN 1810 AND 1819 THEN "1810"
            WHEN `YEAR BUILT` BETWEEN 1820 AND 1829 THEN "1820"
            WHEN `YEAR BUILT` BETWEEN 1830 AND 1839 THEN "1830"
            WHEN `YEAR BUILT` BETWEEN 1840 AND 1849 THEN "1840"
            WHEN `YEAR BUILT` BETWEEN 1850 AND 1859 THEN "1850"
            WHEN `YEAR BUILT` BETWEEN 1860 AND 1869 THEN "1860"
            WHEN `YEAR BUILT` BETWEEN 1870 AND 1879 THEN "1870"
            WHEN `YEAR BUILT` BETWEEN 1880 AND 1889 THEN "1880"
            WHEN `YEAR BUILT` BETWEEN 1890 AND 1899 THEN "1890"
            WHEN `YEAR BUILT` BETWEEN 1900 AND 1909 THEN "1900"
            WHEN `YEAR BUILT` BETWEEN 1910 AND 1919 THEN "1910"
            WHEN `YEAR BUILT` BETWEEN 1920 AND 1929 THEN "1920"
            WHEN `YEAR BUILT` BETWEEN 1930 AND 1939 THEN "1930"
            WHEN `YEAR BUILT` BETWEEN 1940 AND 1949 THEN "1940"
            WHEN `YEAR BUILT` BETWEEN 1950 AND 1959 THEN "1950"
            WHEN `YEAR BUILT` BETWEEN 1960 AND 1969 THEN "1960"
            WHEN `YEAR BUILT` BETWEEN 1970 AND 1979 THEN "1970"
            WHEN `YEAR BUILT` BETWEEN 1980 AND 1989 THEN "1980"
            WHEN `YEAR BUILT` BETWEEN 1990 AND 1999 THEN "1990"
            WHEN `YEAR BUILT` BETWEEN 2000 AND 2009 THEN "2000"
            WHEN `YEAR BUILT` BETWEEN 2010 AND 2019 THEN "2010"
            WHEN `YEAR BUILT` > 2019 THEN "2020"
            ELSE NULL END AS decade
from Manhattan_RS;

#8C) Analyzing sales, spt ratio, and sp_per_sqf on a decade level basis [IMPORT]
SELECT decade,
       AVG(`SALE PRICE`) AS avg_sale_price,
       SUM(`SALE PRICE`) AS total_sales,
       COUNT(`SALE PRICE`) AS transactions,
       SUM(`SALE PRICE`)/COUNT(`SALE PRICE`) AS sp_per_transaction,
       AVG(`GROSS SQUARE FEET`) AS avg_sqft,
       AVG(`SALE PRICE`/`GROSS SQUARE FEET`) AS sp_per_sqf
FROM age_quality
WHERE `GROSS SQUARE FEET` IS NOT NULL
GROUP BY 1
ORDER BY avg_sale_price DESC;

#8D) Analyzing which neighborhoods sold the newest properties [IMPORT]
SELECT NEIGHBORHOOD, AVG(2022 - `YEAR BUILT`) AS avg_age, #ROUND(AVG(decade),0) AS avg_decade,
       ROUND(avg(`YEAR BUILT`),0) AS avg_year_built,
       COUNT(`SALE PRICE`) AS transactions
FROM age_quality
GROUP BY 1
ORDER BY avg_year_built DESC;

#8E) Finding neighborhoods that sold the newest buildings
WITH age_anlaysis AS (
    SELECT DISTINCT Area, neighborhood, avg(2022-`YEAR BUILT`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_age,
            avg(2022-`YEAR BUILT`) OVER() AS nyc_averageAge,
            COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_transactions,
            SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_sales,
            AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_sales,
            avg(2022-`YEAR BUILT`) OVER(PARTITION BY NEIGHBORHOOD) -  avg(2022-`YEAR BUILT`) OVER() AS diff
FROM age_quality)

SELECT distinct ay.area, ay.NEIGHBORHOOD,ay.avg_age, ay.nyc_averageAge, ay.diff,
                COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS newer_built_properties,
                ay.total_transactions,
                SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS totalSales_obp,
                SUM(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) / COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS totSPT,
                AVG(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) AS AvgSales_nbp,
                AVG(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) / COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avgSPT
FROM age_quality aq
LEFT JOIN age_anlaysis ay
    ON aq.NEIGHBORHOOD = ay.NEIGHBORHOOD
WHERE (2022 - `YEAR BUILT`) < ay.avg_age AND ay.diff < 0 #(only showcases neighborhoods with lower age rate than nyc_rate, but you might leave out neighbords with the most newest/oldest buildings)
ORDER BY ay.avg_age ASC;

#8F) Finding neighborhoods that sold the oldest buildings
WITH age_anlaysis AS (
SELECT DISTINCT Area, neighborhood, avg(2022-`YEAR BUILT`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_age,
                avg(2022-`YEAR BUILT`) OVER() AS nyc_averageAge,
                COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_transactions,
                SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS total_sales,
                AVG(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avg_sales,
                avg(2022-`YEAR BUILT`) OVER(PARTITION BY NEIGHBORHOOD) -  avg(2022-`YEAR BUILT`) OVER() AS diff
FROM age_quality)

SELECT distinct ay.area, ay.NEIGHBORHOOD,ay.avg_age,ay.nyc_averageAge, ay.diff,
                COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS older_built_properties,
                ay.total_transactions,
                SUM(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS totalSales_obp,
                SUM(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) / COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS totSPT,
                AVG(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) AS AvgSales_obp,
                AVG(`SALE PRICE`) OVER(PARTITION BY aq.NEIGHBORHOOD) / COUNT(`SALE PRICE`) OVER(PARTITION BY NEIGHBORHOOD) AS avgSPT
FROM age_quality aq
LEFT JOIN age_anlaysis ay
    ON aq.NEIGHBORHOOD = ay.NEIGHBORHOOD
WHERE (2022 - `YEAR BUILT`) > ay.avg_age  AND ay.diff > 0 #(only showcases neighborhoods with lower age rate than nyc_rate, but you might leave out neighbords with the most newest/oldest buildings)
ORDER BY ay.avg_age DESC;

#8G) Analyzing age data of properties on a district level
SELECT DISTINCT AREA, avg(2022-`YEAR BUILT`) OVER(PARTITION BY AREA) AS avg_age,
                AVG(`SALE PRICE`) OVER(PARTITION BY AREA) AS avg_sale_price,
                avg(2022-`YEAR BUILT`) OVER() AS nyc_averageAge,
                avg(2022-`YEAR BUILT`) OVER(PARTITION BY AREA) -  avg(2022-`YEAR BUILT`) OVER() AS diff,
                COUNT(`SALE PRICE`) OVER(PARTITION BY AREA) AS total_transactions
FROM age_quality
ORDER BY avg_age ASC;




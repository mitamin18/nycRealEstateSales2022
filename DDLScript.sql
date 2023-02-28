#Data Definition Language

#1) Initial Data Cleaning
ALTER TABLE Manhattan_RS
ADD BCK_LOT varchar(50);

UPDATE Manhattan_RS SET Manhattan_RS.BCK_LOT
    = CONCAT(DA_Project.Manhattan_RS.BCK, '-', DA_Project.Manhattan_RS.LOT);

ALTER TABLE Manhattan_RS
ADD Full_Address varchar(100);

UPDATE Manhattan_RS SET Manhattan_RS.Full_Address
    = CONCAT(DA_Project.Manhattan_RS.ADDRESS, ' NEW YORK,', ' NY ', DA_Project.Manhattan_RS.`ZIP CODE`);

#2) Appending new columns
ALTER TABLE Manhattan_RS
ADD DISTRICT varchar(50);

UPDATE Manhattan_RS SET Manhattan_RS.DISTRICT =
       (CASE WHEN NEIGHBORHOOD IN ('ALPHABET CITY', 'CHINATOWN', 'CIVIC CENTER', 'EAST VILLAGE', 'FINANCIAL',
                                  'GREENWICH VILLAGE-CENTRAL', 'GREENWICH VILLAGE-WEST', 'LITTLE ITALY',
                                  'LOWER EAST SIDE', 'SOHO', 'SOUTHBRIDGE', 'TRIBECA') THEN "Downtown"
            WHEN NEIGHBORHOOD IN ('CHELSEA', 'CLINTON', 'FASHION', 'FLATIRON', 'GRAMERCY', 'JAVITS CENTER',
                                  'KIPS BAY', 'MIDTOWN CBD', 'MIDTOWN EAST', 'MIDTOWN WEST', 'MURRAY HILL') THEN "Midtown"
            WHEN NEIGHBORHOOD LIKE '%ROOSEVELT ISLAND%' THEN "Other"
            ELSE "Uptown" END);

ALTER TABLE Manhattan_RS
ADD GeneralBuildingCategory varchar(50);

UPDATE Manhattan_RS SET Manhattan_RS.GeneralBuildingCategory =
    (CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family dwelling%' THEN "Family Dwelling"
                WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN "Condominium"
             WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN "Rental"
             WHEN `BUILDING CLASS CATEGORY`IN ('09 COOPS - WALKUP APARTMENTS', '10 COOPS - ELEVATOR APARTMENTS') THEN "COOP"
             WHEN `BUILDING CLASS CATEGORY` IN ('25 LUXURY HOTELS', '26 OTHER HOTELS') THEN "Hotel"
             WHEN `BUILDING CLASS CATEGORY` LIKE '%21%' THEN "Office"
             ELSE "Other" END);

#3) Creating a temp_table --
DROP TABLE if exists fdrc_data; #if you want to edit data type or append anything, must drop table and re-create

 CREATE TABLE fdrc_data (
  neighborhood varchar(50),
  family_dwellings int,
  rentals int,
  condos int,
  fdrc_transactions int,
  all_transactions int,
  fd_sales int,
  rental_sales int,
  condo_sales int,
  fdrc_sales int,
  all_sales int(255)
);

INSERT INTO fdrc_data
SELECT neighborhood,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END) AS family_dwellings,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END) AS rentals,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END) AS condos,
         (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN 1 ELSE 0 END)) + (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN 1 ELSE 0 END)) +
          (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN 1 ELSE 0 END)) AS fdrc_transactions,
          (select count(`SALE PRICE`)) AS all_transactions,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) AS fd_sales,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) AS rental_sales,
         SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END) AS condo_sales,
        (SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%family%dwelling%' THEN `SALE PRICE` ELSE 0 END) + SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%rental%' THEN `SALE PRICE` ELSE 0 END) +
        SUM(CASE WHEN `BUILDING CLASS CATEGORY` LIKE '%condo%' THEN `SALE PRICE` ELSE 0 END)) AS fdrc_sales,
        (select sum(`SALE PRICE`)) AS all_sales
      from Manhattan_RS
    GROUP BY 1;

#4) Renaming column in table
ALTER TABLE Manhattan_RS
RENAME COLUMN DISTRICT TO AREA;



/*****************************************************************************
  Written by Amber Garner
  Last Updated: 20 Jun '16
  
  This script shall 
    a) Create a new data base called Product_Order_Data_Mart
    b) Create a new table called business_unit if it does not already exist
    c) Load data into the business_unit table
    d) Create a new table called product_BU if it does not already exist
    e) Load data into the product_BU table
    f) Create three staging tables if they do not already exist
    g) Load three seperate files into their respective staging tables
    
      Input Files:  
              2012_product_data_students.csv
			  2013_product_data_students.csv
              2014_product_data_students.csv
    
   Each file should reside in the C:\Temp folder prior to running the script.  
  
   The script uses the "Product_Order_Data_Mart" database created here.

/****************************************************************************/  


# create the data if there is not one already on this MySQL instance
CREATE DATABASE IF NOT EXISTS Product_Order_Data_Mart;

# we will use the database we just created
USE Product_Order_Data_Mart;

# Delete business_unit table if it already exists
DROP TABLE if exists business_unit ; 

# Delete product_BU table if it already exists
DROP TABLE if exists product_BU ; 

-- A business unit is division of the company
# Creates business_unit table 
CREATE TABLE Business_Unit (
BU_ID          INTEGER PRIMARY KEY AUTO_INCREMENT,
BU_Name        VARCHAR(25),
BU_Designation VARCHAR(25)
);

-- Each product is assigned to one business unit for a given year
# Creates Product_BU table
CREATE TABLE Product_BU (
Prod_BU_ID   INTEGER PRIMARY KEY AUTO_INCREMENT,
BU_Name      VARCHAR(25),
Product_Name VARCHAR(25),
Prod_BU_Year INT(4)
);


-- Adding records to the Business Unit table
INSERT INTO Business_Unit (BU_Name, BU_Designation)
VALUES
('Snack',     'Growth'),
('On the go', 'Growth'),
('Energy',    'Growth'),
('Health',    'Mature'),
('Lunchtime', 'Mature'),
('Sugar',     'Decline'),
('GMO',       'Decline')
;


-- Adding records to the Product/Business Unit table
INSERT INTO Product_BU (BU_Name, Product_Name, Prod_BU_Year)
VALUES
('On the go', 'Blue Rock Candy', '2012'),
('On the go', 'Blue Rock Candy', '2013'),
('On the go', 'Blue Rock Candy', '2014'),
('Snack', 'Crocodile Tears', '2012'),
('Snack', 'Crocodile Tears', '2013'),
('Snack', 'Crocodile Tears', '2014'),
('Sugar', 'Giant Gummies', '2012'),
('Sugar', 'Giant Gummies', '2013'),
('Sugar', 'Giant Gummies', '2014'),
('Sugar', 'Green Lightning', '2012'),
('Lunchtime', 'Green Lightning', '2013'),
('Lunchtime', 'Green Lightning', '2014'),
('GMO', 'Grey Gummies', '2012'),
('GMO', 'Grey Gummies', '2013'),
('GMO', 'Grey Gummies', '2014'),
('Sugar', 'Nap Be Gone', '2012'),
('Sugar', 'Nap Be Gone', '2013'),
('Sugar', 'Nap Be Gone', '2014'),
('GMO', 'Orange Creepies', '2012'),
('GMO', 'Orange Creepies', '2013'),
('Lunchtime', 'Orange Creepies', '2014'),
('Health', 'Panda Gummies', '2012'),
('Health', 'Panda Gummies', '2013'),
('Health', 'Panda Gummies', '2014'),
('On the go', 'Pink Bubble Gum', '2012'),
('On the go', 'Pink Bubble Gum', '2013'),
('On the go', 'Pink Bubble Gum', '2014'),
('Energy', 'Purple Pain', '2012'),
('Energy', 'Purple Pain', '2013'),
('Energy', 'Purple Pain', '2014'),
('Energy', 'Red Hot Chili Peppers', '2012'),
('Energy', 'Red Hot Chili Peppers', '2013'),
('Energy', 'Red Hot Chili Peppers', '2014'),
('Lunchtime', 'Yellow Zonkers', '2012'),
('Lunchtime', 'Yellow Zonkers', '2013'),
('Lunchtime', 'Yellow Zonkers', '2014')
;

/*****************************************************************************/
#This is the 2012 data import section

# Delete `stg_2012` table if it already exists
DROP TABLE if exists `stg_2012` ; 

# create the 2012 Staging table to import data from the csv file.
CREATE TABLE IF NOT EXISTS `stg_2012` (
  `Month`             int(11) DEFAULT NULL,
  `Country`           text,
  `Region`            text,
  `State`             text,
  `Product`           text,
  `Per-Unit Price`    int(11) DEFAULT NULL,
  `Quantity`          int(11) DEFAULT NULL,
  `Order Total`       int(11) DEFAULT NULL
) DEFAULT CHARSET=utf8;



#Load the 2012 data from the csv file into the table from the secure upload folder
#
LOAD DATA INFILE 'C:\\Temp\\2012_product_data_students.csv' 
INTO TABLE stg_2012 
FIELDS TERMINATED BY ',' 		# columns separated by commas
LINES TERMINATED BY '\r\n'		# line termination
IGNORE 1 LINES;			        # ignore the first line with our headers 


/*****************************************************************************/
#This is the 2013 data import section

# Delete `stg_2013` table if it already exists
DROP TABLE if exists `stg_2013` ; 

# create the 2013 Staging table to import data from the csv file.
CREATE TABLE IF NOT EXISTS `stg_2013` (
  `Month`          int(11) DEFAULT NULL,
  `Region`         text,
  `Customer_ID`    int(11) DEFAULT NULL,
  `Product`        text,
  `Per-Unit Price` int(11) DEFAULT NULL,
  `Quantity_1`     int(11) DEFAULT NULL,
  `Quantity_2`     int(11) DEFAULT NULL
) DEFAULT CHARSET=utf8;

#Load the 2013 data from the csv file into the table from the secure upload folder
#
LOAD DATA INFILE 'C:\\Temp\\2013_product_data_students.csv' 
INTO TABLE stg_2013 
FIELDS TERMINATED BY ',' 		# columns separated by commas
LINES TERMINATED BY '\r\n'		# line termination
IGNORE 1 LINES;			        # ignore the first line with our headers 


/*****************************************************************************/
#This is the 2014 data import section

# Delete `stg_2014` table if it already exists
DROP TABLE if exists `stg_2014` ; 

# create the 2014 Staging table to import data from the csv file.
CREATE TABLE IF NOT EXISTS `stg_2014` (
  `Month`               int(11) DEFAULT NULL,
  `Country`             text,
  `Region`              text,
  `State`               text,
  `Product`             text,
  `Per-Unit Price`      int(11) DEFAULT NULL,
  `Quantity`            int(11) DEFAULT NULL,
  `Order Subtotal`      int(11) DEFAULT NULL,
  `Quantity Discount`   int(11) DEFAULT NULL
) DEFAULT CHARSET=utf8;



#Load the 2014 data from the csv file into the table from the secure upload folder
#
LOAD DATA INFILE 'C:\\Temp\\2014_product_data_students.csv' 
INTO TABLE stg_2014 
FIELDS TERMINATED BY ',' 		# columns separated by commas
LINES TERMINATED BY '\r\n'		# line termination
IGNORE 1 LINES;			        # ignore the first line with our headers here



#END OF SCRIPT
/*****************************************************************************/
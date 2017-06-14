/*****************************************************************************
  Written by Amber Garner
  Last Updated: 20 Jun '16
  
  This script shall 
    a) Create the fact table if it does not exists
    b) Drop all records from the fact table 
    c) Insert the staged data into the fact table
    d) Export the fact table to a comma delimited file with headers.
  
  Produces the final output file: "G4_output_final.csv".
  
  Prerequsite:
    The script uses the "Product_Order_Data_Mart" database created 
    as part of an earlier task.alter
    
  The script uses the "Product_Order_Data_Mart" database.

/****************************************************************************/  

#use the Product_Order_Data_Mart database
USE Product_Order_Data_Mart;

/***************************************************************************
 Ceate the fact table
****************************************************************************/
CREATE TABLE IF NOT EXISTS fact_Orders (
	BU_Designation       VARCHAR(25),
	BU_name              VARCHAR(25),
	Product              VARCHAR(25),
	Region               VARCHAR(25),
	`Year`               int(11),
	`Month`              int(11),
	`Sum of Quantity`    int(11),
	`Sum of Order Total` int(11)
);

/***************************************************************************
 Clear out the fact table before loading
****************************************************************************/
TRUNCATE TABLE fact_Orders ; 


/***************************************************************************
   Final transform and load the data in to fact table
  - Filters out any orders that have a total = 0
  - Filters out any orders that are "Decline"
****************************************************************************/
INSERT INTO fact_Orders
  SELECT * FROM v4_final_transform 
  WHERE `Sum of Order Total` != 0 
    AND BU_Designation != 'Decline';


/***************************************************************************
  output the data from the fact table into a flat file 
    called "G4_output_final.csv"
  -Hard coded column headers in the query output.
****************************************************************************/
SELECT 'BU_Designation', 'BU_name', 'Product','Region','Year','Month','Sum of Quantity','Sum of Order Total'
UNION ALL
SELECT BU_Designation, BU_name, Product,Region,Year,Month,`Sum of Quantity`,`Sum of Order Total`
    FROM fact_Orders
    ORDER BY BU_Designation, BU_Name, Product, Region, Year, Month, 'Sum of Quantity', 'Sum of Order Total'
    INTO OUTFILE 'C:\\Temp\\G4_output_final.csv'
    FIELDS TERMINATED BY ',' 		# columns separated by commas
    LINES TERMINATED BY '\r\n'		# line termination;
    
    
    


#END OF SCRIPT
/*****************************************************************************/    
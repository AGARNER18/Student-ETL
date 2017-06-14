/*****************************************************************************
  Written by Amber Garner 
  Last Updated: 20 Jun '16
  
  This script shall 
    a) Create views for logic transforms for each staged data set
    b) the views are named according to thier intended step, for example, all 
       v1_##### scripts should run completly before v2_##### scripts.
  
  The views are layered and segregated to facilitate ease of change, support 
  and maintenance.  Each 'view' is for a single purpose, but may have 
  multiple business logics embeded.
  
    View     Definiton
 ---------   -----------------------------------------------------------------
 v1_2012     This view is to transform only the 2012 staged data to a common 
             format used by the next sequence of view (v2_all_raw)  
            
 v1_2013     This view is to transform only the 2013 staged data to a common 
             format used by the next sequence of view (v2_all_raw)  
             -Quantity and Order Total are calculated
  
 v1_2014     This view is to transform only the 2014 staged data to a common 
             format used by the next sequence of view (v2_all_raw)  
			 -Order Total is calculated
             
 v2_all_raw  This view that combines (UNION ALL) the data from each year.
  
 v3_all_agg  This view sums up all the raw data and joins to the product_bu 
			 table
  
 v4_final_transform
             This view joins the business_unit table 
  
  Prerequsite:
    The script uses the "Product_Order_Data_Mart" database created 
    as part of an earlier task, "G4_1 - Extract data from CSV files.sql".
    
    
  The script uses the "Product_Order_Data_Mart" database.

/****************************************************************************/  

#use the Product Order Data mart
USE Product_Order_Data_Mart;

#to re-create the view, delete it first, then create it
DROP VIEW IF EXISTS `product_order_data_mart`.`v1_2012`;

/***************************************************************************
  This view organizes the 2012 staging data.  
  -It drops the state column.
  -The view hard codes the year as 2012
****************************************************************************/
CREATE VIEW `v1_2012` AS
    SELECT 
		2012 AS `Year`,
		`Month` ,
		`Country`,
		`Region` ,
		`Product`,
		`Per-Unit Price`,
		`Quantity`      ,
		`Order Total` 
    FROM
        stg_2012;


/***************************************************************************
  This view organizes the 2013 staging data.  
    - 2013 data source does not include a state column.
    - Quantity_1 and Quantity_2 are added to create Quantity
    - Order total is calculated from Quantity * Per-Unit Price
    - The country is assumed to be USA
****************************************************************************/
DROP VIEW IF EXISTS `product_order_data_mart`.`v1_2013`;

CREATE VIEW `v1_2013` AS
    SELECT 
		2013     AS 	`Year`,
		`Month`,
		'USA'    AS `Country`,
		`Region` ,
		`Product`,
		`Per-Unit Price`,
		`Quantity_1` + `Quantity_2` as `Quantity` ,                        #add the two quantities for a total quantity of this order
		(`Quantity_1` + `Quantity_2`) * `Per-Unit Price` as `Order Total`  #Calculate the Order total
    FROM
        stg_2013;
    
    
    
/***************************************************************************
  This view organizes the 2014 staging data.  
  - It drops the state column.
  - Order total is calculated as Quantity * Per-Unit Price - Discount
****************************************************************************/
DROP VIEW IF EXISTS `product_order_data_mart`.`v1_2014`;

CREATE VIEW `v1_2014` AS    
    SELECT 
		2014     AS 	`Year`,
		`Month` ,
		`Country`,
		`Region` ,
		`Product`,
		`Per-Unit Price`,
		`Quantity`,
		(`Quantity` * `Per-Unit Price`) -  `Quantity Discount` AS `Order Total`   #Order total is calculated (Qty * $) minus discount
    FROM
        stg_2014;
    
    
/***************************************************************************
  This view unions the three years worth of data.
****************************************************************************/
DROP VIEW IF EXISTS `product_order_data_mart`.`v2_all_raw`;

CREATE VIEW `v2_all_raw` AS  
	SELECT * FROM v1_2012
	  union all
	SELECT * FROM v1_2013
	  union all 
	SELECT * FROM v1_2014;
    

/***************************************************************************
  This view aggregates the three years worth of data and joins to the 
  product_bu table to pick up BU_Name
****************************************************************************/
DROP VIEW IF EXISTS `product_order_data_mart`.`v3_all_agg`;

CREATE VIEW `v3_all_agg` AS
	SELECT 
		   `Product_name`,
		   `BU_Name`,
		   `Year`, 
		   `Month`,
           `Region`,
		   SUM(`Quantity`) AS `Sum of Quantity`, 
		   SUM(`Order Total`) AS `Sum of Order Total`
	  FROM v2_all_raw
	  LEFT JOIN product_bu ON v2_all_raw.Product = product_bu.product_name AND v2_all_raw.`Year` = product_bu.Prod_BU_Year
	  GROUP BY  `Product_name`, `BU_Name`,  `Year`,  `Month`,  `Region`  ;    


/***************************************************************************
  This is the final transform.
  - it Joins to the business_unit table to pick up the BU_Designation
****************************************************************************/
DROP VIEW IF EXISTS `product_order_data_mart`.`v4_final_transform`;

CREATE VIEW `v4_final_transform` AS
	SELECT business_unit.BU_Designation, 
		   business_unit.BU_name,
		   v3_all_agg.Product_name as `Product`,
		   v3_all_agg.Region,
		   v3_all_agg.`Year`,
		   v3_all_agg.`Month`,
		   v3_all_agg.`Sum of Quantity`,
		   v3_all_agg.`Sum of Order Total`
		   FROM v3_all_agg 
	   LEFT JOIN business_unit on v3_all_agg.BU_Name = business_unit.BU_Name;



#END OF SCRIPT
/*****************************************************************************/   




    
    
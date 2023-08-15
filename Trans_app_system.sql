/*THIS CODE WAS WRITTENN BY EDSON KAMBEU*/
/*TASK 1 ASSIGNMENT FOR SECURE DATABASES*/

/*Creating tables */
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS store CASCADE;
DROP TABLE IF EXISTS warehouse_item CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS transcation CASCADE;

CREATE TABLE customer(
customer_id VARCHAR(3),
customer_fname VARCHAR(20) NOT NULL,
customer_sname VARCHAR(20) NOT NULL,
dateofbirth DATE  NOT NULL CHECK (dateofbirth > '1900/01/01'
								 AND dateofbirth < CURRENT_DATE) ,
address VARCHAR(50),
telephone_number VARCHAR(12),
PRIMARY KEY (customer_id)
);

CREATE TABLE store (
	store_id VARCHAR(3),
	store_name VARCHAR(20),
	store_location VARCHAR(20),
	store_address VARCHAR(50),
	store_telephone VARCHAR(12),
	PRIMARY KEY (store_id)
	);

CREATE TABLE warehouse_item(
	warehouse_item_id VARCHAR(3),
	store_id VARCHAR(3) ,
	current_quantity INTEGER NOT NULL CHECK (current_quantity >= 0),
	PRIMARY KEY (warehouse_item_id),
	FOREIGN KEY (store_id) REFERENCES store(store_id)
);


CREATE TABLE product (
	product_id VARCHAR(3),
	warehouse_item_id VARCHAR(3) NOT NULL,
	product_type VARCHAR(50) NOT NULL,
	product_name VARCHAR(50) NOT NULL,
	product_description VARCHAR(255),
	product_cost DECIMAL NOT NULL CHECK (product_cost > 0),
	PRIMARY KEY(product_id),
	FOREIGN KEY(warehouse_item_id) REFERENCES warehouse_item(warehouse_item_id)	
 );
	
CREATE TABLE transcation (
	transcation_id SERIAL,
	customer_id VARCHAR(3),
	product_id VARCHAR(3),
	quantity INTEGER NOT NULL CHECK (quantity > 0),
	delivery_date DATE NOT NULL, /*constraint on delivery date in stored procedure*/
	delivery_time TIME NOT NULL,
	bank_name VARCHAR (50) NOT NULL,
	sort_code VARCHAR (6) NOT NULL,
	bank_account_no VARCHAR(20),
	transcation_date DATE DEFAULT CURRENT_DATE,
	transcation_time TIME DEFAULT CURRENT_TIME,
	PRIMARY KEY (transcation_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
	FOREIGN KEY (product_id) REFERENCES product(product_id)
);

/*Checking if tables have been created*/
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'public';

/*Inserting data into store table */
INSERT INTO store(store_id,
				  store_name,
				  store_location, 
				  store_address,
				  store_telephone)
VALUES
      ('FR1', 'MME Francistown','Francistown', 'Plot 321 Marang', '2413260'),
	  ('GA1', 'MME Gaborone', 'Gaborone', 'Plot 272 Broadhurst', '3216221'),
	  ('PA1', 'MME Palaype', 'Gaborone', 'Plot 354 Block 8', '4370921');*/
	  
/* Checking if data has been entered into store */
SELECT *
FROM store;

/*Inserting data warehouse_item table */

INSERT INTO warehouse_item (warehouse_item_id, store_id, current_quantity)
VALUES
    ('MGA', 'FR1',20),
	('MGB', 'FR1',3),
	('MPD', 'PA1', 17),
	('MKP', 'PA1', 30),
	('MMS', 'FR1', 5),
	('MGE', 'GA1', 10),
	('ADR', 'GA1', 102),
	('ACR', 'GA1', 55),
	('MPH', 'GA1', 60),
	('MDA', 'PA1', 90),
	('MDE','PA1', 15),
	('MDH', 'GA1', 9),
	('MKS','FR1', 17),
	('ABP', 'PA1', 52),
	('ABK','GA1', 0),
	('ABG', 'FR1',0),
	('ABD','GA1', 5);
	
/*Checking if data has been entered in the warehouse table*/
SELECT *
FROM warehouse_item;

/* Insert data into product table*/ 	
INSERT INTO product (product_id, 
					 warehouse_item_id, 
					 product_type,
					 product_name,
					 product_description,
					 product_cost)
VALUES
    ('GA', 'MGA','Musical','Accoustic Guitar', 'A guitar without electronic amplification', 5000),
	('GB', 'MGB','Musical', 'Bass Guitar','An electric guitar with six strings', 5200),
	('GE', 'MGE', 'Musical', 'Electronic Guitar','A guitar with electronic amplification', 5600),
	('DA', 'MDA', 'Musical', 'Accoustic Drum','A drum without electronic amplification', 4300),
	('DE', 'MDE', 'Musical', 'Electronic Drum','A drum with electronic amplification', 2500),
	('DH', 'MDH', 'Musical', 'Hybrid Drum', 'A drum with option for electronic amplification','2900'),
	('PD', 'MPD', 'Musical', 'Digital Piano', 'A piano with elecronic amplification', 6000),
	('PH', 'MPH', 'Musical', 'Hybrid Piano','A piano with electronic amplification option', 6420),
	('KP', 'MKP', 'Musical', 'Musical Portable Keyboard', 'A small keyboard easy to carry around', 7300),
	('KS', 'MKS', 'Musical', 'Musical Keyboard Synthesizer','An electroinic keyboard that mimic a traditional keyboard', 8300),
	('MS', 'MMS', 'Musical', 'Musical Monitor Studio','A playback system for music', 2700 ),
	('CDR', 'ACR', 'Accesories', 'CD Rewritable','CD for recording music audio', 10),
	('DVR', 'ADR', 'Accesories', 'DVD Rewritable','DVD for recording musical videos', 15),
	('BP', 'ABP', 'Accesories', 'Piano Book','A book for learning the piano instrument', 125),
	('BK', 'ABK', 'Accesories','Keyboard Book','A book for learning the keyboard instrument ', 150 ),
	('BG', 'ABG', 'Accesories', 'Guitar Book','A book for learning the guitar instrument', 200),
	('BD', 'ABD', 'Accesories', 'Drum Book','A book for learning how to pay the drum instrument', 280);

/*Data will insterted into the customer and transcation tables using stored procedures*/ 

/*STORED PROCEDURE FOR REGISTERING NEW CUSTOMER*/ 
CREATE OR REPLACE PROCEDURE register_new_customer(
	c_id VARCHAR(3),
	c_fname VARCHAR(20),
	c_sname VARCHAR(20),
	c_dateofbirth DATE,
	c_address VARCHAR(20),
	c_telephone_number VARCHAR(12)
)
LANGUAGE plpgsql
AS $$
DECLARE
 existing_customer_id VARCHAR(50);
BEGIN 
 SELECT customer_fname
 INTO existing_customer_id
 FROM customer 
 WHERE customer.customer_id = c_id;

 IF FOUND THEN
  RAISE NOTICE 'The customer already exists';
 ELSE
  INSERT INTO customer(customer_id, 
					 customer_fname, 
					 customer_sname, 
					 dateofbirth, 
					 address,
					 telephone_number )
										 
  VALUES(c_id, 
	   c_fname, 
	   c_sname,
	   c_dateofbirth, 
	   c_address, 
	   c_telephone_number);
 END IF;	   
END $$;

/*Testing the stored procedure for registering customers*/
/*Register new customers*/
/*Registering a customer using an invalid date of birth. We should get an error.*/
CALL register_new_customer('EN8','Edson','Kambeu', '1882/11/24', 'Plot 12798', '77474427');

/*Registering a customer with all valid entries*/
CALL register_new_customer('EN8','Edson','Kambeu', '1982/11/24', 'Plot 12798', '77474427');

/* Checking wether a new customer record has been inserted into customer table*/
SELECT *
FROM customer
WHERE customer_id = 'EN8';
/*We should see the record of the new customer in our customer table*/

/*Testing if we can register Edson, a customer who is already registered*/
CALL register_new_customer('EN8','Edson','Kambeu', '1982/11/24', 'Plot 12798', '77474427');

/*The above query should give us a notice that the customer already exists*/

/*STORED PROCEDURE FOR A CUSTOMER TO PURCHASE A PRODUCT*/
/*The stored procedure will also be used to insert dat into transcations table*/
/*Stored procedure will update stock level in warehouse if transcation is succesful*/

CREATE OR REPLACE PROCEDURE customer_purchase_product(
	c_id VARCHAR(3),
	selected_product VARCHAR(50),
	selected_store VARCHAR(20),
	transcation_quantity INTEGER,
	delivery_date_selected DATE,
	delivery_time_selected TIME,
	name_of_bank VARCHAR(20),
	account_no VARCHAR(20),
	bank_code VARCHAR (20),
	payment_amount DECIMAL
	
)
LANGUAGE plpgsql
AS $$
DECLARE
selected_product_id VARCHAR(3);
selected_store_id VARCHAR(3);
store_product_available VARCHAR(20);
quantity_in_store INTEGER;
selected_product_cost DECIMAL;
transcation_amount DECIMAL;
quantity_sold INTEGER;
warehouse_item_sold_id VARCHAR(3);
current_quantity_item_sold INTEGER;

BEGIN
--check if customer is registered
BEGIN
IF NOT EXISTS(SELECT *
			  FROM customer
		 WHERE customer_id = c_id) THEN
RAISE EXCEPTION 'Customer does not exist. Register the customer first';
END IF;
END;


--customer select a product
--Check if product exist
BEGIN
IF NOT EXISTS(SELECT product_name
			 FROM product
			 WHERE product_name = selected_product) THEN
RAISE EXCEPTION 'Product selected does not exist.';
END IF;
END;

--Identify product_id of selected product--
BEGIN
SELECT product_id 
INTO selected_product_id
FROM product
WHERE product_name = selected_product;
END;
  
--customer select store
--Check if selected store exist--
BEGIN
IF NOT EXISTS(SELECT store_name
			 FROM store
			 WHERE store_name = selected_store) THEN
RAISE EXCEPTION 'Selected store does not exist.';
END IF;
END;

--identify store id of selected store--
BEGIN
SELECT store_id
INTO selected_store_id
FROM store
WHERE store_name = selected_store;
END;

--Check which store is the product selected store
BEGIN 
SELECT store_name, product_name
INTO store_product_available
FROM product
LEFT JOIN warehouse_item
USING (warehouse_item_id)
LEFT JOIN store
USING (store_id)
WHERE product_name = selected_product;
END;

--check if selected store has the product
BEGIN
IF (selected_store <> store_product_available)
THEN
RAISE EXCEPTION 'Product is only available at %', store_product_available;
END IF;
END;

--check current_quantity for selected store-- 
BEGIN
SELECT current_quantity
INTO quantity_in_store
FROM product
LEFT JOIN warehouse_item
USING (warehouse_item_id)
WHERE product_id = selected_product_id;
END;

--check if quantity in selected store for selected product is adeqate---
BEGIN
IF (transcation_quantity > quantity_in_store)
THEN
 RAISE EXCEPTION 'There is no enough stock for the selected product %',selected_product;
END IF;
END;

--Check if delivery date is a weekday--
BEGIN
IF (SELECT EXTRACT(DOW FROM delivery_date_selected))
IN (0,6) THEN
RAISE EXCEPTION 'We do not deliver on Saturdays and Sundays';
END IF;
END;
---Check if delivery date is minimum 3 days from today
BEGIN
IF (delivery_date_selected < (CURRENT_DATE + INTERVAL'3 Days'))
THEN 
RAISE EXCEPTION 'Our minimum delivery time is 3 days.';
END IF;
END;

--Check if delivery time selected is between 9am and 4pm ---
BEGIN
IF delivery_time_selected 
NOT BETWEEN TIME '09:00:00' AND TIME '16:00:00' THEN
RAISE EXCEPTION 'We only deliver between 0900 hrs and 1600 hrs';
END IF;
END;
--Check product  price--
BEGIN
SELECT product_cost
INTO selected_product_cost
FROM product
WHERE product_id = selected_product_id;
RAISE NOTICE 'The % you wish to purchase costs P%',selected_product,selected_product_cost;
END;

--Calcuate transcation cost--
BEGIN
SELECT selected_product_cost * transcation_quantity
INTO transcation_amount;
RAISE NOTICE 'Your transcation amount is P%', transcation_amount;
END;

--Customer makes payment---
BEGIN
IF (payment_amount <> transcation_amount) 
THEN RAISE EXCEPTION 'Transcation is unsuccesful. Pay exactly P% .', transcation_amount;
ELSE 
 RAISE NOTICE 'Transcation is successful.';
END IF;
END;

--Insert data into transcation table--
BEGIN
INSERT INTO transcation (transcation_id,
						 customer_id,
						 product_id,
						 quantity,
						 delivery_date,
						 delivery_time,
						 bank_name,
						 sort_code,
						 bank_account_no,
						 transcation_date,
						 transcation_time)
VALUES(DEFAULT,
	   c_id,
	   selected_product_id,
	   transcation_quantity,
	   delivery_date_selected,
	   delivery_time_selected,
	   name_of_bank,
	   bank_code,
	   account_no,
	   DEFAULT,
	   DEFAULT);
RAISE NOTICE 'Transcation data entered into the database';
END;
	   
/* Update stock level in the warehouse*/
--Identify quantity sold in a successful transcation --
BEGIN 
SELECT quantity
INTO quantity_sold
FROM transcation 
WHERE product_id = selected_product_id;
END;
--Identify warehouse item id  of item sold--
BEGIN
SELECT warehouse_item_id
INTO warehouse_item_sold_id
FROM product 
WHERE product_id = selected_product_id;
END;
--Identify current quantity of item sold--
BEGIN
SELECT current_quantity
INTO current_quantity_item_sold
FROM warehouse_item
WHERE warehouse_item_id = warehouse_item_sold_id;
END;

--Update current quantity in warehouse table--
BEGIN
UPDATE warehouse_item
SET current_quantity = current_quantity_item_sold - quantity_sold
WHERE warehouse_item_id = warehouse_item_sold_id;
RAISE NOTICE 'inventory updated';
END;
END $$;


/*Testing the stored procedure*/
/*A customer tries to purchase without being registered*/
CALL customer_purchase_product('EN9',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/08/25',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);

/*A registired customer tries to purchase headphones a product that do not exist*/
CALL customer_purchase_product('EN8',
							   'Headphones',
							   'MME Francistown',
							   1,
							   '2022/08/25',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
/* A customer tries to buy at a store MME Maun that do not exist*/

CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Maun',
							   1,
							   '2022/08/25',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
/* A customer tries to buy at a store that do not have a product*/

CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Gaborone',
							   1,
							   '2022/08/25',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
							   
/* A customer purchases a product without enough stock*/							   
CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   100,
							   '2022/08/25',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
/*A customer chooses an incorrect delivery date which is a weekend*/
CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/09/24',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
/*A customer chooses an incorrect delivery date which is less than delivery time*/
/*Use todays date for testing*/
CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/08/22',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
										   
							   
/*A customer chooses an invalid delivery time which is a weekend*/
CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/09/23',
							   '19:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);
							   
/* A customer pays an incorrect amount*/
CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/09/23',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   2000);
							   
/* Before we enter a valid transcation for purchase of Accoustic Guitar, lets check current qunatity in stock*/ 
SELECT product_name, 
current_quantity AS quantity_before_purchase
FROM product
LEFT JOIN warehouse_item
USING (warehouse_item_id)
WHERE product_name = 'Accoustic Guitar';

/* This a valid transcation for the purchase of a guitar*/

CALL customer_purchase_product('EN8',
							   'Accoustic Guitar',
							   'MME Francistown',
							   1,
							   '2022/09/23',
							   '11:00:00',
							   'Absa',
							   '1140968',
							   '04',
							   5000);				  


/*Verify if transcation has been added into the transcation table*/
SELECT *
FROM transcation;

/*Check if warehouse item for accoustic guitar has been updated current quantity has been updated*/
SELECT product_name, 
current_quantity AS quantity_after_purchase
FROM product
LEFT JOIN warehouse_item
USING (warehouse_item_id)
WHERE product_name = 'Accoustic Guitar';
/* Transcation table is inserted with a new transcation record and warehouse item is updated simaltaneously*/
/*END*/






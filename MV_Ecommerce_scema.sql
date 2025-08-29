--  Part A (Q.3) : ERD into Relational Schema
--  Part B (Q.4, Q.5) : SQL DDL (Table Creation)

CREATE DATABASE IF NOT EXISTS multivendor_eCommerce;

USE multivendor_eCommerce;

-- CUSTOMER TABLE
CREATE TABLE `customer` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `phone_no` VARCHAR(20) UNIQUE,
  `address` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
);
-- ORDER TABLE
CREATE TABLE `order` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT,
  `order_date` DATETIME NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `order_status` ENUM('pending',  'delivered', 'cancelled') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY (`customer_id`) REFERENCES `customer`(`id`) ON DELETE SET NULL ON UPDATE CASCADE   -- preserve the `order` history
);
-- PAYMENT TABLE  
CREATE TABLE `payment` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` BIGINT UNIQUE,  -- Ensures one-to-one with orders 
  `payment_method` ENUM('Card', 'Bkash', 'PayPal', 'Cash on Delivery') DEFAULT 'Cash on Delivery',
  `amount` DECIMAL(10,2) NOT NULL,
  `payment_date` DATETIME NOT NULL,
  `payment_status` ENUM('Paid', 'Failed', 'Pending') DEFAULT 'Pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY (`order_id`) REFERENCES `order`(`id`) ON DELETE CASCADE ON UPDATE CASCADE  -- avoiding orphan records if parent record not exist
);
-- SUBSCRIPTION TABLE 
CREATE TABLE `subscription_plan` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `plan_name` VARCHAR(100) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `duration_in_months` INT NOT NULL,
  `features` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP    
);
-- Part B: Q.4 -- Creating Vendor table and defining foreign key reference to subscription_plan
CREATE TABLE `vendor` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `subscription_plan_id` INT,
  `business_name` VARCHAR(100) NOT NULL,
  `contact_person` VARCHAR(100) NOT NULL,
  `email` VARCHAR(50) UNIQUE NOT NULL,
  `phone_no` VARCHAR(20) UNIQUE NOT NULL,
  `address` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`subscription_plan_id`) REFERENCES `subscription_plan`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
);
-- PRODUCT TABLE
CREATE TABLE `product` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(255),
  `price` DECIMAL(8,2) NOT NULL,
  `stock_quantity` INT NOT NULL,
  `status` ENUM('active', 'inactive') DEFAULT 'active',  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY (`vendor_id`) REFERENCES `vendor`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
);
-- ORDER_PRODUCT PIVOT TABLE
CREATE TABLE `order_product` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `order_id` BIGINT,
  `product_id` INT,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(8,2) NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
  FOREIGN KEY (`order_id`) REFERENCES `order`(`id`) ON DELETE CASCADE ON UPDATE CASCADE, -- avoiding orphan records if parent record not exist
  FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
);
-- CATEGORY TABLE
CREATE TABLE `category` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);
-- Part B: Q.5 Creating the ProductCategory pivot table and establishing the M:N relationship between Product abd Category
CREATE TABLE `product_category` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` INT,
  `category_id` INT,
  `assign_date` DATETIME,
  `visible` BOOLEAN DEFAULT true, 
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   
  FOREIGN KEY (`category_id`) REFERENCES `category`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Part C: SQL DML (Insert/Update/Delete):

--Insert data on subscription_plan table
INSERT INTO `subscription_plan` (`plan_name`, `price`, `duration_in_months`, `features`)
VALUES
  ('Basic Plan', 999.00, 1, 'Access to basic features with limited support'),
  ('Standard Plan', 1999.00, 3, 'Access to standard features with priority support'),
  ('Premium Plan', 2999.00, 6, 'All features unlocked with 24/7 support'),
  ('Annual Plan', 5999.00, 12, 'Full features with annual billing discount'),
  ('Enterprise Plan', 3999.00, 12, 'Full features with Enterprise billing discount');
  
-- Part C: SQL DML: Q.6: Insert data on vendor table
INSERT INTO `vendor` (`subscription_plan_id`, `business_name`, `contact_person`, `email`, `phone_no`, `address`)
VALUES
  (1, 'SmartTech Ltd', 'Rahim Khan', 'rahim@smarttech.com', '017XXXXXXXX', 'Dhaka Bangladesh'),
  (2, 'Ryans Computers', 'Rakib Islam', 'rakib@ryanscomputers.net', '018XXXXXXXX', 'Uttara Dhaka Bangladesh'),
  (5, 'TechLand Computers', 'Rakib Islam', 'rakibul@techland.com', '0182XXXXXXX', 'Uttara Dhaka Bangladesh');

-- Insert data on category table 
INSERT INTO `category` (`name`, `description`)
VALUES
  ('Electronics', 'Desktops, laptops, keyboards, mice, and monitors.'),
  ('Networking Equipment', 'Routers, switches'),
  ('Software & Licensing', 'Operating systems, antivirus software, licensed software sales.'),
  ('IT Support Services', 'Technical support, troubleshooting, maintenance');

-- Part C: SQL DML: Q.7 Insert data on product table 
INSERT INTO `product` (`vendor_id`, `name`, `description`, `price`, `stock_quantity`, `status`) VALUES
  (1, 'Laptop', '14-inch business laptop', 75000.00, 10, 'active'),
  (1, 'Laptop 15-inch', '15-inch business laptop', 80000.00, 5, 'active'),
  (2, 'Microsoft Laptop', '13-inch laptop', 129000.00, 8, 'active'),
  (2, 'Mouse Pad', 'Value Top Mouse Pad', 150.00, 10, 'active'),
  (1, 'USB Converter', 'Logitech USB Converter', 200.00, 5, 'active'),
  (2, 'Keyboard', 'Value Top Keyboard', 650.00, 8, 'active'),
  (1, 'Mouse', 'Logitech Mouse', 560.00, 6, 'active'),
  (2, 'Pen Drive', 'TWINMOS Pen Drive', 450.00, 12, 'active'),
  (2, 'Routers', 'TWINMOS Routers', 2250.00, 0, 'inactive');  
  
-- Insert data on pivot table to set up connectivity between product and category table 
INSERT INTO `product_category` (`product_id`, `category_id`, `assign_date`)
VALUES
  (1, 1, NOW()),  
  (2, 1, NOW()),  
  (3, 1, NOW()),
  (4, 1, NOW()),
  (5, 1, NOW()),
  (6, 1, NOW()),
  (7, 1, NOW()),
  (8, 1, NOW()),
  (9, 1, NOW());

-- Part C: SQL DML: Q.8 Update the stock quantity of "Laptop" product to 15
UPDATE `product`
SET `stock_quantity` = 15
WHERE `name` = 'Laptop';

--Insert data on customer table 
INSERT INTO `customer` (`name`, `email`, `phone_no`, `address`) VALUES
('Rahim Khan', 'rahim.khan@gmail.com', '017XXXXXXXX', 'Uttara Dhaka Bangladesh'),
('Jubair Islam', 'Jubair.islam@gmail.com', '013XXXXXXXX', 'Banani Dhaka Bangladesh'),
('Mamun Sarkar', 'mamun.sarkar@gmail.com', '018XXXXXXXX', 'Mohakhali Dhaka Bangladesh'),
('Karim Uddin', 'karim.uddin@gmail.com', '0175XXXXXXX', 'Dhaka Bangladesh'),
('David Brown', 'oldcustomer@gmail.com', '011XXXXXXXX', 'Gulshan Dhaka Bangladesh'),
('Belal Hossian', 'belal.hossain@gmail.com', '01713XXXXXXX', 'Khilkhet Dhaka Bangladesh');


-- Part C: SQL DML: Q.9 Delete a customer whose email is "oldcustomer@gmail.com"
DELETE FROM `customer` WHERE `email` = 'oldcustomer@gmail.com';

--Part D: SQL Queries: Q.10 : to display all vendors along with their subscription plan name and price
SELECT `plan_name` as `subscription plan`, `price`,`business_name`, `contact_person`, `email`, `phone_no`, `address`
FROM `vendor`
LEFT JOIN `subscription_plan` ON `vendor`.`subscription_plan_id` = `subscription_plan`.`id`;


--Part D: SQL Queries: Q.11 : Find all products under the category "Electronics" with their name, price, and stock quantity
SELECT `c`.`name` as `category`, `p`.`name` as `product Name`, `price`, `stock_quantity` 
FROM `product` `p`
INNER JOIN `product_category` `pc` ON `p`.`id` = `pc`.`product_id`
INNER JOIN `category` `c` ON `c`.`id` = `pc`.`category_id`
WHERE `c`.`name` = 'Electronics';

--Part D: SQL Queries: Q.12: List all orders placed by customer "Karim Uddin", showing order_id, date, total_amount, and status.

-- Insert data into order table
INSERT INTO `order` (`customer_id`, `order_date`, `total_amount`, `order_status`) VALUES
(1, '2025-08-25 14:30:00', 1200.00, 'delivered'),
(2, '2025-08-26 10:15:00', 75000.00, 'pending'),
(4, '2025-08-26 16:45:00', 80000.00, 'cancelled'),
(4, '2025-08-27 09:00:00', 2010.00, 'delivered'),
(3, '2025-08-27 11:20:00', 129000.00, 'pending');

SELECT `c`.`name` as `customer`, `o`.`id` as `order_id`,  `order_date` as 'date', `total_amount`, `order_status` as `status` 
FROM `order` `o`
JOIN `customer` `c` ON `o`.`customer_id` = `c`.`id`
WHERE `c`.`name` = 'Karim Uddin';

--Part D: SQL Queries: Q.13 Show the payment details (method, amount, status) for order_id = 1.
INSERT INTO `payment` (`order_id`, `payment_method`, `amount`, `payment_date`, `payment_status`) VALUES 
(1, 'Bkash', 1200.00, '2025-08-25 14:31:00', 'Paid'),
(4, 'Card', 2010.00, '2025-08-27 09:01:00', 'Paid');

SELECT `order_id`, `payment_method` as `method`, `amount`, `payment_status` as `status`
FROM `payment`
WHERE `order_id` = 1;

-- Insert data into the pivot table `order_product`
INSERT INTO `order_product` (`order_id`, `product_id`, `quantity`, `unit_price`, `subtotal`) VALUES 
(1, 4, 1, 150.00, 150.00),
(1, 5, 3, 200.00, 600.00),
(1, 8, 1, 450.00, 450.00),
(2, 1, 1, 75000.00, 75000.00),
(3, 2, 1, 80000.00, 80000.00),
(4, 6, 1, 650.00, 650.00),
(4, 7, 1, 560.00, 560.00),
(4, 5, 4, 200.00, 800.00),
(5, 3, 1, 129000.00, 129000.00);

--Part D: SQL Queries: Q.14 Find the top 5 best-selling products based on total quantity sold.
SELECT  `p`.`id` AS `product_id`,  `p`.`name` AS `top_5_best_selling_product`,  SUM(`op`.`quantity`) AS `total_quantity_sold`
FROM `order_product` `op` 
JOIN `product` `p` ON `op`.`product_id` = `p`.`id` 
JOIN `order` `o` ON `op`.`order_id` = `o`.`id` 
WHERE `o`.`order_status` = 'delivered'
GROUP BY `p`.`id`, `p`.`name`
ORDER BY `total_quantity_sold` DESC
LIMIT 5;

-- Part E: Advanced SQL Q.15. Write a query to calculate the total sales amount per vendor.

WITH `per_vendor_sales` AS (SELECT  `p`.`vendor_id`, SUM(`op`.`subtotal`) AS `total_sales`
FROM `order_product` `op` 
JOIN `product` `p` ON `op`.`product_id` = `p`.`id` 
JOIN `order` `o` ON `op`.`order_id` = `o`.`id` 
WHERE `o`.`order_status` = 'delivered'
GROUP BY `p`.`vendor_id`
ORDER BY `total_sales` DESC)

SELECT `v`.`business_name` AS `Vendor`, `pvs`.`total_sales` AS `Total Sales` 
FROM `per_vendor_sales` `pvs`
JOIN `vendor` `v` ON `pvs`.`vendor_id`= `v`.`id`;

-- Part E: Advanced SQL Q.16. Find the names of customers who have not placed any orders.
SELECT `c`.`name` AS `Customer Name`
FROM `customer` `c`
LEFT JOIN `order` `o` ON `c`.`id` = `o`.`customer_id`
WHERE `o`.`customer_id` IS NULL;

-- Part E: Advanced SQL Q.17. Show the total number of active products available in the platform.
SELECT COUNT(*) AS `total_active_products`
FROM `product`
WHERE `status` = 'Active';

-- Part E: Advanced SQL Q.18. Retrieve the details of vendors who are subscribed to the Enterprise plan.
SELECT `sp`.`plan_name`, `business_name`, `contact_person`, `email`, `phone_no`, `address`  
FROM `vendor` `v`
LEFT JOIN `subscription_plan` `sp` ON `sp`.`id`= `v`.`subscription_plan_id`
WHERE `sp`.`plan_name` = 'Enterprise Plan';


-- Part E: Advanced SQL Q.19. Write a query to calculate the average order amount per customer.
SELECT `c`.`id`, `c`.`name`, AVG(`total_amount`) AS `average order amount`
FROM `order` `o`
INNER JOIN `customer` `c` ON `o`.`customer_id` = `c`.`id`
WHERE `o`.`order_status` IN ('pending', 'delivered')
GROUP BY `c`.`id`, `c`.`name`
ORDER BY `average order amount`;

-- Part E: Advanced SQL Q.20. Display the list of customers who purchased products from more than one vendor.
-- trace path: customer-order-order_product-product-vendor

SELECT `c`.`id` AS `customer_id`, `c`.`name` AS `customer_name`, `c`.`email` AS `customer_email`, `c`.`address` AS `customer_address`
FROM `customer` `c`
INNER JOIN `order` `o` ON `c`.`id` = `o`.`customer_id`
INNER JOIN `order_product` `op` ON `o`.`id` = `op`.`order_id`
INNER JOIN `product` `p` ON `op`.`product_id` =`p`.`id`
GROUP BY `c`.`id`
HAVING  COUNT(DISTINCT `p`.`vendor_id`) > 1;


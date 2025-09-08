-- Data Importing --
-- Creating a new database for hotel booking data
CREATE DATABASE hotel_booking_data;

-- Creating the main table to store hotel booking information
CREATE TABLE hotel_bookings (
    hotel VARCHAR(50),
    is_canceled TINYINT(1),
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(50),
    country CHAR(3),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest TINYINT(1),
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(20),
    agent VARCHAR(20),
    company VARCHAR(20),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    adr DECIMAL(10,2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(20),
    reservation_status_date DATE
);
-- Conceptualizing the Dataset -- 
-- Previewing all hotel bookings
SELECT * FROM hotel_bookings;

-- Counting total rows in hotel bookings
SELECT COUNT(*) FROM hotel_bookings;

-- Locating the Solvable Issues --

-- Creating a new table with row numbers for duplicate detection
CREATE TABLE `hotel_bookings_1` (
  `hotel` varchar(50) DEFAULT NULL,
  `is_canceled` tinyint(1) DEFAULT NULL,
  `lead_time` int DEFAULT NULL,
  `arrival_date_year` int DEFAULT NULL,
  `arrival_date_month` varchar(20) DEFAULT NULL,
  `arrival_date_week_number` int DEFAULT NULL,
  `arrival_date_day_of_month` int DEFAULT NULL,
  `stays_in_weekend_nights` int DEFAULT NULL,
  `stays_in_week_nights` int DEFAULT NULL,
  `adults` int DEFAULT NULL,
  `children` int DEFAULT NULL,
  `babies` int DEFAULT NULL,
  `meal` varchar(50) DEFAULT NULL,
  `country` char(3) DEFAULT NULL,
  `market_segment` varchar(50) DEFAULT NULL,
  `distribution_channel` varchar(50) DEFAULT NULL,
  `is_repeated_guest` tinyint(1) DEFAULT NULL,
  `previous_cancellations` int DEFAULT NULL,
  `previous_bookings_not_canceled` int DEFAULT NULL,
  `reserved_room_type` varchar(10) DEFAULT NULL,
  `assigned_room_type` varchar(10) DEFAULT NULL,
  `booking_changes` int DEFAULT NULL,
  `deposit_type` varchar(20) DEFAULT NULL,
  `agent` varchar(20) DEFAULT NULL,
  `company` varchar(20) DEFAULT NULL,
  `days_in_waiting_list` int DEFAULT NULL,
  `customer_type` varchar(50) DEFAULT NULL,
  `adr` decimal(10,2) DEFAULT NULL,
  `required_car_parking_spaces` int DEFAULT NULL,
  `total_of_special_requests` int DEFAULT NULL,
  `reservation_status` varchar(20) DEFAULT NULL,
  `reservation_status_date` date DEFAULT NULL,
  `rn` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data into new table and assigning row numbers to detect duplicates
INSERT INTO hotel_bookings_1 
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month,
                 arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights,
                 stays_in_week_nights, adults, children, babies, meal, country,
                 market_segment, distribution_channel, is_repeated_guest,
                 previous_cancellations, previous_bookings_not_canceled,
                 reserved_room_type, assigned_room_type, booking_changes, deposit_type,
                 agent, company, days_in_waiting_list, customer_type, adr,
                 required_car_parking_spaces, total_of_special_requests,
                 reservation_status, reservation_status_date
    ORDER BY reservation_status_date DESC
) AS rn
FROM hotel_bookings;

-- Previewing first 100 rows of the table with row numbers
SELECT * FROM hotel_bookings_1 LIMIT 100;

-- Counting how many duplicate rows exist (row number > 1)
SELECT COUNT(*) FROM hotel_bookings_1 WHERE rn > 1;

-- Keeping only the first occurrence of each duplicate and creating a clean table
CREATE TABLE hotel_bookings_clean AS
SELECT * FROM hotel_bookings_1
WHERE rn = 1;

-- Removing the temporary row number column
ALTER TABLE hotel_bookings_clean DROP COLUMN rn;

-- Checking min and max ADR
SELECT MAX(adr), MIN(adr) FROM hotel_bookings_clean;

-- Counting rows with negative ADR
SELECT COUNT(*) FROM hotel_bookings_clean WHERE adr < 0;

-- Removing rows with negative ADR
DELETE FROM hotel_bookings_clean WHERE adr < 0; -- Removed 1 Row --

-- Checking for extremely high ADR values
SELECT * FROM hotel_bookings_clean WHERE adr > 1000;

-- Removing rows with ADR above 1000
DELETE FROM hotel_bookings_clean WHERE adr > 1000; -- Removed 1 Row --

-- Checking the maximum and minimum lead time
SELECT MAX(lead_time), MIN(lead_time) FROM hotel_bookings_clean;

-- Counting rows with lead time above 365 days
SELECT COUNT(*) FROM hotel_bookings_clean WHERE lead_time > 365;

-- Removing rows with lead time above 365 days
DELETE FROM hotel_bookings_clean WHERE lead_time > 365;
-- Evaluating the Unsolvable Issues --

-- Counting missing values in agent, company, and country
SELECT 
    COUNT(*) - COUNT(agent) AS missing_agent,
    COUNT(*) - COUNT(company) AS missing_company,
    COUNT(*) - COUNT(country) AS missing_country
FROM hotel_bookings_clean;

-- Replacing missing country values with 'UNK'
UPDATE hotel_bookings_clean
SET country = 'UNK'
WHERE country IS NULL OR country = '';

-- Replacing missing agent values with 'UNK'
UPDATE hotel_bookings_clean
SET agent = 'UNK'
WHERE agent IS NULL OR agent = '';

-- Replacing missing company values with 'UNK'
UPDATE hotel_bookings_clean
SET company = 'UNK'
WHERE company IS NULL OR company = '';

-- Augmenting the Dataset --

-- Adding a new column to store total guests
ALTER TABLE hotel_bookings_clean ADD COLUMN total_guests INT;

-- Calculating total guests for each booking
UPDATE hotel_bookings_clean
SET total_guests = adults + children + babies;

-- Previewing total_guests for first 100 rows
SELECT total_guests FROM hotel_bookings_clean LIMIT 100;

-- Creating final cleaned table using CTAS
CREATE TABLE hotel_bookings_final AS
SELECT *
FROM hotel_bookings_clean;

-- Adding an Auto-Increment ID 
ALTER TABLE hotel_bookings_final
ADD COLUMN booking_id INT AUTO_INCREMENT PRIMARY KEY;



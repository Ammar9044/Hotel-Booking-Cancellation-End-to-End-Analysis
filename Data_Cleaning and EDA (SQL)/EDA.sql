-- 1. Calculating overall cancellation rate
SELECT 
    ROUND(COUNT(CASE WHEN is_canceled = 1 THEN 1 END) * 100 / COUNT(*), 2 ) AS cancellation_rate
FROM hotel_bookings_final;


-- 2. Counting cancellations for City Hotel
SELECT COUNT(*) AS Canceled_Bookings
FROM hotel_bookings_final
WHERE is_canceled = 1 AND hotel = 'City Hotel'; 


-- 3. Counting cancellations for Resort Hotel
SELECT COUNT(*) AS Canceled_Bookings
FROM hotel_bookings_final
WHERE is_canceled = 1 AND hotel = 'Resort Hotel'; 


-- 4. Comparing cancellation rate between City and Resort hotels
SELECT 
    hotel,
    ROUND(COUNT(CASE WHEN is_canceled = 1 THEN 1 END) * 100 / COUNT(*), 2) AS cancellation_rate
FROM hotel_bookings_final
GROUP BY hotel;


-- 5. Calculating average lead time by hotel
SELECT 
    hotel, 
    AVG(lead_time) AS avg_lead_time
FROM hotel_bookings_final
GROUP BY 1;


-- 6. Comparing lead time for canceled vs not canceled bookings by hotel
SELECT 
    hotel,
    is_canceled,
    COUNT(*) AS bookings_count,
    ROUND(AVG(lead_time), 2) AS avg_lead_time
FROM hotel_bookings_final
GROUP BY hotel, is_canceled
ORDER BY hotel, is_canceled;


-- 7. Comparing ADR (price per night) for canceled vs not canceled bookings
SELECT 
    hotel,
    is_canceled,
    COUNT(*) AS bookings_count,
    ROUND(AVG(adr), 2) AS avg_adr
FROM hotel_bookings_final
GROUP BY hotel, is_canceled
ORDER BY hotel, is_canceled;


-- 8. Investigating seasonality: cancellation rate by arrival month
SELECT 
    arrival_date_month, 
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY 1
ORDER BY avg_cancellation DESC;


-- 9. Cancellation rate by deposit type
SELECT 
    deposit_type,
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY deposit_type
ORDER BY avg_cancellation DESC;


-- 10. Cancellation rate by customer type
SELECT 
    customer_type,
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY customer_type
ORDER BY avg_cancellation DESC;


-- 11. Cancellation rate by market segment
SELECT 
    market_segment,
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY market_segment
ORDER BY avg_cancellation DESC;


-- 12. Cancellation rate by country
SELECT 
    country,
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY country
ORDER BY avg_cancellation DESC;


-- 13. Cancellation rate by number of special requests
SELECT 
    total_of_special_requests,
    ROUND(AVG(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100, 2) AS avg_cancellation
FROM hotel_bookings_final
GROUP BY total_of_special_requests
ORDER BY avg_cancellation DESC;

WITH repeat_analysis AS (
    SELECT 
        is_repeated_guest,
        COUNT(*) AS total_bookings,
        SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) AS canceled_bookings
    FROM hotel_bookings
    GROUP BY is_repeated_guest
)
SELECT 
    is_repeated_guest,
    total_bookings,
    canceled_bookings,
    ROUND(canceled_bookings * 100.0 / total_bookings, 2) AS cancellation_rate_pct
FROM repeat_analysis;

WITH adr_bins AS (
    SELECT 
        CASE 
            WHEN adr < 50 THEN 'Low (<50)'
            WHEN adr BETWEEN 50 AND 100 THEN 'Medium (50-100)'
            WHEN adr BETWEEN 100 AND 200 THEN 'High (100-200)'
            ELSE 'Premium (>200)'
        END AS adr_range,
        is_canceled
    FROM hotel_bookings
)
SELECT 
    adr_range,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS total_canceled,
    ROUND(100.0 * SUM(is_canceled) / COUNT(*), 2) AS cancellation_rate
FROM adr_bins
GROUP BY adr_range
ORDER BY cancellation_rate DESC;

WITH yearly_data AS (
    SELECT 
        arrival_date_year AS year,
        COUNT(*) AS total_bookings,
        SUM(is_canceled) AS total_canceled
    FROM hotel_bookings
    GROUP BY arrival_date_year
)
SELECT 
    year,
    total_bookings,
    total_canceled,
    ROUND(100.0 * total_canceled / total_bookings, 2) AS cancellation_rate,
    ROUND(
        (100.0 * total_canceled / total_bookings) 
        - LAG(100.0 * total_canceled / total_bookings) OVER (ORDER BY year),
        2
    ) AS yoy_change
FROM yearly_data
ORDER BY year;




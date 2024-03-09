-- Combine data set

CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4;


-- EDA -------------------------------------------------------------------------

-- check the number of unique app in both table 

SELECT COUNT(DISTINCT id) As Appid
FROM AppleStore;
-- 7197

SELECT COUNT(DISTINCT id) as Appid
FROM appleStore_description_combined;
-- 7197


-- check missing value 
SELECT COUNT(*) As missingvalue
from AppleStore
where track_name is NULL or user_rating is NULL;
-- 0

SELECT COUNT(*) As missingvalue
from appleStore_description_combined
where track_name is NULL;
-- 0


-- Prime Genre

SELECT COUNT(DISTINCT prime_genre) AS UniqueGenreCount
FROM AppleStore;
-- 23

Bar-SELECT prime_genre, COUNT(*) AS AppCount
FROM AppleStore
GROUP BY prime_genre
ORDER BY AppCount DESC;


-- Price 
SELECT COUNT(DISTINCT price) AS UniquePriceCount,
       Max(Price) As Max_Price,
       Min(Price) As Min_Price,
       SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END) AS FreeAppCount,
       SUM(CASE WHEN price > 0 THEN 1 ELSE 0 END) AS PaidAppCount
FROM AppleStore;

SELECT price, COUNT(*) AS AppCount
FROM AppleStore
GROUP BY price
ORDER BY price;

PIE-SELECT price, COUNT(*) AS AppCount
FROM AppleStore
GROUP BY price
ORDER BY price;


-- User ratings 
BAR-SELECT user_rating AS Star, COUNT(*) AS count
FROM AppleStore
GROUP BY user_rating
ORDER BY user_rating;

-- average user rating
SELECT avg(user_rating) As AvgRating
from AppleStore;


-- Size 
PIE-SELECT 
    CASE
        WHEN size_bytes < 50000000 THEN '0MB~50MB'
        WHEN size_bytes BETWEEN 50000000 AND 100000000 THEN '50MB~100MB'
        WHEN size_bytes BETWEEN 100000001 AND 200000000 THEN '100MB~200MB'
        ELSE '>200MB'
    END AS SizeRange,
    COUNT(*) AS AppCount
FROM AppleStore
GROUP BY SizeRange
ORDER By SizeRange;


-- Lamgusge Support
SELECT lang_num, COUNT(*) AS AppCount
FROM AppleStore
GROUP BY lang_num;


-- Question ---------------------------------------------------------------------

-- Question 1. Whether Price will affect the user ratings
BAR-SELECT price > 0 AS IsPaid, AVG(user_rating) AS AverageRating
FROM AppleStore
GROUP BY IsPaid;

LINE-SELECT 
  CASE
    WHEN price = 0 THEN 'Free'
    WHEN price BETWEEN 0.01 AND 1.99 THEN 'Inexpensive'
    WHEN price BETWEEN 2 AND 9.99 THEN 'Moderate'
    WHEN price BETWEEN 10 AND 49.99 THEN 'Expensive'
    ELSE 'Very Expensive'
  END AS PriceCategory,
  AVG(user_rating) AS AverageRating
FROM AppleStore
GROUP BY PriceCategory
ORDER BY 
  CASE PriceCategory
    WHEN 'Free' THEN 1
    WHEN 'Inexpensive' THEN 2
    WHEN 'Moderate' THEN 3
    WHEN 'Expensive' THEN 4
    WHEN 'Very Expensive' THEN 5
  END, 
  AverageRating DESC;




-- Q2. User ratings and popularity by category (calculated here using the number of total ratings)

SELECT prime_genre, AVG(user_rating) AS AverageRating, SUM(rating_count_tot) AS TotalRatings
FROM AppleStore
WHERE rating_count_tot > 0
GROUP BY prime_genre
ORDER BY AverageRating DESC, TotalRatings DESC;



-- Q3. Does the level of detail in the app description affect user ratings and number of downloads?

SELECT a.id, a.track_name, a.user_rating, a.rating_count_tot, d.app_desc, LENGTH(d.app_desc) AS desc_length
FROM AppleStore a
JOIN appleStore_description_combined d ON a.id = d.id;


SELECT 
    CASE 
        WHEN LENGTH(d.app_desc) < 500 THEN 'Short'
        WHEN LENGTH(d.app_desc) BETWEEN 500 AND 1500 THEN 'Medium'
        ELSE 'Long'
    END AS desc_length_group,
    AVG(a.user_rating) AS average_rating, 
    AVG(a.rating_count_tot) AS average_rating_count, 
    AVG(LENGTH(d.app_desc)) AS average_desc_length,
    COUNT(*) AS app_count
FROM AppleStore a
JOIN appleStore_description_combined d ON a.id = d.id
GROUP BY CASE 
            WHEN LENGTH(d.app_desc) < 500 THEN 'Short'
            WHEN LENGTH(d.app_desc) BETWEEN 500 AND 1500 THEN 'Medium'
            ELSE 'Long'
         END

UNION ALL

SELECT 
    'All' AS desc_length_group,
    AVG(a.user_rating) AS average_rating, 
    AVG(a.rating_count_tot) AS average_rating_count, 
    AVG(LENGTH(d.app_desc)) AS average_desc_length,
    COUNT(*)
FROM AppleStore a
JOIN appleStore_description_combined d ON a.id = d.id;


SET search_path to laptop_schema;



/******* A. Price and Value Analysis *******/


- Q1: Average price of laptops for each brand
- What is the average price of laptops for each brand?

```
SELECT brand, ROUND(AVG(price), 2) AS avg_price
FROM laptops
GROUP BY brand
ORDER BY avg_price DESC;
```


| brand     | avg_price |
|-----------|-----------|
| Razer     | 199990.00 |
| Apple     | 187862.00 |
| Samsung   | 134224.24 |
| MSI       | 126735.39 |
| LG        | 117097.20 |
| Dell      | 104804.47 |
| Gigabyte  | 96991.67  |
| Huawei    | 96830.83  |
| Colorful  | 89999.00  |
| Microsoft | 86794.50  |
| HP        | 82586.11  |
| Ninkear   | 79999.00  |
| Asus      | 74286.74  |
| Lenovo    | 73901.54  |
| Fujitsu   | 73278.67  |
| Xiaomi    | 63323.33  |
| Honor     | 62323.33  |
| Acer      | 62042.32  |
| Realme    | 47999.00  |
| Infinix   | 40240.00  |
| Wings     | 33490.00  |
| Zebronics | 32177.50  |
| Chuwi     | 27866.13  |
| Avita     | 25416.50  |
| Tecno     | 23990.00  |
| Ultimus   | 18740.00  |
| AXL       | 14990.00  |
| Jio       | 14850.00  |
| Walker    | 12990.00  |
| Primebook | 12490.00  |
| iBall     | 8000.00   |



   
- Q2: Correlation between price and spec score
- What is the correlation between price and spec score?

```
SELECT ROUND(CORR(price, spec_score)::NUMERIC, 2) AS correlation
FROM laptops;
```

| correlation |
|-------------|
| 0.73        |




-- Q3: Price difference between NVIDIA and other graphics cards

-- Is there a significant price difference between laptops with 
-- NVIDIA graphics cards and those with other graphics card?

```SELECT 
    CASE 
        WHEN graphics_card LIKE '%NVIDIA%' THEN 'NVIDIA Graphics'
        ELSE 'Other Graphics'
    END AS graphics_type,
    COUNT(*) AS laptop_count,
    ROUND(AVG(price), 2) AS average_price
FROM laptops
GROUP BY 
    CASE 
        WHEN graphics_card LIKE '%NVIDIA%' THEN 'NVIDIA Graphics'
        ELSE 'Other Graphics'
    END;```

| graphics_type   | laptop_count | average_price |
|-----------------|--------------|---------------|
| Other Graphics  | 652          | 64125.52      |
| NVIDIA Graphics | 368          | 122242.23     |



-- Based on the output, there is a substantial price difference 
-- between laptops with NVIDIA graphics cards and those with 
-- other graphics cards. 

-- Laptops with NVIDIA graphics have a significantly higher average price (₹122,242.23) 
-- compared to those with other graphics cards (₹64,125.52), 
-- nearly double the price, suggesting that NVIDIA graphics cards are associated 
-- with higher-end, more expensive laptop models.

   
   
   
-- Q4: Most common OS in laptops priced over 100,000
-- Which operating system is most common among laptops priced over 100,000?

SELECT os, COUNT(*) AS laptop_count
FROM laptops
WHERE price > 100000
GROUP BY os
ORDER BY laptop_count DESC;


| os         | laptop_count |
|------------|--------------|
| Windows 11 | 219          |
| Mac        | 15           |
| Windows 10 | 2            |
| Unknown    | 1            |
| Windows    | 1            |

   
   
   
-- Q5: Relationship between RAM capacity and price
-- What is the relationship between RAM capacity and price?


WITH ram_extracted AS (
    SELECT 
        price,
        CASE 
            WHEN internal_memory LIKE '%TB%' THEN 
                CAST(SUBSTRING(UPPER(internal_memory) FROM '[0-9]+(?=\s*TB)') AS INTEGER) * 1024
            WHEN internal_memory LIKE '%GB%' THEN 
                CAST(SUBSTRING(UPPER(internal_memory) FROM '[0-9]+(?=\s*GB)') AS INTEGER)
            ELSE 0
        END AS ram_gb
    FROM laptops
),
ram_categories AS (
    SELECT 
        CASE 
            WHEN ram_gb <= 128 THEN '0-128 GB'
            WHEN ram_gb <= 512 THEN '129-512 GB'
            ELSE '513+ GB'
        END AS ram_category,
        price
    FROM ram_extracted
)
SELECT 
    ram_category,
    COUNT(*) AS laptop_count,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM ram_categories
GROUP BY ram_category
ORDER BY 
    CASE 
        WHEN ram_category = '0-128 GB' THEN 1
        WHEN ram_category = '129-512 GB' THEN 2
        WHEN ram_category = '513+ GB' THEN 3
    END;
	
	
| ram_category | laptop_count | avg_price | min_price | max_price |
|--------------|--------------|-----------|-----------|-----------|
| 0-128 GB     | 23           | 23709.13  | 8000      | 150000    |
| 129-512 GB   | 725          | 62034.69  | 15990     | 231746    |
| 513+ GB      | 272          | 151744.54 | 34980     | 599990    |
	


-- The data shows a clear correlation between RAM capacity and laptop prices, 
-- with higher RAM capacities associated with significantly higher average prices. 
-- Laptops in the highest RAM category (513+ GB) have an average price more than 
-- six times that of the lowest category (0-128 GB), indicating that RAM capacity 
-- is a major factor in determining laptop pricing.
   
   
   
-- Q6: Average price of laptops with a spec score above 70
-- What is the average price of laptops with a spec score above 70?


SELECT ROUND(AVG(price), 2) AS avg_price_above_70_spec_score
FROM laptops
WHERE spec_score > 70;


| avg_price_above_70_spec_score |
|-------------------------------|
| 183649.26                     |






/******* B. Brand and Market Analysis ********/


-- Q7: Top 5 laptop brands with highest average user rating
-- Which are laptop brands have the top 5 highest average user rating?


SELECT brand, ROUND(AVG(user_rating), 1) AS avg_user_ratings
FROM laptops
GROUP BY brand
ORDER BY avg_user_ratings DESC
LIMIT 5;

| brand     | avg_user_ratings |
|-----------|------------------|
| Colorful  | 4.6              |
| Huawei    | 4.5              |
| LG        | 4.5              |
| Microsoft | 4.4              |
| Tecno     | 4.4              |


   
-- Q8: Brand offering the highest number of Gaming laptops
-- Which brand offers the highest number of Gaming laptops?


SELECT brand, COUNT(*) AS num_of_gaming_laptops
FROM laptops
WHERE utility LIKE '%Gaming%'
GROUP BY brand
ORDER BY num_of_gaming_laptops DESC
LIMIT 1;


| brand  | num_of_gaming_laptops |
|--------|-----------------------|
| Lenovo | 63                    |





-- Q9: Average warranty period by brand

-- What is the average warranty period offered by each brand?


SELECT brand, 
       ROUND(AVG(CAST(SUBSTRING(warranty FROM '[0-9]+') AS INTEGER)), 2) AS avg_warranty_years
FROM laptops
GROUP BY brand
ORDER BY avg_warranty_years DESC;


| brand     | avg_warranty_years |
|-----------|--------------------|
| Gigabyte  | 2.00               |
| Fujitsu   | 2.00               |
| MSI       | 1.82               |
| Xiaomi    | 1.17               |
| Lenovo    | 1.11               |
| Huawei    | 1.00               |
| Ultimus   | 1.00               |
| Walker    | 1.00               |
| Ninkear   | 1.00               |
| Wings     | 1.00               |
| Jio       | 1.00               |
| AXL       | 1.00               |
| iBall     | 1.00               |
| Dell      | 1.00               |
| Chuwi     | 1.00               |
| Apple     | 1.00               |
| Primebook | 1.00               |
| Realme    | 1.00               |
| HP        | 1.00               |
| Avita     | 1.00               |
| Razer     | 1.00               |
| Zebronics | 1.00               |
| Asus      | 1.00               |
| Samsung   | 1.00               |
| Acer      | 1.00               |
| Tecno     | 1.00               |
| Infinix   | 1.00               |
| Microsoft | 1.00               |
| Colorful  | 1.00               |
| LG        | 1.00               |
| Honor     | 1.00               |






-- Q10:
-- How does the market share of different brands vary across different 
-- price segments (budget, mid-range, premium)?


-- first, create price segments for the laptops
-- Budget: 8,000 - 40,000, Mid-range: 40,001 - 100,000, Premium: 100,001 - 599,990


WITH price_segments_cte AS
(SELECT brand, name, 
 		CASE WHEN price <= 40000 THEN 'Budget'
 			 WHEN price BETWEEN 40001 AND 100000 THEN 'Mid-range'
 			 ELSE 'Premium' END AS price_segment
 FROM laptops
)
, brand_cte AS (
SELECT brand, price_segment, COUNT(*) AS laptop_count
FROM price_segments_cte
GROUP BY brand, price_segment
)
SELECT price_segment, brand,
	   laptop_count,
	   SUM(laptop_count) OVER(PARTITION BY price_segment) AS total_in_segment,
	   ROUND(100.0 * laptop_count / 
					SUM(laptop_count) OVER(PARTITION BY price_segment), 2) AS market_share
FROM brand_cte
ORDER BY price_segment, market_share DESC;



| price_segment | brand     | laptop_count | total_in_segment | market_share |
|---------------|-----------|--------------|------------------|--------------|
| Budget        | Lenovo    | 43           | 205              | 20.98        |
| Budget        | HP        | 35           | 205              | 17.07        |
| Budget        | Asus      | 34           | 205              | 16.59        |
| Budget        | Acer      | 27           | 205              | 13.17        |
| Budget        | Dell      | 16           | 205              | 7.80         |
| Budget        | Infinix   | 14           | 205              | 6.83         |
| Budget        | Chuwi     | 8            | 205              | 3.90         |
| Budget        | Zebronics | 6            | 205              | 2.93         |
| Budget        | MSI       | 4            | 205              | 1.95         |
| Budget        | Ultimus   | 4            | 205              | 1.95         |
| Budget        | Wings     | 3            | 205              | 1.46         |
| Budget        | Avita     | 2            | 205              | 0.98         |
| Budget        | Primebook | 2            | 205              | 0.98         |
| Budget        | Jio       | 2            | 205              | 0.98         |
| Budget        | AXL       | 2            | 205              | 0.98         |
| Budget        | Walker    | 1            | 205              | 0.49         |
| Budget        | iBall     | 1            | 205              | 0.49         |
| Budget        | Tecno     | 1            | 205              | 0.49         |
| Mid-range     | Lenovo    | 132          | 577              | 22.88        |
| Mid-range     | HP        | 116          | 577              | 20.10        |
| Mid-range     | Asus      | 115          | 577              | 19.93        |
| Mid-range     | Dell      | 66           | 577              | 11.44        |
| Mid-range     | MSI       | 57           | 577              | 9.88         |
| Mid-range     | Acer      | 45           | 577              | 7.80         |
| Mid-range     | Infinix   | 8            | 577              | 1.39         |
| Mid-range     | Samsung   | 6            | 577              | 1.04         |
| Mid-range     | Xiaomi    | 5            | 577              | 0.87         |
| Mid-range     | Huawei    | 5            | 577              | 0.87         |
| Mid-range     | Gigabyte  | 4            | 577              | 0.69         |
| Mid-range     | Fujitsu   | 3            | 577              | 0.52         |
| Mid-range     | Honor     | 3            | 577              | 0.52         |
| Mid-range     | Microsoft | 2            | 577              | 0.35         |
| Mid-range     | Apple     | 2            | 577              | 0.35         |
| Mid-range     | Zebronics | 2            | 577              | 0.35         |
| Mid-range     | LG        | 2            | 577              | 0.35         |
| Mid-range     | Ninkear   | 1            | 577              | 0.17         |
| Mid-range     | Realme    | 1            | 577              | 0.17         |
| Mid-range     | Colorful  | 1            | 577              | 0.17         |
| Mid-range     | Wings     | 1            | 577              | 0.17         |
| Premium       | MSI       | 49           | 238              | 20.59        |
| Premium       | HP        | 48           | 238              | 20.17        |
| Premium       | Lenovo    | 32           | 238              | 13.45        |
| Premium       | Dell      | 31           | 238              | 13.03        |
| Premium       | Asus      | 30           | 238              | 12.61        |
| Premium       | Samsung   | 15           | 238              | 6.30         |
| Premium       | Apple     | 15           | 238              | 6.30         |
| Premium       | Acer      | 10           | 238              | 4.20         |
| Premium       | LG        | 3            | 238              | 1.26         |
| Premium       | Gigabyte  | 2            | 238              | 0.84         |
| Premium       | Razer     | 1            | 238              | 0.42         |
| Premium       | Huawei    | 1            | 238              | 0.42         |
| Premium       | Xiaomi    | 1            | 238              | 0.42         |






-- Summary of the output:

-- 1. Market Dominance:
-- In the budget segment, Lenovo leads with 20.98% market share, followed 
-- closely by HP (17.07%) and Asus (16.59%).
   
-- The mid-range segment is also dominated by Lenovo (22.88%), HP (20.10%), 
-- and Asus (19.93%), showing their strong presence across both budget 
-- and mid-range markets.
   
-- In the premium segment, MSI takes the lead with 20.59% market share, 
-- closely followed by HP at 20.17%, indicating HP's strong presence across all segments.

-- 2. Brand Diversity:
-- The budget segment shows the most brand diversity with 18 different brands 
-- represented, including some lesser-known names like Chuwi, Ultimus, and Primebook.
-- The mid-range segment has 20 brands, but with a more concentrated market 
-- share among the top brands.
-- The premium segment is the least diverse with only 12 brands, dominated 
-- by well-established names.

-- 3. Segment Distribution:
-- The mid-range segment is the largest with 577 laptops, followed by the 
-- premium segment with 238 laptops, and the budget segment with 205 laptops.
-- Some brands like Apple and Samsung have a stronger presence in the 
-- premium segment compared to budget and mid-range.
-- Certain brands (e.g., Infinix, Zebronics) appear in budget and mid-range 
-- but not in the premium segment, indicating their market focus.




-- Q11:
-- What is the average user rating for laptops in different utility categories 
-- (e.g., gaming, business, everyday use) across brands?


SELECT utility, ROUND(AVG(user_rating), 2) AS avg_user_rating
FROM laptops
WHERE utility IS NOT NULL
GROUP BY utility
ORDER BY avg_user_rating DESC;



|utility                                    |avg_user_rating|
|-------------------------------------------|---------------|
|Business, Everyday Use, Performance        |4.60           |
|Performance, Business                      |4.54           |
|Gaming, Everyday Use, Performance          |4.50           |
|Everyday Use, Gaming, Business, Performance|4.48           |
|Everyday Use, Gaming, Performance          |4.45           |
|Everyday Use, Performance, Gaming          |4.45           |
|Everyday Use, Business, Performance, Gaming|4.42           |
|Everyday Use, Business                     |4.41           |
|Performance, Everyday Use                  |4.37           |
|Gaming, Performance                        |4.36           |
|Gaming                                     |4.36           |
|Performance, Gaming                        |4.33           |
|Business, Performance                      |4.33           |
|Everyday Use, Performance                  |4.33           |
|Everyday Use, Gaming                       |4.32           |
|Performance                                |4.31           |
|Business, Everyday Use                     |4.30           |
|Gaming, Everyday Use                       |4.30           |
|Everyday Use                               |4.27           |
|Business                                   |4.27           |
|Everyday Use, Business, Performance        |4.24           |
|Performance, Business, Everyday Use        |4.20           |











/****** C. Performance and Specifications ******/


-- Q12: Average spec score across different processor brands
-- How does the average spec score vary across different processor brands?



SELECT brand, ROUND(AVG(spec_score), 2) AS avg_spec_score
FROM laptops
GROUP BY brand
ORDER BY avg_spec_score DESC;


| brand     | avg_spec_score |
|-----------|----------------|
| Razer     | 83.00          |
| Ninkear   | 73.00          |
| MSI       | 71.20          |
| LG        | 70.20          |
| Colorful  | 70.00          |
| Gigabyte  | 69.17          |
| Fujitsu   | 64.00          |
| Samsung   | 63.10          |
| HP        | 62.02          |
| Dell      | 61.88          |
| Xiaomi    | 61.83          |
| Asus      | 61.34          |
| Zebronics | 60.25          |
| Lenovo    | 59.37          |
| Huawei    | 59.17          |
| Acer      | 57.41          |
| Tecno     | 56.00          |
| Realme    | 56.00          |
| Honor     | 55.00          |
| Microsoft | 54.50          |
| Apple     | 53.94          |
| Infinix   | 52.55          |
| Wings     | 49.00          |
| Chuwi     | 45.63          |
| Ultimus   | 42.75          |
| Avita     | 42.00          |
| iBall     | 35.00          |
| AXL       | 33.50          |
| Walker    | 33.00          |
| Primebook | 30.00          |
| Jio       | 21.00          |







-- Q13: Percentage of laptops with SSD storage
-- What percentage of laptops in the dataset have SSD storage?


SELECT CONCAT(ROUND(100.0 * SUM(CASE WHEN internal_memory LIKE '%SSD%' THEN 1 ELSE 0 END) 
			 / COUNT(*), 2), '%') AS pct_ssd_laptops
FROM laptops;


| pct_ssd_laptops |
|-----------------|
| 98.82%          |




-- Q14: Distribution of processor cores across laptop utilities
-- How does the distribution of processor cores vary across different laptop utilities 
-- (e.g., business, gaming, everyday use)?


SELECT utility, processor_core, COUNT(*) AS laptop_count
FROM laptops
WHERE utility IS NOT NULL AND processor_core IS NOT NULL
GROUP BY utility, processor_core
ORDER BY utility DESC, laptop_count DESC;


| utility                                     | processor_core | laptop_count |
|---------------------------------------------|----------------|--------------|
| Performance, Everyday Use                   | Core i5        | 7            |
| Performance, Everyday Use                   | Core i3        | 2            |
| Performance, Business, Everyday Use         | Core i7        | 1            |
| Performance, Business                       | Core i7        | 3            |
| Performance                                 | Core i5        | 126          |
| Performance                                 | Core i7        | 82           |
| Performance                                 | Core i3        | 63           |
| Performance                                 | Core i9        | 22           |
| Performance                                 | Core N4500     | 1            |
| Gaming, Performance                         | Core i5        | 9            |
| Gaming, Performance                         | Core i9        | 5            |
| Gaming, Performance                         | Core i7        | 4            |
| Gaming, Everyday Use                        | Core i7        | 1            |
| Gaming                                      | Core i5        | 74           |
| Gaming                                      | Core i7        | 35           |
| Gaming                                      | Core i9        | 20           |
| Everyday Use, Performance                   | Core i5        | 13           |
| Everyday Use, Performance                   | Core i3        | 7            |
| Everyday Use, Performance                   | Core i7        | 4            |
| Everyday Use, Performance                   | Core i9        | 1            |
| Everyday Use, Gaming, Business, Performance | Core i5        | 5            |
| Everyday Use, Gaming, Business, Performance | Core i3        | 1            |
| Everyday Use, Gaming, Business, Performance | Core i7        | 1            |
| Everyday Use, Gaming                        | Core i7        | 2            |
| Everyday Use, Business, Performance, Gaming | Core i5        | 4            |
| Everyday Use, Business, Performance, Gaming | Core i3        | 2            |
| Everyday Use, Business, Performance         | Core i5        | 20           |
| Everyday Use, Business, Performance         | Core i3        | 14           |
| Everyday Use, Business, Performance         | Core i7        | 6            |
| Everyday Use, Business                      | Core i5        | 3            |
| Everyday Use, Business                      | Core i3        | 2            |
| Everyday Use                                | Core i5        | 51           |
| Everyday Use                                | Core i7        | 17           |
| Everyday Use                                | Core i3        | 16           |
| Everyday Use                                | Core i9        | 4            |
| Everyday Use                                | Core Z3735     | 1            |
| Business, Performance                       | Core i5        | 15           |
| Business, Performance                       | Core i7        | 8            |
| Business, Performance                       | Core i3        | 5            |
| Business, Performance                       | Core i9        | 2            |
| Business                                    | Core i5        | 7            |
| Business                                    | Core i7        | 6            |
| Business                                    | Core i3        | 3            |



-- The data shows that Core i5 processors are the most common across almost 
-- all utility categories, particularly in "Performance" and "Gaming" laptops. 
-- There's a notable presence of Core i7 and Core i9 processors in high-performance 
-- categories like "Gaming" and "Performance", while Core i3 processors are more 
-- prevalent in "Everyday Use" and budget-oriented configurations.




-- Q15: Distribution of Intel vs. AMD processors
-- What is the distribution of laptops with Intel vs. AMD processors?


SELECT processor_brand, COUNT(*) AS laptop_count
FROM laptops
WHERE processor_brand IS NOT NULL
GROUP BY processor_brand
ORDER BY laptop_count DESC;



| processor_brand | laptop_count |
|-----------------|--------------|
| Intel           | 763          |
| Amd             | 227          |



-- The data clearly shows that Intel processors dominate the laptop market 
-- in this dataset, with more than three times as many laptops featuring 
-- Intel processors (763) compared to AMD processors (227).





-- Q16: Types and frequency of ROM memory
-- What are the different types of ROM memory available 
-- in the laptops, and how frequently do they occur?


SELECT rom_memory, COUNT(*) AS laptop_count
FROM laptops
GROUP BY rom_memory
ORDER BY laptop_count DESC;


| rom_memory        | laptop_count |
|-------------------|--------------|
| 16 GB DDR4 RAM    | 249          |
| 8 GB DDR4 RAM     | 245          |
| 16 GB DDR5 RAM    | 137          |
| 16 GB LPDDR5 RAM  | 109          |
| 8 GB LPDDR5 RAM   | 50           |
| 32 GB DDR5 RAM    | 47           |
| 8 GB DDR5 RAM     | 23           |
| 16 GB LPDDR4X RAM | 21           |
| 16 GB LPDDR5X RAM | 18           |
| 8 GB LPDDR4X RAM  | 13           |
| 16 GB RAM         | 9            |
| 32 GB LPDDR5 RAM  | 9            |
| 8 GB RAM          | 9            |
| 4 GB DDR4 RAM     | 8            |
| 4 GB LPDDR4X RAM  | 7            |
| 8 GB LPDDR4 RAM   | 7            |
| 32 GB LPDDR5X RAM | 7            |
| 32 GB LPDDR5x RAM | 6            |
| 16 GB LPDDR5x RAM | 5            |
| 16 GB LPDDR4x RAM | 3            |
| 64 GB DDR5 RAM    | 3            |
| 16 GB LPDDR4 RAM  | 3            |
| 4 GB LPDDR4 RAM   | 3            |
| 18 GB RAM         | 3            |
| 32 GB DDR4 RAM    | 3            |
| 36 GB RAM         | 2            |
| 4 GB ‎LPDDR4 RAM  | 2            |
| 32 GB LPDDR4X RAM | 2            |
| 8 GB LPDDR4x RAM  | 2            |
| 16 GB DDR5 SDRAM  | 2            |
| 16 GB DDR6 RAM    | 1            |
| 16 GB LPDDRx4 RAM | 1            |
| DDR5 RAM          | 1            |
| 2 GB DDR3 RAM     | 1            |
| 16 GB DDR4- RAM   | 1            |
| 8 GB DDR3 RAM     | 1            |
| 16 GB PDDR5X RAM  | 1            |
| 8 GB DDR5 SDRAM   | 1            |
| 64 GB LPDDR5 RAM  | 1            |
| 12 GB DDR4 RAM    | 1            |
| 12 GB LPDDR3 RAM  | 1            |
| 48 GB RAM         | 1            |
| 12 GB LPDDR4 RAM  | 1            |



-- Q17: Common graphics card brands in high-rated laptops
-- Which graphics card brands are most commonly used in high-rated laptops?


-- define high-rated laptops as those that fall within the 
-- top 10% of their spec_score values

-- Identify the laptops in the 90th percentile of spec_score


WITH spec_score_distribution AS (
    SELECT spec_score, 
           NTILE(10) OVER (ORDER BY spec_score DESC) AS percentile_rank
    FROM laptops
)
SELECT graphics_card, COUNT(*) AS laptop_count
FROM laptops
WHERE spec_score IN (
    SELECT spec_score 
    FROM spec_score_distribution 
    WHERE percentile_rank = 1
)
GROUP BY graphics_card
ORDER BY laptop_count DESC;



| graphics_card                               | laptop_count |
|---------------------------------------------|--------------|
| 8 GB, NVIDIA GeForce RTX 4060 Graphics      | 30           |
| 8 GB, NVIDIA GeForce RTX 4070 Graphics      | 19           |
| 16 GB, NVIDIA GeForce RTX 4090 Graphics     | 11           |
| 6 GB, NVIDIA GeForce RTX 4050 Graphics      | 11           |
| 12 GB, NVIDIA GeForce RTX 4080 Graphics     | 7            |
| Intel Arc Graphics                          | 3            |
| 12 GB, NVIDIA Geforce RTX 4080 Graphics     | 3            |
| 8 GB, NVIDIA GEFORCE RTX 4060 Graphics      | 3            |
| 6 GB, NVIDIA RTX 4050 Graphics              | 2            |
| 4 GB, Intel Arc A370M Graphics              | 1            |
| 12 GB, NVIDIA GEFORCE RTX 4080 Graphics     | 1            |
| 8 GB, NVIDIA GeForce RTX 3070 Ti Graphics   | 1            |
| 16 GB, NVIDIA GeForce RTX 3080 Ti Graphics  | 1            |
| 12 GB, NVIDIA GeForce RTX 3080 Ti Graphics  | 1            |
| 12 GB, Nvidia GeForce RTX4080 Graphics      | 1            |
| 4 GB,  NVIDIA GeForce RTX 3050 Graphics     | 1            |
| 8 GB, NVIDIA Geforce RTX 4060 Graphics      | 1            |
| 4 GB, Nvidia Quadro T1200 Graphics          | 1            |
| 8 GB, NVIDIA GeForce RTX A2000 Ada Graphics | 1            |
| Intel Iris Xe Graphics                      | 1            |
| AMD Radeon Graphics                         | 1            |
| 8 GB, AMD Radeon RX 7600S Graphics          | 1            |
| 12 GB, NVIDIA GeForce RTX 3500 Ada Graphics | 1            |




-- Summary:

-- The output shows that the most commonly used graphics card in 
-- high-rated laptops (those in the top 10% of spec scores) is the 
-- "8 GB, NVIDIA GeForce RTX 4060 Graphics," appearing in 30 laptops. 
-- Other popular options include the "8 GB, NVIDIA GeForce RTX 4070 Graphics" 
-- with 19 laptops and the "16 GB, NVIDIA GeForce RTX 4090 Graphics" and 
-- "6 GB, NVIDIA GeForce RTX 4050 Graphics," each with 11 laptops. 

-- NVIDIA graphics cards dominate the high-rated laptop segment, 
-- with a few occurrences of Intel and AMD graphics cards.





-- Q18: Common RAM and storage combinations across processor generations
-- What is the most common combination of RAM and storage capacity, and how has this 
-- changed across different processor generations?


SELECT rom_memory, internal_memory, processor_gen
FROM laptops;


-- Q19: Average number of USB ports in different price ranges
-- What is the average number of USB ports for laptops in different price ranges?



-- Q20:
-- How does the presence of Thunderbolt ports correlate with other 
-- high-end specifications and price?







/****** D. Physical Characteristics *******/


-- Q21: Average weight across screen size categories
-- How does the average weight of laptops differ across screen size categories?


SELECT screen_size, ROUND(AVG(weight), 2) AS avg_weight
FROM laptops
WHERE weight IS NOT NULL
GROUP BY screen_size
ORDER BY avg_weight DESC;


| screen_size          | avg_weight |
|----------------------|------------|
| 18 inches Largest    | 3.29       |
| 17 inches Largest    | 2.71       |
| 17.3 inches Large    | 2.71       |
| 16 inches Smallest   | 2.64       |
| 17.3 inches Largest  | 2.63       |
| 17 inches Smallest   | 2.49       |
| 16.1 inches Largest  | 2.48       |
| 16.1 inches Large    | 2.36       |
| 17 inches Average    | 2.35       |
| 17 inches Large      | 2.33       |
| 16 inches Average    | 2.26       |
| 15.75 inches Large   | 2.25       |
| 16.2 inches Average  | 2.16       |
| 16.2 inches Large    | 2.14       |
| 15.6 inches Average  | 1.95       |
| 16 inches Large      | 1.94       |
| 15 inches Average    | 1.89       |
| 15.6 inches Large    | 1.85       |
| 15.6 inches Small    | 1.85       |
| 16 inches Largest    | 1.83       |
| 14.5 inches Small    | 1.75       |
| 15.6 inches Largest  | 1.69       |
| 14.2 inches Smallest | 1.62       |
| 14.2 inches Small    | 1.54       |
| 15.3 inches Small    | 1.51       |
| 15.3 inches Average  | 1.51       |
| 14 inches Small      | 1.45       |
| 14 inches Smallest   | 1.43       |
| 14.2 inches Average  | 1.43       |
| 14 inches Average    | 1.43       |
| 13.3 inches Smallest | 1.34       |
| 14.1 inches Average  | 1.32       |
| 14.1 inches Small    | 1.30       |
| 13.4 inches Small    | 1.28       |
| 13.5 inches Small    | 1.27       |
| 11.6 inches Small    | 1.25       |
| 13.6 inches Small    | 1.24       |
| 11.6 inches Smallest | 1.23       |
| 12.4 inches Smallest | 1.13       |
| 13.3 inches Small    | 1.05       |
| 11.6 inches Largest  | 1.00       |
| 11.6 inches Average  | 0.99       |
| 12 inches Small      | 0.81       |
| 12.6 inches Small    | 0.70       |




-- Q22: Distribution of laptops across thickness categories

-- What is the distribution of laptops across different thickness categories?


SELECT thickness_category, COUNT(*) AS laptop_count
FROM laptops
WHERE thickness_category IS NOT NULL
GROUP BY thickness_category
ORDER BY laptop_count DESC;



| thickness_category | laptop_count |
|--------------------|--------------|
| Average            | 270          |
| Slim               | 250          |
| Thick              | 227          |
| Thickest           | 12           |
| Ultra Slim         | 12           |





-- Q23: Relationship between thickness and weight
-- How does the thickness of laptops relate to their weight? 
-- Are thicker laptops generally heavier?



-- Q24: 
-- What is the relationship between screen size and overall laptop weight?





/******** E. User Experience and Ratings  ********/


-- Q25: Highest user-rated laptops and their price comparison
-- Which laptops have the highest user rating, and how does their price 
-- compare to the average?

-- define highest user_rated laptops as those with maximum user rating

WITH highest_rated_laptops AS (
SELECT name, user_rating, price
FROM laptops 
WHERE user_rating = (SELECT MAX(user_rating) FROM laptops)
)
, average_cte AS (
SELECT ROUND(AVG(price), 2) AS avg_price
FROM laptops
)
SELECT name, user_rating, price, avg_price, 
	   (price - avg_price) AS price_diff, 
	   ROUND(100.0 * (price - avg_price)/(avg_price), 2) AS percent_diff
FROM highest_rated_laptops
CROSS JOIN average_cte
ORDER BY percent_diff DESC;


| name                                                | user_rating | price  | avg_price | price_diff | percent_diff |
|-----------------------------------------------------|-------------|--------|-----------|------------|--------------|
| Apple MacBook Pro 14 2023 Laptop                    | 4.8         | 186899 | 85093.11  | 101805.89  | 119.64       |
| Samsung Galaxy Book 4 Pro 14 NP940XGK-KG3IN Laptop  | 4.8         | 171990 | 85093.11  | 86896.89   | 102.12       |
| MSI Prestige 16 AI Studio B1VEG Laptop              | 4.8         | 159990 | 85093.11  | 74896.89   | 88.02        |
| HP Omen 16-wf0054TX Gaming Laptop                   | 4.8         | 151490 | 85093.11  | 66396.89   | 78.03        |
| LG Gram 17 2023 17Z90R-G.CH77A2 Laptop              | 4.8         | 146990 | 85093.11  | 61896.89   | 72.74        |
| Asus Zenbook S13 OLED 2024 UX5304MA-NQ762WS Laptop  | 4.8         | 139990 | 85093.11  | 54896.89   | 64.51        |
| Acer Nitro 16 ‎AN16-41 Gaming Laptop                | 4.8         | 129990 | 85093.11  | 44896.89   | 52.76        |
| MSI Pulse 17 B13VGK-666IN Gaming Laptop             | 4.8         | 128990 | 85093.11  | 43896.89   | 51.59        |
| Acer Swift Edge 16 2023 Laptop                      | 4.8         | 107399 | 85093.11  | 22305.89   | 26.21        |
| MSI Bravo 15 C7VFK-087IN Gaming Laptop              | 4.8         | 104989 | 85093.11  | 19895.89   | 23.38        |
| Lenovo IdeaPad Slim 5i 82XF003DIN Laptop            | 4.8         | 90000  | 85093.11  | 4906.89    | 5.77         |
| Asus Vivobook 16X K3605VU-MB541WS Laptop            | 4.8         | 89990  | 85093.11  | 4896.89    | 5.75         |
| Asus Vivobook 16X 2023 K3605ZF-MBN741WS Laptop      | 4.8         | 88990  | 85093.11  | 3896.89    | 4.58         |
| Lenovo Yoga Slim 6 14IRH8 83E00012INLaptop          | 4.8         | 81400  | 85093.11  | -3693.11   | -4.34        |
| Dell Vostro 5630 IN5630P8YRR001ORS1 Laptop          | 4.8         | 78980  | 85093.11  | -6113.11   | -7.18        |
| Asus Vivobook 16X K3605ZU-MBN541WS Laptop           | 4.8         | 76990  | 85093.11  | -8103.11   | -9.52        |
| Asus Vivobook Pro 15 M6500QC-LK742WS Laptop         | 4.8         | 73990  | 85093.11  | -11103.11  | -13.05       |
| Dell Inspiron 7430 2023 2 in 1 Laptop               | 4.8         | 69990  | 85093.11  | -15103.11  | -17.75       |
| HP Victus 15-fa1124TX Gaming Laptop                 | 4.8         | 59997  | 85093.11  | -25096.11  | -29.49       |
| Xiaomi Redmi Book Pro 14 2024 Laptop                | 4.8         | 59990  | 85093.11  | -25103.11  | -29.50       |
| Asus Vivobook Pro 15 M6500QF-HN541WS Creator Laptop | 4.8         | 57990  | 85093.11  | -27103.11  | -31.85       |
| HP Victus 15-fb1018AX Gaming Laptop                 | 4.8         | 54990  | 85093.11  | -30103.11  | -35.38       |
| Acer Aspire 5 A514-56M 2023 Gaming Laptop           | 4.8         | 53990  | 85093.11  | -31103.11  | -36.55       |
| HP 15s-EQ2084AU Laptop                              | 4.8         | 52199  | 85093.11  | -32894.11  | -38.66       |
| HP 15s-er2004AU Laptop                              | 4.8         | 50990  | 85093.11  | -34103.11  | -40.08       |
| Lenovo IdeaPad Slim 3 82H803HQIN Laptop             | 4.8         | 48900  | 85093.11  | -36193.11  | -42.53       |
| Lenovo S14 Gen 3 82TW000VIH Laptop                  | 4.8         | 45990  | 85093.11  | -39103.11  | -45.95       |
| Lenovo Thinkpad E16 G1 21JN004DIG Laptop            | 4.8         | 42990  | 85093.11  | -42103.11  | -49.48       |
| HP 14s-dq5138tu Laptop                              | 4.8         | 39990  | 85093.11  | -45103.11  | -53.00       |
| Acer Aspire 3 Spin 14 NX.KENSI.002 Laptop           | 4.8         | 39990  | 85093.11  | -45103.11  | -53.00       |
| Lenovo IdeaPad Slim 3 82RK00VVIN Laptop             | 4.8         | 37990  | 85093.11  | -47103.11  | -55.35       |



-- The highest user rating in the dataset is 4.8, with 31 laptops 
-- achieving this rating across various price points.

-- There's a wide price range among these top-rated laptops, from 
-- ₹37,990 to ₹186,899, indicating that high user satisfaction 
-- isn't solely tied to price.

-- About half of the highest-rated laptops are priced below the 
-- average price of ₹85,093.11, suggesting that there are many 
-- well-regarded options available at more affordable price points.






-- Q26:
-- Is there a correlation between the number of user votes and the user rating?


-- Q27:
-- How does the average user rating change for laptops with different screen sizes?





/******** F. Specialized Features  *********/

-- Q28: Average battery life across laptop utilities


-- Q29:
-- What is the average battery life across different laptop 
-- utilities (e.g., gaming, business)?


-- Q30:
-- What percentage of laptops offer touch screen functionality, 
-- and how does this correlate with price?


-- Q31:
-- How does the presence of a backlit keyboard affect the average price 
-- and user rating of laptops?


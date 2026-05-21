create database EV_Project;
show tables;
use EV_Project;
select * from ev_data;


#1. Filtering Grouped Results: Premium Safety Standards
SELECT 
    brand,
    ROUND(AVG(safety_rating), 2) as average_safety_rating,
    ROUND(AVG(customer_rating), 2) as average_customer_rating
FROM ev_data
GROUP BY brand
HAVING AVG(safety_rating) >= 4.0 
   AND AVG(customer_rating) > 3.7
ORDER BY average_customer_rating DESC;

#2. Conditional Labeling: Driving Range Categorization
SELECT 
    brand,
    model,
    variant,
    range_miles,
    CASE 
        WHEN range_miles < 200 THEN 'Short Range (City Commuter)'
        WHEN range_miles BETWEEN 200 AND 300 THEN 'Standard Range (Balanced)'
        ELSE 'Long Range (Interstate Capable)'
    END as autonomy_classification
FROM ev_data
ORDER BY range_miles DESC;

#3. Regional Market Breakdown
SELECT 
    country_of_origin,
    market_segment,
    SUM(annual_sales_units) as total_units_sold,
    COUNT(DISTINCT brand) as active_manufacturing_brands
FROM ev_data
GROUP BY country_of_origin, market_segment
ORDER BY country_of_origin ASC, total_units_sold DESC;

#4. Combining Results Sets: The Showcase Catalog
(
    SELECT 'Fastest Flagships' as showcase_category, brand, model, acceleration_0_60_mph as metric, price_usd
    FROM ev_data
    ORDER BY acceleration_0_60_mph ASC
    LIMIT 3
)
UNION ALL
(
    SELECT 'Most Affordable' as showcase_category, brand, model, price_usd as metric, price_usd
    FROM ev_data
    ORDER BY price_usd ASC
    LIMIT 3
);

#5. Subquery
SELECT 
    VolumeBrands.brand,
    ROUND(AVG(VolumeBrands.price_usd), 2) as filtered_average_price,
    MAX(VolumeBrands.customer_rating) as peak_customer_rating
FROM (
    SELECT * FROM ev_data
    WHERE brand IN (
        SELECT brand 
        FROM ev_data 
        GROUP BY brand 
        HAVING SUM(annual_sales_units) >= 1000000
    )
) as VolumeBrands
GROUP BY VolumeBrands.brand;

#6. Conditional Aggregation: Drivetrain Counts
SELECT 
    brand,
    COUNT(CASE WHEN drive_type = 'AWD' THEN 1 END) as awd_variants_count,
    COUNT(CASE WHEN drive_type = 'RWD' THEN 1 END) as rwd_variants_count,
    COUNT(CASE WHEN drive_type = 'FWD' THEN 1 END) as fwd_variants_count,
    COUNT(*) as total_fleet_variants
FROM ev_data
GROUP BY brand
ORDER BY total_fleet_variants DESC;

#7.  Market Segment Leaders (Dense Ranking)
WITH RankedEVs AS (
    SELECT 
        market_segment, brand, model, variant, range_miles, price_usd,
        DENSE_RANK() OVER (PARTITION BY market_segment ORDER BY range_miles DESC) as range_rank
    FROM ev_data
)
SELECT * FROM RankedEVs 
WHERE range_rank <= 3
ORDER BY market_segment, range_rank;

# 8. Cumulative Sales and National Market Share
WITH CountrySales AS (
    SELECT country_of_origin, SUM(annual_sales_units) as total_sales
    FROM ev_data
    GROUP BY country_of_origin
),
GlobalTotal AS (
    SELECT SUM(total_sales) as grand_total FROM CountrySales
)
SELECT 
    country_of_origin,
    total_sales,
    SUM(total_sales) OVER (ORDER BY total_sales DESC) as cumulative_sales,
    ROUND(100.0 * total_sales / (SELECT grand_total FROM GlobalTotal), 2) as global_market_share_pct
FROM CountrySales;
# 9. Cross-Tabulation Matrix (Pivoting via Conditional Aggregation)
SELECT 
    brand,
    COUNT(CASE WHEN market_segment = 'Luxury' THEN 1 END) as luxury_models_count,
    COUNT(CASE WHEN market_segment = 'Premium' THEN 1 END) as premium_models_count,
    COUNT(CASE WHEN market_segment = 'Mid-range' THEN 1 END) as midrange_models_count,
    ROUND(AVG(price_usd), 2) as global_average_price
FROM ev_data
GROUP BY brand
ORDER BY global_average_price DESC;

#10. Over-the-Average Filtering (Correlated Subquery)
SELECT 
    brand, model, body_type, price_usd, market_segment
FROM ev_data e1
WHERE price_usd > (
    SELECT AVG(price_usd) 
    FROM ev_data e2 
    WHERE e2.body_type = e1.body_type
)
ORDER BY body_type, price_usd DESC;

#11. Efficiency Benchmarking Matrix 
WITH EfficiencyMetrics AS (
    SELECT 
        brand, model, body_type, battery_capacity_kwh, range_miles,
        ROUND((cast(range_miles as float) / battery_capacity_kwh), 2) as miles_per_kwh,
        ROW_NUMBER() OVER (
            PARTITION BY body_type 
            ORDER BY (cast(range_miles as float) / battery_capacity_kwh) DESC
        ) as efficiency_rank
    FROM ev_data
)
SELECT * FROM EfficiencyMetrics 
WHERE efficiency_rank = 1;

#12. Multi-Level Performance Cohort Filters
SELECT 
    brand,
    COUNT(DISTINCT model) as distinct_models_produced,
    ROUND(AVG(customer_rating), 2) as average_brand_rating,
    SUM(annual_sales_units) as cumulative_brand_sales
FROM ev_data
GROUP BY brand
HAVING COUNT(DISTINCT model) >= 5 
   AND AVG(customer_rating) > 3.75 
   AND SUM(annual_sales_units) > 500000
ORDER BY cumulative_brand_sales DESC; 

#13. Multi-Column Composite Window Partitioning
SELECT 
    country_of_origin,
    drive_type,
    brand,
    model,
    horsepower,
    RANK() OVER (
        PARTITION BY country_of_origin, drive_type 
        ORDER BY horsepower DESC
    ) as dynamic_power_rank
FROM ev_data
ORDER BY country_of_origin, drive_type, dynamic_power_rank;

#14. Percentile Distribution Profiling
WITH PowerPercentiles AS (
    SELECT 
        brand, model, variant, horsepower, price_usd,
        PERCENT_RANK() OVER (ORDER BY horsepower DESC) as horsepower_percentile
    FROM ev_data
)
SELECT * FROM PowerPercentiles 
WHERE horsepower_percentile <= 0.10
ORDER BY horsepower DESC;

#15. Rolling Window Moving Averages
SELECT 
    brand, year, model, variant, customer_rating,
    ROUND(AVG(customer_rating) OVER (
        PARTITION BY brand 
        ORDER BY year ASC 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as rolling_three_year_average_rating
FROM ev_data;

#16. Dynamic Price-to-Performance Multi-Tier Indexing
SELECT 
    brand, model, variant, price_usd, acceleration_0_60_mph,
    CASE 
        WHEN acceleration_0_60_mph < 4.0 AND price_usd < 60000 THEN 'Hyper-Value Sport'
        WHEN acceleration_0_60_mph < 4.0 AND price_usd >= 100000 THEN 'Premium Supercar'
        WHEN acceleration_0_60_mph >= 6.0 AND price_usd < 40000 THEN 'Economical Commuter'
        WHEN acceleration_0_60_mph >= 6.0 AND price_usd >= 80000 THEN 'Overpriced Luxury'
        ELSE 'Balanced Market Spec'
    END as performance_value_cohort
FROM ev_data
ORDER BY performance_value_cohort, price_usd ASC;

#17. Median Price Simulation via Row Tracking
WITH OrderedPrices AS (
    SELECT 
        brand, price_usd,
        ROW_NUMBER() OVER (PARTITION BY brand ORDER BY price_usd ASC) as price_row,
        COUNT(*) OVER (PARTITION BY brand) as total_brand_cars
    FROM ev_data
)
SELECT 
    brand,
    ROUND(AVG(price_usd), 2) as estimated_median_price
FROM OrderedPrices
WHERE price_row IN ((total_brand_cars + 1) / 2, (total_brand_cars + 2) / 2)
GROUP BY brand;
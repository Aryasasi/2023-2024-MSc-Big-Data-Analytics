--QUESTION 1
SELECT channel_id,prod_id,
    SUM(amount_sold) AS total_sales FROM sales
GROUP BY
    channel_id, prod_id;
       
--QUESTION 2

Drop MATERIALIZED VIEW SALES_CHAN_PROD_MV;

CREATE MATERIALIZED VIEW SALES_CHAN_PROD_MV 
   REFRESH FORCE ON DEMAND
    WITH PRIMARY KEY
   ENABLE QUERY REWRITE
AS 
 SELECT channel_id,prod_id,
    SUM(amount_sold) AS total_sales FROM sales
GROUP BY channel_id, prod_id;   
       
--QUESTION 3

SELECT
    c.channel_desc AS channel_description,
    p.prod_name AS product_name,
    SUM(s.amount_sold) AS total_sales
FROM  sales s
    JOIN channels c ON s.channel_id = c.channel_id
    JOIN products p ON s.prod_id = p.prod_id
GROUP BY c.channel_desc, p.prod_name;

--QUESTION 5

SELECT * FROM USER_DIMENSIONS;

DROP DIMENSION TIMES_DIM;
DROP DIMENSION PRODUCTS_DIM;
DROP DIMENSION CUSTOMERS_DIM;

DROP MATERIALIZED VIEW CAL_MONTH_SALES_MV;
DROP MATERIALIZED VIEW TOTAL_SALES_MV;  
DROP MATERIALIZED VIEW TOTAL_SALES_MV2;  


CREATE DIMENSION sales_prod_dim 
    LEVEL amount_sold IS ( sales.amount_sold )
    LEVEL product IS ( products.prod_id )
    LEVEL category IS ( products.prod_category )
    LEVEL prod_name IS ( products.prod_name )   
    HIERARCHY spc_rollup (
    
         amount_sold  CHILD OF
         product      CHILD OF 
         category     CHILD OF 
         prod_name
    JOIN KEY (sales.prod_id) REFERENCES product
    )
   ATTRIBUTE category DETERMINES (
        products.prod_category,
        products.prod_category_desc,
        products.prod_subcategory,
        products.prod_subcategory_desc
    )
    ATTRIBUTE product DETERMINES (
        products.prod_desc,
        products.prod_weight_class,
        products.prod_unit_of_measure,
        products.prod_pack_size,
        products.prod_status,
        products.prod_list_price,
        products.prod_min_price
    )
    ATTRIBUTE prod_name DETERMINES (
        products.prod_desc
    )
    ATTRIBUTE amount_sold DETERMINES (
        sales.quantity_sold);
--QUESTION 7

SELECT      ch.channel_desc as channel,
 DECODE(GROUPING(p.prod_category), 1, 'All Categories', p.prod_category) as Category,
            DECODE(GROUPING(shc.country_name), 1, 'France and Italy', shc.country_name) as Country , 
            SUM(amount_sold)as total_sales
FROM        sales s, customers c, times t, channels ch, shcountries shc, products p
WHERE       s.time_id = t.time_id
AND         c.cust_id = s.cust_id
AND         s.channel_id = ch.channel_id
AND         s.prod_id=p.prod_id
AND         p.prod_category IN ('Electronics', 'Software/Other')
AND         ch.channel_desc IN ('Direct Sales', 'Internet')
AND         shc.country_name IN ('France' , 'Italy')
AND         t.calendar_month_desc IN ('2001-05','2001-06')
GROUP BY ROLLUP (ch.channel_desc, t.calendar_month_desc, shc.country_name,p.prod_category);


SELECT PROD_CATEGORY FROM PRODUCTS;
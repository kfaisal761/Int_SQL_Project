-- total revenue per cohort year

SELECT 
	cohort_year,
	SUM(total_net_revenue)
FROM
	cohort_analysis
GROUP BY 
	cohort_year;
	
WITH sales_data AS (SELECT 
	c.customerkey,
	SUM(s.quantity*s.netprice/s.exchangerate) AS net_revenue
	
FROM customer c 
LEFT JOIN sales s ON c.customerkey = s.customerkey
GROUP BY 
	c.customerkey
)

SELECT 
	AVG(net_revenue) AS avg_spending_custoner_reveune,
	AVG(coalesce(net_revenue, 0)) AS avg_customer 
	
FROM sales_data;



DROP VIEW cohort_analysis;

CREATE OR REPLACE VIEW public.cohort_analysis AS 
WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice / s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON s.customerkey = c.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    concat(TRIM(givenname),' ',TRIM(surname)) AS cleaned_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;
-- Q0: Show table schema
\d+ retail;

-- Q1: Show first 10 rows
SELECT * FROM retail LIMIT 10;

-- Q2: Check # of records
SELECT COUNT(*) FROM retail;

-- Q3: Number of clients (unique customer_id)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Q4: Invoice date range (max/min)
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- Q5: Number of SKU (unique stock_code)
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- Q6: Average invoice amount excluding negative invoices
SELECT AVG(invoice_total)
FROM (
  SELECT invoice_no,
         SUM(unit_price * quantity) AS invoice_total
  FROM retail
  GROUP BY invoice_no
  HAVING SUM(unit_price * quantity) > 0
) t;

-- Q7: Total revenue
SELECT SUM(unit_price * quantity) FROM retail;

-- Q8: Total revenue by YYYYMM
SELECT TO_CHAR(invoice_date, 'YYYYMM') AS yyyymm,
       SUM(unit_price * quantity) AS revenue
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;

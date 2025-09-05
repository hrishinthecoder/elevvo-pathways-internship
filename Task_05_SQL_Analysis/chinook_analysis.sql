-- ===================================================================================
-- Chinook (PostgreSQL) End-to-End Analysis
-- Assumes lowercase, unquoted, plural table names:
-- artists, albums, tracks, genres, media_types, customers, employees,
-- invoices, invoicelines, playlists, playlisttrack
--
-- If your DB uses CamelCase (e.g., "Album", "Artist"), add double quotes.
-- ===================================================================================

-- ---------------------------------------------
-- [0] Quick sanity checks & helpers
-- ---------------------------------------------

-- List row counts by table (adjust names if needed)
-- Purpose: sanity check that data is loaded
SELECT 'artists' AS table, COUNT(*) AS rows FROM artists
UNION ALL SELECT 'albums', COUNT(*) FROM albums
UNION ALL SELECT 'tracks', COUNT(*) FROM tracks
UNION ALL SELECT 'genres', COUNT(*) FROM genres
UNION ALL SELECT 'media_types', COUNT(*) FROM media_types
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'invoices', COUNT(*) FROM invoices
UNION ALL SELECT 'invoicelines', COUNT(*) FROM invoicelines
UNION ALL SELECT 'playlists', COUNT(*) FROM playlists
UNION ALL SELECT 'playlisttrack', COUNT(*) FROM playlisttrack
ORDER BY table;

-- Optional performance tips (commented out):
-- CREATE INDEX IF NOT EXISTS idx_invoicelines_invoiceid ON invoicelines(invoiceid);
-- CREATE INDEX IF NOT EXISTS idx_invoicelines_trackid   ON invoicelines(trackid);
-- CREATE INDEX IF NOT EXISTS idx_invoices_customer_date ON invoices(customerid, invoicedate);
-- CREATE INDEX IF NOT EXISTS idx_tracks_genreid         ON tracks(genreid);
-- CREATE INDEX IF NOT EXISTS idx_albums_artistid        ON albums(artistid);
-- CREATE INDEX IF NOT EXISTS idx_customers_supportrep   ON customers(supportrepid);
-- CREATE INDEX IF NOT EXISTS idx_playlisttrack_trackid  ON playlisttrack(trackid);

-- NOTE: Many queries below use a CTE named line_revenue that includes quantity and line total.
--       This keeps the math/columns consistent across analyses.

-- ---------------------------------------------
-- [1] Top 20 customers by total spend
-- ---------------------------------------------
-- Purpose: identify highest-value customers
WITH line_revenue AS (
  SELECT
    il.invoicelineid,
    il.invoiceid,
    il.trackid,
    il.quantity,
    (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
),
customer_spend AS (
  SELECT i.customerid, SUM(lr.line_total) AS revenue
  FROM invoices i
  JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
  GROUP BY i.customerid
)
SELECT
  c.customerid,
  c.firstname || ' ' || c.lastname AS customer_name,
  c.country,
  ROUND(cs.revenue, 2) AS total_spend
FROM customer_spend cs
JOIN customers c ON c.customerid = cs.customerid
ORDER BY total_spend DESC
LIMIT 20;

-- ---------------------------------------------
-- [2] Customer distribution & revenue by country
-- ---------------------------------------------
-- Purpose: market sizing and ARPC (avg revenue per customer)
WITH line_revenue AS (
  SELECT
    il.invoiceid,
    (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
),
country_rev AS (
  SELECT c.country, c.customerid, SUM(lr.line_total) AS cust_revenue
  FROM customers c
  JOIN invoices i ON i.customerid = c.customerid
  JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
  GROUP BY c.country, c.customerid
)
SELECT
  country,
  COUNT(*)                              AS customers,
  ROUND(SUM(cust_revenue), 2)           AS total_revenue,
  ROUND(AVG(cust_revenue), 2)           AS arpc -- avg revenue per customer
FROM country_rev
GROUP BY country
ORDER BY total_revenue DESC;

-- ---------------------------------------------
-- [3] Recency view: last purchase date per customer
-- ---------------------------------------------
-- Purpose: segmentation by most recent activity
SELECT
  c.customerid,
  c.firstname || ' ' || c.lastname AS customer_name,
  c.country,
  MAX(i.invoicedate)::date AS last_purchase_date
FROM customers c
JOIN invoices i ON i.customerid = c.customerid
GROUP BY c.customerid, customer_name, c.country
ORDER BY last_purchase_date DESC;

-- ---------------------------------------------
-- [4] Revenue by year-month (trend)
-- ---------------------------------------------
-- Purpose: sales trend for seasonality/MoM tracking
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  to_char(date_trunc('month', i.invoicedate), 'YYYY-MM') AS year_month,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM invoices i
JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
GROUP BY 1
ORDER BY 1;

-- ---------------------------------------------
-- [5] MoM growth %
-- ---------------------------------------------
-- Purpose: quantify acceleration/slowdown
WITH monthly AS (
  SELECT
    date_trunc('month', i.invoicedate) AS ym,
    SUM(il.unitprice * il.quantity)    AS revenue
  FROM invoices i
  JOIN invoicelines il ON il.invoiceid = i.invoiceid
  GROUP BY 1
)
SELECT
  to_char(ym, 'YYYY-MM') AS year_month,
  ROUND(revenue, 2) AS revenue,
  ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY ym))
         / NULLIF(LAG(revenue) OVER (ORDER BY ym), 0), 2) AS mom_pct
FROM monthly
ORDER BY ym;

-- ---------------------------------------------
-- [6] Revenue by billing country
-- ---------------------------------------------
-- Purpose: find top markets
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  i.billingcountry AS country,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM invoices i
JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
GROUP BY country
ORDER BY revenue DESC;

-- ---------------------------------------------
-- [7] Top 10 genres by revenue
-- ---------------------------------------------
-- Purpose: content category performance
WITH line_revenue AS (
  SELECT il.invoiceid, il.trackid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  g.name AS genre,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM line_revenue lr
JOIN tracks t   ON t.trackid  = lr.trackid
JOIN genres g   ON g.genreid  = t.genreid
GROUP BY genre
ORDER BY revenue DESC
LIMIT 10;

-- ---------------------------------------------
-- [8] Top 10 artists by revenue
-- ---------------------------------------------
-- Purpose: catalogue value by artist
WITH line_revenue AS (
  SELECT il.invoiceid, il.trackid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  a.name AS artist,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM line_revenue lr
JOIN tracks t  ON t.trackid   = lr.trackid
JOIN albums al ON al.albumid  = t.albumid
JOIN artists a ON a.artistid  = al.artistid
GROUP BY artist
ORDER BY revenue DESC
LIMIT 10;

-- ---------------------------------------------
-- [9] Top 10 albums by revenue
-- ---------------------------------------------
WITH line_revenue AS (
  SELECT il.invoiceid, il.trackid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  al.title AS album,
  a.name   AS artist,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM line_revenue lr
JOIN tracks t  ON t.trackid   = lr.trackid
JOIN albums al ON al.albumid  = t.albumid
JOIN artists a ON a.artistid  = al.artistid
GROUP BY album, artist
ORDER BY revenue DESC
LIMIT 10;

-- ---------------------------------------------
-- [10] Top 20 tracks by revenue
-- ---------------------------------------------
WITH line_revenue AS (
  SELECT
    il.invoicelineid,
    il.invoiceid,
    il.trackid,
    il.quantity,
    (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  t.name  AS track,
  al.title AS album,
  a.name  AS artist,
  ROUND(SUM(lr.line_total), 2) AS revenue,
  SUM(lr.quantity) AS qty
FROM line_revenue lr
JOIN tracks t   ON t.trackid   = lr.trackid
JOIN albums al  ON al.albumid  = t.albumid
JOIN artists a  ON a.artistid  = al.artistid
GROUP BY track, album, artist
ORDER BY revenue DESC
LIMIT 20;

-- ---------------------------------------------
-- [11] Average invoice value by country
-- ---------------------------------------------
-- Purpose: pricing power / basket size per market
SELECT
  billingcountry AS country,
  ROUND(AVG(total), 2) AS avg_invoice_value,
  COUNT(*) AS invoice_count
FROM invoices
GROUP BY country
ORDER BY avg_invoice_value DESC;

-- ---------------------------------------------
-- [12] Employee performance: revenue by support rep
-- ---------------------------------------------
-- Purpose: attribute revenue to employees via assigned customers
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
),
employee_rev AS (
  SELECT
    e.employeeid,
    e.firstname || ' ' || e.lastname AS employee_name,
    SUM(lr.line_total) AS revenue
  FROM employees e
  JOIN customers c ON c.supportrepid = e.employeeid
  JOIN invoices i  ON i.customerid   = c.customerid
  JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
  GROUP BY e.employeeid, employee_name
)
SELECT employeeid, employee_name, ROUND(revenue, 2) AS revenue
FROM employee_rev
ORDER BY revenue DESC;

-- ---------------------------------------------
-- [13] Customers handled per employee
-- ---------------------------------------------
SELECT
  e.employeeid,
  e.firstname || ' ' || e.lastname AS employee_name,
  COUNT(c.customerid) AS customers_supported
FROM employees e
LEFT JOIN customers c ON c.supportrepid = e.employeeid
GROUP BY e.employeeid, employee_name
ORDER BY customers_supported DESC;

-- ---------------------------------------------
-- [14] Genre popularity by country (top 5 per country)
-- ---------------------------------------------
-- Purpose: localized taste profiling
WITH genre_country AS (
  SELECT
    i.billingcountry AS country,
    g.name AS genre,
    SUM(il.quantity) AS qty
  FROM invoices i
  JOIN invoicelines il ON il.invoiceid = i.invoiceid
  JOIN tracks t        ON t.trackid    = il.trackid
  JOIN genres g        ON g.genreid    = t.genreid
  GROUP BY country, genre
),
ranked AS (
  SELECT
    country, genre, qty,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY qty DESC) AS rnk
  FROM genre_country
)
SELECT country, genre, qty
FROM ranked
WHERE rnk <= 5
ORDER BY country, qty DESC;

-- ---------------------------------------------
-- [15] Media Type revenue ranking
-- ---------------------------------------------
WITH line_revenue AS (
  SELECT il.invoiceid, il.trackid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  mt.name AS media_type,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM line_revenue lr
JOIN tracks t      ON t.trackid     = lr.trackid
JOIN media_types mt ON mt.mediatypeid = t.mediatypeid
GROUP BY media_type
ORDER BY revenue DESC;

-- ---------------------------------------------
-- [16] Cross-sell: customers buying many genres
-- ---------------------------------------------
-- Purpose: identify eclectic/upsell-ready customers
SELECT
  c.customerid,
  c.firstname || ' ' || c.lastname AS customer_name,
  COUNT(DISTINCT g.genreid) AS distinct_genres_bought
FROM customers c
JOIN invoices i      ON i.customerid  = c.customerid
JOIN invoicelines il ON il.invoiceid  = i.invoiceid
JOIN tracks t        ON t.trackid     = il.trackid
JOIN genres g        ON g.genreid     = t.genreid
GROUP BY c.customerid, customer_name
ORDER BY distinct_genres_bought DESC, customer_name
LIMIT 20;

-- ---------------------------------------------
-- [17] Repeat purchase rate
-- ---------------------------------------------
-- Purpose: quick retention proxy
WITH orders_per_customer AS (
  SELECT customerid, COUNT(*) AS orders
  FROM invoices
  GROUP BY customerid
)
SELECT
  ROUND(100.0 * SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct,
  SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
  COUNT(*) AS total_customers
FROM orders_per_customer;

-- ---------------------------------------------
-- [18] High-value markets by ARPC (min customer threshold)
-- ---------------------------------------------
-- Purpose: avoid small-sample bias; threshold=5 customers
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
),
cust_country_rev AS (
  SELECT c.country, c.customerid, SUM(lr.line_total) AS revenue
  FROM customers c
  JOIN invoices i  ON i.customerid = c.customerid
  JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
  GROUP BY c.country, c.customerid
),
country_agg AS (
  SELECT country,
         COUNT(*) AS customers,
         AVG(revenue) AS arpc,
         SUM(revenue) AS total_rev
  FROM cust_country_rev
  GROUP BY country
)
SELECT country, customers, ROUND(arpc,2) AS arpc, ROUND(total_rev,2) AS total_revenue
FROM country_agg
WHERE customers >= 5
ORDER BY arpc DESC;

-- ---------------------------------------------
-- [19] First purchase cohort (year) & returns
-- ---------------------------------------------
-- Purpose: basic cohorting by first purchase year
WITH first_order AS (
  SELECT
    c.customerid,
    MIN(i.invoicedate)::date AS first_purchase_date,
    DATE_PART('year', MIN(i.invoicedate))::int AS cohort_year
  FROM customers c
  JOIN invoices i ON i.customerid = c.customerid
  GROUP BY c.customerid
),
orders_per_year AS (
  SELECT
    c.customerid,
    DATE_PART('year', i.invoicedate)::int AS order_year,
    COUNT(*) AS orders_in_year
  FROM customers c
  JOIN invoices i ON i.customerid = c.customerid
  GROUP BY c.customerid, order_year
)
SELECT
  f.cohort_year,
  o.order_year,
  COUNT(DISTINCT o.customerid) AS active_customers
FROM first_order f
JOIN orders_per_year o ON o.customerid = f.customerid
GROUP BY f.cohort_year, o.order_year
ORDER BY f.cohort_year, o.order_year;

-- ---------------------------------------------
-- [20] Playlist coverage of top tracks
-- ---------------------------------------------
-- Purpose: see which playlists already include bestsellers
WITH top_tracks AS (
  SELECT t.trackid, t.name AS track, SUM(il.quantity) AS qty
  FROM invoicelines il
  JOIN tracks t ON t.trackid = il.trackid
  GROUP BY t.trackid, t.name
  ORDER BY qty DESC
  LIMIT 20
)
SELECT
  tt.track,
  COUNT(pt.playlistid) AS playlist_count
FROM top_tracks tt
LEFT JOIN playlisttrack pt ON pt.trackid = tt.trackid
GROUP BY tt.track
ORDER BY playlist_count DESC, tt.track;

-- ---------------------------------------------
-- [21] Track duration stats by genre
-- ---------------------------------------------
-- Purpose: content length norms (milliseconds -> minutes)
SELECT
  g.name AS genre,
  ROUND(AVG(t.milliseconds)/60000.0, 2) AS avg_minutes,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.milliseconds)/60000.0, 2) AS median_minutes,
  ROUND(MAX(t.milliseconds)/60000.0, 2) AS max_minutes
FROM tracks t
JOIN genres g ON g.genreid = t.genreid
GROUP BY genre
ORDER BY avg_minutes DESC;

-- ---------------------------------------------
-- [22] Outlier pricing: top 15 most expensive tracks (catalog price)
-- ---------------------------------------------
SELECT
  t.name AS track,
  a.name AS artist,
  al.title AS album,
  t.unitprice AS catalog_unit_price
FROM tracks t
JOIN albums al ON al.albumid = t.albumid
JOIN artists a ON a.artistid = al.artistid
ORDER BY t.unitprice DESC, track
LIMIT 15;

-- ---------------------------------------------
-- [23] Basket composition: top co-purchased tracks with a given track
-- ---------------------------------------------
-- Purpose: find common pairings for cross-sell (change :track_id)
-- Example param: :track_id = 1
WITH invoices_with_target AS (
  SELECT DISTINCT il.invoiceid
  FROM invoicelines il
  WHERE il.trackid = :track_id
),
co_purchased AS (
  SELECT il.trackid, COUNT(*) AS co_occurrences
  FROM invoicelines il
  JOIN invoices_with_target t ON t.invoiceid = il.invoiceid
  WHERE il.trackid <> :track_id
  GROUP BY il.trackid
)
SELECT
  cp.co_occurrences,
  tr.name AS track,
  ar.name AS artist
FROM co_purchased cp
JOIN tracks tr  ON tr.trackid = cp.trackid
JOIN albums al  ON al.albumid = tr.albumid
JOIN artists ar ON ar.artistid = al.artistid
ORDER BY cp.co_occurrences DESC
LIMIT 20;

-- ---------------------------------------------
-- [24] Sales by employee, by month (support rep attribution)
-- ---------------------------------------------
-- Purpose: performance + seasonality per rep
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  e.firstname || ' ' || e.lastname AS employee,
  to_char(date_trunc('month', i.invoicedate), 'YYYY-MM') AS year_month,
  ROUND(SUM(lr.line_total), 2) AS revenue
FROM employees e
JOIN customers c ON c.supportrepid = e.employeeid
JOIN invoices i  ON i.customerid   = c.customerid
JOIN line_revenue lr ON lr.invoiceid = i.invoiceid
GROUP BY employee, year_month
ORDER BY employee, year_month;

-- ---------------------------------------------
-- [25] Global KPIs at a glance
-- ---------------------------------------------
-- Purpose: quick dashboard numbers
WITH line_revenue AS (
  SELECT il.invoiceid, (il.unitprice * il.quantity) AS line_total
  FROM invoicelines il
)
SELECT
  (SELECT COUNT(*) FROM customers)                 AS customers,
  (SELECT COUNT(*) FROM invoices)                  AS invoices,
  (SELECT ROUND(AVG(total),2) FROM invoices)       AS avg_invoice_value,
  (SELECT ROUND(SUM(lr.line_total),2) FROM line_revenue lr) AS total_revenue;

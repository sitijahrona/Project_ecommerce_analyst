# Langkah 1 — Validasi tabel hasil cleaning
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(order_id IS NULL) AS null_order_id,
  COUNTIF(order_date IS NULL) AS null_order_date,
  COUNTIF(customer_id IS NULL) AS null_customer_id,
  COUNTIF(quantity IS NULL) AS null_quantity,
  COUNTIF(unit_price IS NULL) AS null_unit_price,
  COUNTIF(discount IS NULL) AS null_discount,
  COUNTIF(revenue IS NULL) AS null_revenue
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`;

# Langkah 2 — Validasi perhitungan revenue

SELECT
  order_id,
  quantity,
  unit_price,
  discount,
  revenue,
  ROUND(quantity * unit_price * (1 - discount), 2)
    AS calculated_revenue,
  ROUND(
    revenue - quantity * unit_price * (1 - discount), 2
  ) AS revenue_difference
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
ORDER BY ABS(
  revenue - quantity * unit_price * (1 - discount)
) DESC
LIMIT 10;

# Hitung jumlah transaksi yang berbeda

SELECT
  COUNT(*) AS total_orders,
  COUNTIF(
    ABS(
      revenue - quantity * unit_price * (1 - discount)
    ) > 0.01
  ) AS differences_over_001,
  COUNTIF(
    ABS(
      revenue - quantity * unit_price * (1 - discount)
    ) > 0.001
  ) AS differences_over_0001,
  ROUND(
    AVG(
      ABS(
        revenue - quantity * unit_price * (1 - discount)
      )
    ), 4
  ) AS average_absolute_difference,
  ROUND(
    MAX(
      ABS(
        revenue - quantity * unit_price * (1 - discount)
      )
    ), 4
  ) AS maximum_absolute_difference
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`;

# mulai analisis penjualan

SELECT
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS total_customers,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(revenue), 2) AS average_revenue_per_order,
  ROUND(AVG(customer_rating), 2) AS average_customer_rating,
  ROUND(AVG(delivery_days), 2) AS average_delivery_days
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`;

# hasil analisis
- Rata-rata rating 2,97/5: cukup rendah dibandingkan skor maksimum 5, sehingga layak ditelusuri lebih lanjut berdasarkan kategori produk atau wilayah.
- Rata-rata pengiriman 6,12 hari: bisa menjadi dasar untuk membandingkan kecepatan pengiriman antarwilayah.
- 989 pelanggan menghasilkan 5.000 pesanan: terdapat beberapa pesanan per pelanggan secara keseluruhan, tetapi kita belum bisa menyimpulkan pola pembelian berulang tanpa analisis lebih lanjut.

# analisis tren pendapatan bulanan
SELECT
  FORMAT_DATE('%Y-%m', order_date) AS order_month,
  COUNT(*) AS total_orders,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  order_month
ORDER BY
  order_month;

# bulan dengan pendapatan tertinggi

WITH monthly_sales AS (
  SELECT
    FORMAT_DATE('%Y-%m', order_date) AS order_month,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders
  FROM
    `projectecommerce-512914.project_ecommerce.ecommerce_clean`
  GROUP BY
    order_month
)
SELECT
  order_month,
  total_orders,
  ROUND(total_revenue, 2) AS total_revenue
FROM monthly_sales
ORDER BY total_revenue DESC
LIMIT 10;

# bulan dengan pendapatan terendah

WITH monthly_sales AS (
  SELECT
    FORMAT_DATE('%Y-%m', order_date) AS order_month,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders
  FROM
    `projectecommerce-512914.project_ecommerce.ecommerce_clean`
  GROUP BY
    order_month
)
SELECT
  order_month,
  total_orders,
  ROUND(total_revenue, 2) AS total_revenue
FROM monthly_sales
ORDER BY total_revenue ASC
LIMIT 10;

# analisis kategori produk

SELECT
  product_category,
  COUNT(*) AS total_orders,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(revenue), 2) AS average_revenue_per_order,
  ROUND(AVG(customer_rating), 2) AS average_rating
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  product_category
ORDER BY
  total_revenue DESC;

# Insight penting
- Electronics merupakan kontributor revenue terbesar, sekitar 35,8% dari total revenue.
- Electronics juga mencatat jumlah pesanan dan unit terjual terbanyak.
- Beauty memiliki rata-rata revenue per pesanan tertinggi, yaitu 1.059,28, walaupun total revenue-nya paling rendah.
- Rata-rata rating semua kategori relatif mirip, yaitu 2,94–3,01. Belum terlihat perbedaan rating yang besar antarkategori.

# analisis wilayah penjualan

SELECT
  region,
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(revenue), 2) AS average_revenue_per_order,
  ROUND(AVG(customer_rating), 2) AS average_rating,
  ROUND(AVG(delivery_days), 2) AS average_delivery_days
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  region
ORDER BY
  total_revenue DESC;

# Insight yang bisa kamu tulis
- West menjadi kontributor revenue terbesar, sekitar 26,3% dari total pendapatan.
- North memiliki jumlah pelanggan unik terbanyak, yaitu 709, sedikit lebih tinggi dibandingkan West yang memiliki 708 pelanggan unik.
- South memiliki rata-rata waktu pengiriman tertinggi, yaitu 6,17 hari, sedangkan West paling rendah, yaitu 6,08 hari.
- Rating rata-rata semua wilayah hampir sama, berkisar antara 2,96–2,99.

# analisis metode pembayaran

SELECT
  payment_method,
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(revenue), 2) AS average_revenue_per_order,
  ROUND(AVG(customer_rating), 2) AS average_rating
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  payment_method
ORDER BY
  total_revenue DESC;

# Insight yang bisa diambil
- Card menghasilkan revenue terbesar, sekitar 46,3% dari total revenue.
- Card juga memiliki jumlah pesanan dan unit terjual terbanyak.
- COD berada di posisi kedua, sedangkan Wallet memiliki jumlah pesanan terendah.
- Card mencatat rating rata-rata 3,02, sedikit lebih tinggi daripada COD (2,94) dan Wallet (2,93).

# analisis rating pelanggan

SELECT
  CASE
    WHEN customer_rating < 2 THEN '1. Rating < 2'
    WHEN customer_rating < 3 THEN '2. Rating 2–<3'
    WHEN customer_rating < 4 THEN '3. Rating 3–<4'
    ELSE '4. Rating 4–5'
  END AS rating_group,
  COUNT(*) AS total_orders,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (), 2
  ) AS percentage,
  ROUND(AVG(delivery_days), 2) AS average_delivery_days,
  ROUND(AVG(revenue), 2) AS average_revenue
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  rating_group
ORDER BY
  rating_group;

# insight 
1. Pesanan dengan rating 4–5 memiliki rata-rata pendapatan tertinggi. Rata-rata pendapatannya sebesar 1.042,51 per pesanan, lebih tinggi dibandingkan kelompok rating lainnya.
2. Rating tinggi memiliki rata-rata pengiriman sedikit lebih cepat. Kelompok rating 4–5 memiliki rata-rata pengiriman 6,04 hari, sedangkan kelompok rating 2–
3. Distribusi jumlah pesanan di setiap kelompok relatif merata. Setiap kelompok mencakup sekitar 24–25% dari total pesanan. Artinya, tidak ada satu kelompok rating yang mendominasi jumlah pesanan.

# analisis diskon terhadap pendapatan.
SELECT
  CASE
    WHEN discount = 0 THEN '1. No Discount'
    WHEN discount <= 0.10 THEN '2. Discount 0–10%'
    WHEN discount <= 0.20 THEN '3. Discount 10–20%'
    ELSE '4. Discount >20%'
  END AS discount_group,
  COUNT(*) AS total_orders,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
  ) AS percentage,
  ROUND(AVG(discount) * 100, 2) AS average_discount_pct,
  ROUND(AVG(revenue), 2) AS average_revenue,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM
  `projectecommerce-512914.project_ecommerce.ecommerce_clean`
GROUP BY
  discount_group
ORDER BY
  discount_group;

# Insight utama
1. Rata-rata pendapatan menurun seiring meningkatnya diskon. Rata-rata pendapatan per pesanan turun dari 1.201,28 pada pesanan tanpa diskon menjadi 911,36 pada kelompok diskon di atas 20%. Ini merupakan pola deskriptif; kita belum bisa memastikan bahwa diskon adalah satu-satunya penyebabnya.
2. Pesanan dengan diskon di atas 20% mendominasi jumlah transaksi. Kelompok ini mencakup 43,96% dari seluruh pesanan, dengan total pendapatan 2.003.173,81. Artinya, kelompok diskon tinggi berkontribusi besar terhadap pendapatan total karena jumlah pesanannya banyak.
3. Pesanan tanpa diskon memiliki rata-rata pendapatan tertinggi, tetapi jumlahnya sedikit. Hanya ada 68 pesanan (1,36%) tanpa diskon. Karena kelompoknya kecil, kita tidak bisa langsung menyimpulkan bahwa menghilangkan diskon akan meningkatkan pendapatan secara keseluruhan.
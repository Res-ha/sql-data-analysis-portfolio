/*
 * PROJECT DATA ANALYSIS FOR B2B RETAIL: CUSTOMER ANALYTICS REPORT
 * Author : Resha Ananda Rahman
 * Context: Proyek pembelajaran DQLab - analisis penjualan dan customer xyz.com.
 * Dialect : MySQL / MariaDB
 *
 * CARA MENGGUNAKAN
 * Pilih database yang memiliki tabel orders_1, orders_2, dan customer.
 * Jalankan setiap query secara terpisah sesuai bagian analisis. File ini
 * hanya membaca data dan tidak mengubah isi tabel.
 *
 * CAKUPAN PERAPIAN
 * Kapitalisasi keyword, indentasi empat spasi, alias tabel, komentar,
 * penomoran analisis, dan titik koma diseragamkan. Logika query asli
 * dipertahankan; satu blok duplikat identik dihapus.
 *
 * DAFTAR ANALISIS
 * 00. Data preview
 * 01. Total penjualan dan revenue Quarter 1
 * 02. Total penjualan dan revenue Quarter 2
 * 03. Perbandingan penjualan dan revenue per quarter
 * 04. Customer terdaftar per quarter
 * 05. Customer terdaftar yang sudah bertransaksi
 * 06. Kategori produk terlaris pada Quarter 2
 * 07. Customer unik yang bertransaksi pada Quarter 1
 * 08. Retention customer dari Quarter 1 ke Quarter 2
 */

-- ============================================================================
-- 00. DATA PREVIEW
-- ============================================================================
-- orders_1: transaksi Quarter 1 (Januari-Maret 2004).
-- orders_2: transaksi Quarter 2 (April-Juni 2004).
-- customer: profil customer yang terdaftar di xyz.com.

SELECT *
FROM orders_1
LIMIT 5;

SELECT *
FROM orders_2
LIMIT 5;

SELECT *
FROM customer
LIMIT 5;

-- ============================================================================
-- 01. TOTAL PENJUALAN DAN REVENUE QUARTER 1
-- ============================================================================
-- Tujuan: Menghitung total unit terjual dan revenue transaksi berstatus
-- Shipped selama Quarter 1.

SELECT
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceEach) AS revenue
FROM orders_1
WHERE status = 'Shipped';

-- ============================================================================
-- 02. TOTAL PENJUALAN DAN REVENUE QUARTER 2
-- ============================================================================
-- Tujuan: Menghitung total unit terjual dan revenue transaksi berstatus
-- Shipped selama Quarter 2.

SELECT
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceEach) AS revenue
FROM orders_2
WHERE status = 'Shipped';

-- ============================================================================
-- 03. PERBANDINGAN PENJUALAN DAN REVENUE PER QUARTER
-- ============================================================================

SELECT
    quarter,
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceEach) AS revenue
FROM (
    SELECT
        orderNumber,
        status,
        quantity,
        priceEach,
        1 AS quarter
    FROM orders_1

    UNION ALL

    SELECT
        orderNumber,
        status,
        quantity,
        priceEach,
        2 AS quarter
    FROM orders_2
) AS tabel_a
WHERE status = 'Shipped'
GROUP BY quarter
ORDER BY quarter ASC;

-- ============================================================================
-- 04. CUSTOMER TERDAFTAR PER QUARTER
-- ============================================================================

SELECT
    quarter,
    COUNT(DISTINCT customerID) AS total_customers
FROM (
    SELECT
        customerID,
        createDate,
        QUARTER(createDate) AS quarter
    FROM customer
    WHERE createDate >= '2004-01-01'
      AND createDate < '2004-07-01'
) AS tabel_b
GROUP BY quarter
ORDER BY quarter ASC;

-- ============================================================================
-- 05. CUSTOMER TERDAFTAR YANG SUDAH BERTRANSAKSI
-- ============================================================================

SELECT
    quarter,
    COUNT(DISTINCT customerID) AS total_customers
FROM (
    SELECT
        customerID,
        createDate,
        QUARTER(createDate) AS quarter
    FROM customer
    WHERE createDate >= '2004-01-01'
      AND createDate < '2004-07-01'
) AS tabel_b
WHERE customerID IN (
    SELECT customerID
    FROM orders_1

    UNION

    SELECT customerID
    FROM orders_2
)
GROUP BY quarter
ORDER BY quarter ASC;

-- ============================================================================
-- 06. KATEGORI PRODUK TERLARIS PADA QUARTER 2
-- ============================================================================

SELECT
    a.categoryID,
    a.total_order,
    a.total_penjualan
FROM (
    SELECT
        tabel_c.categoryID,
        COUNT(DISTINCT tabel_c.orderNumber) AS total_order,
        SUM(tabel_c.quantity) AS total_penjualan
    FROM (
        SELECT
            productCode,
            orderNumber,
            quantity,
            status,
            LEFT(productCode, 3) AS categoryID
        FROM orders_2
        WHERE status = 'Shipped'
    ) AS tabel_c
    GROUP BY tabel_c.categoryID
) AS a
ORDER BY
    a.total_order DESC,
    a.total_penjualan DESC;

-- ============================================================================
-- 07. CUSTOMER UNIK YANG BERTRANSAKSI PADA QUARTER 1
-- ============================================================================

SELECT
    COUNT(DISTINCT customerID) AS total_customers
FROM orders_1;

-- ============================================================================
-- 08. RETENTION CUSTOMER DARI QUARTER 1 KE QUARTER 2
-- ============================================================================

SELECT
    1 AS quarter,
    COUNT(DISTINCT customerID)
    / (
        SELECT COUNT(DISTINCT customerID)
        FROM orders_1
    ) * 100 AS Q2
FROM orders_1
WHERE customerID IN (
    SELECT DISTINCT customerID
    FROM orders_2
);

/*
 * PROJECT DATA ANALYSIS FOR RETAIL: SALES PERFORMANCE REPORT
 * Author : Resha Ananda Rahman
 * Context: Proyek pembelajaran DQLab - analisis performa DQLab Store.
 *
 * CARA MENGGUNAKAN
 * Pilih database yang memiliki tabel dqlab_sales_store, kemudian jalankan
 * setiap query secara terpisah sesuai bagian analisis yang dibutuhkan.
 * File ini hanya membaca data dan tidak mengubah isi tabel.
 *
 * CAKUPAN DOKUMENTASI
 * Struktur judul, komentar, penomoran bagian, dan pemisah query diseragamkan
 * agar mudah dibaca di GitHub. Sintaks SQL dan logika query dipertahankan
 * sesuai file sumber terbaru.
 *
 * DAFTAR ANALISIS
 * 0.  Data preview
 * 1A. Overall performance berdasarkan tahun
 * 1B. Overall performance berdasarkan product sub-category
 * 2A. Efektivitas dan efisiensi promosi berdasarkan tahun
 * 2B. Efektivitas dan efisiensi promosi berdasarkan product sub-category
 * 3A. Jumlah customer yang bertransaksi setiap tahun
 */

-- ============================================================================
-- 0. DATA PREVIEW
-- ============================================================================
-- Menampilkan isi table dqlab_sales_store

SELECT * FROM dqlab_sales_store;

-- ============================================================================
-- 1A. OVERALL PERFORMANCE BERDASARKAN TAHUN
-- ============================================================================
-- Tujuan: Menghitung total sales dan jumlah order unik pada 2009-2012.
-- COUNT(DISTINCT order_id) mencegah satu order dihitung lebih dari sekali.

SELECT
    EXTRACT(YEAR FROM order_date) AS years,
    SUM(sales) AS sales,
    COUNT(DISTINCT order_id) AS number_of_order
FROM dqlab_sales_store
WHERE order_status = 'Order Finished'
  AND order_date >= '2009-01-01'
  AND order_date < '2013-01-01'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years ASC;

-- ============================================================================
-- 1B. OVERALL PERFORMANCE BERDASARKAN PRODUCT SUB-CATEGORY
-- ============================================================================
-- Tujuan: Membandingkan total sales setiap sub-category pada 2011 dan 2012.
-- Hasil diurutkan dari sales terbesar untuk setiap tahun.

SELECT
    EXTRACT(YEAR FROM order_date) AS years,
    product_sub_category,
    SUM(sales) AS sales
FROM dqlab_sales_store
WHERE order_status = 'Order Finished'
  AND EXTRACT(YEAR FROM order_date) IN (2011, 2012)
GROUP BY
    EXTRACT(YEAR FROM order_date),
    product_sub_category
ORDER BY
    years ASC,
    sales DESC;

-- ============================================================================
-- 2A. EFEKTIVITAS DAN EFISIENSI PROMOSI BERDASARKAN TAHUN
-- ============================================================================
-- Tujuan: Menghitung sales, promotion value, dan burn rate per tahun.
-- Formula: burn rate = promotion_value / sales * 100.
-- Target DQLab Store: burn rate maksimum 4,5%.

SELECT
    EXTRACT(YEAR FROM order_date) AS years,
    SUM(sales) AS sales,
    SUM(discount_value) AS promotion_value,
    ROUND(
        (SUM(discount_value) / NULLIF(SUM(sales), 0)) * 100,
        2
    ) AS burn_rate_percentage
FROM dqlab_sales_store
WHERE order_status = 'Order Finished'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years ASC;

-- ============================================================================
-- 2B. EFEKTIVITAS DAN EFISIENSI PROMOSI BERDASARKAN PRODUCT SUB-CATEGORY
-- ============================================================================
-- Tujuan: Mengukur burn rate tiap product sub-category pada tahun 2012.
-- Output lengkap tidak memakai LIMIT; laporan hanya menyoroti 5 teratas.

SELECT
    EXTRACT(YEAR FROM order_date) AS years,
    product_sub_category,
    product_category,
    SUM(sales) AS sales,
    SUM(discount_value) AS promotion_value,
    ROUND(
        (SUM(discount_value) / NULLIF(SUM(sales), 0)) * 100,
        2
    ) AS burn_rate_percentage
FROM dqlab_sales_store
WHERE order_status = 'Order Finished'
  AND EXTRACT(YEAR FROM order_date) = 2012
GROUP BY
    EXTRACT(YEAR FROM order_date),
    product_sub_category,
    product_category
ORDER BY sales DESC;

-- ============================================================================
-- 3A. JUMLAH CUSTOMER YANG BERTRANSAKSI SETIAP TAHUN
-- ============================================================================
-- Tujuan: Menghitung customer unik yang memiliki order selesai per tahun.
-- Seorang customer hanya dihitung sekali pada tahun yang sama.

SELECT
    EXTRACT(YEAR FROM order_date) AS years,
    COUNT(DISTINCT customer) AS number_of_customer
FROM dqlab_sales_store
WHERE order_status = 'Order Finished'
  AND EXTRACT(YEAR FROM order_date) BETWEEN 2009 AND 2012
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years ASC;

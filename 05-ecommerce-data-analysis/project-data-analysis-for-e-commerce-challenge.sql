/*
 * PROJECT DATA ANALYSIS FOR E-COMMERCE CHALLENGE
 * Author : Resha Ananda Rahman
 * Context: Proyek pembelajaran DQLab - analisis data transaksi e-commerce.
 * Dialect : MySQL / MariaDB
 *
 * CARA MENGGUNAKAN
 * Impor file CSV ke database menggunakan nama tabel berikut:
 *   1. users.csv         -> users
 *   2. products.csv      -> products
 *   3. orders.csv        -> orders
 *   4. order_details.csv -> order_details
 *
 * Setelah seluruh tabel tersedia, jalankan setiap query secara terpisah
 * sesuai bagian analisis yang dibutuhkan. File ini hanya membaca data dan
 * tidak mengubah isi tabel.
 *
 * CATATAN DATA
 * Nilai "NA" pada kolom paid_at dan delivery_at perlu dikonversi menjadi
 * NULL saat proses impor CSV agar filter IS NULL dan IS NOT NULL bekerja.
 *
 * CAKUPAN ANALISIS
 * - Products dan Orders
 * - Transaksi Bulanan dan Status Transaksi
 * - Pengguna Bertransaksi
 * - Top Buyer, Frequent Buyer, dan Big Frequent Buyer
 * - Domain Email Penjual dan Produk Terlaris
 * - Analisis Transaksi Tahun 2019-2020
 * - High Value Buyer, Dropshipper, dan Reseller Offline
 * - Pembeli Sekaligus Penjual
 * - Lama Transaksi Dibayar
 */

-- ============================================================================
-- PRODUCTS
-- ============================================================================

-- Menampilkan lima data pertama dari tabel products.

SELECT *
FROM products
LIMIT 5;

-- Menampilkan jumlah baris pada tabel products.

SELECT
    COUNT(*) AS total_baris
FROM products;

-- Menampilkan jumlah kategori produk yang berbeda.

SELECT
    COUNT(DISTINCT category) AS jumlah_kategori
FROM products;

-- ============================================================================
-- ORDERS
-- ============================================================================

-- Menampilkan lima data pertama dari tabel orders.

SELECT *
FROM orders
LIMIT 5;

-- Menampilkan jumlah transaksi pada tabel orders.

SELECT
    COUNT(order_id) AS jumlah_transaksi
FROM orders;

-- ============================================================================
-- TRANSAKSI BULANAN
-- ============================================================================
-- Tujuan: Menghitung jumlah transaksi untuk setiap bulan.

SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS bulan,
    COUNT(1) AS jumlah_transaksi
FROM orders
GROUP BY 1
ORDER BY 1;

-- ============================================================================
-- STATUS TRANSAKSI
-- ============================================================================

-- Menampilkan jumlah transaksi yang belum dibayar.

SELECT
    COUNT(1) AS jumlah_transaksi
FROM orders
WHERE paid_at IS NULL;

-- Menampilkan jumlah transaksi yang sudah dibayar tetapi belum dikirim.

SELECT
    COUNT(1) AS jumlah_transaksi
FROM orders
WHERE paid_at IS NOT NULL
  AND delivery_at IS NULL;

-- Menampilkan jumlah transaksi yang belum dikirim, baik sudah dibayar
-- maupun belum dibayar.

SELECT
    COUNT(1) AS jumlah_transaksi
FROM orders
WHERE delivery_at IS NULL;

-- Menampilkan transaksi yang dikirim pada hari yang sama dengan pembayaran.

SELECT
    COUNT(1) AS jumlah_transaksi
FROM orders
WHERE paid_at = delivery_at;

-- ============================================================================
-- PENGGUNA BERTRANSAKSI
-- ============================================================================

-- Menampilkan total pengguna.

SELECT
    COUNT(DISTINCT user_id) AS total_users
FROM users;

-- Menampilkan total pengguna yang pernah menjadi pembeli.

SELECT
    COUNT(DISTINCT buyer_id) AS total_buyer
FROM orders;

-- Menampilkan total pengguna yang pernah menjadi penjual.

SELECT
    COUNT(DISTINCT seller_id) AS total_seller
FROM orders;

-- Menampilkan total pengguna yang pernah menjadi pembeli sekaligus penjual.

SELECT
    COUNT(DISTINCT buyer_id) AS total_buyer_seller
FROM orders
WHERE buyer_id IN (
    SELECT seller_id
    FROM orders
);

-- Menampilkan total pengguna yang tidak pernah menjadi pembeli maupun penjual.

SELECT
    COUNT(DISTINCT user_id) AS total_users
FROM users
WHERE user_id NOT IN (
    SELECT buyer_id
    FROM orders

    UNION

    SELECT seller_id
    FROM orders
);

-- ============================================================================
-- TOP BUYER ALL TIME
-- ============================================================================
-- Tujuan: Menampilkan lima pembeli dengan nilai transaksi terbesar.

SELECT
    a.buyer_id,
    b.nama_user,
    SUM(a.total) AS total_transaksi
FROM orders AS a
INNER JOIN users AS b
    ON a.buyer_id = b.user_id
GROUP BY
    a.buyer_id,
    b.nama_user
ORDER BY total_transaksi DESC
LIMIT 5;

-- ============================================================================
-- FREQUENT BUYER
-- ============================================================================
-- Tujuan: Menampilkan lima pembeli dengan jumlah transaksi tanpa diskon
-- terbanyak.

SELECT
    a.buyer_id,
    b.nama_user,
    COUNT(a.order_id) AS jumlah_transaksi
FROM orders AS a
INNER JOIN users AS b
    ON a.buyer_id = b.user_id
WHERE a.discount = 0
GROUP BY
    a.buyer_id,
    b.nama_user
ORDER BY
    jumlah_transaksi DESC,
    a.buyer_id ASC
LIMIT 5;

-- ============================================================================
-- BIG FREQUENT BUYER 2020
-- ============================================================================
-- Tujuan: Menampilkan pembeli dengan rata-rata nilai transaksi di atas
-- Rp1.000.000 dan aktif bertransaksi minimal pada lima bulan selama 2020.

SELECT
    trx.buyer_id,
    users.email,
    trx.average,
    months.month_count
FROM (
    SELECT
        buyer_id,
        ROUND(AVG(total), 2) AS average
    FROM orders
    WHERE EXTRACT(YEAR FROM created_at) = 2020
    GROUP BY buyer_id
    HAVING AVG(total) > 1000000
) AS trx
INNER JOIN (
    SELECT
        buyer_id,
        COUNT(order_id) AS jumlah_order,
        COUNT(DISTINCT DATE_FORMAT(created_at, '%Y-%m')) AS month_count
    FROM orders
    WHERE EXTRACT(YEAR FROM created_at) = 2020
    GROUP BY buyer_id
    HAVING COUNT(DISTINCT DATE_FORMAT(created_at, '%Y-%m')) >= 5
       AND COUNT(order_id) >= COUNT(
            DISTINCT DATE_FORMAT(created_at, '%Y-%m')
       )
) AS months
    ON trx.buyer_id = months.buyer_id
INNER JOIN users
    ON trx.buyer_id = users.user_id
ORDER BY
    trx.average DESC,
    months.month_count DESC;

-- ============================================================================
-- DOMAIN EMAIL DARI PENJUAL
-- ============================================================================
-- Tujuan: Menghitung jumlah penjual berdasarkan domain email.

SELECT
    SUBSTR(email, INSTR(email, '@') + 1) AS domain_email,
    COUNT(user_id) AS jumlah_pengguna_seller
FROM users
WHERE user_id IN (
    SELECT seller_id
    FROM orders
)
GROUP BY 1
ORDER BY domain_email ASC;

-- ============================================================================
-- TOP 5 PRODUCT DESEMBER 2019
-- ============================================================================
-- Tujuan: Menampilkan lima produk dengan jumlah penjualan terbanyak selama
-- Desember 2019.

SELECT
    SUM(a.quantity) AS total_qty,
    b.desc_product
FROM order_details AS a
INNER JOIN products AS b
    ON a.product_id = b.product_id
INNER JOIN orders AS c
    ON a.order_id = c.order_id
WHERE c.created_at >= '2019-12-01'
  AND c.created_at < '2020-01-01'
GROUP BY 2
ORDER BY 1 DESC
LIMIT 5;

-- ============================================================================
-- 10 TRANSAKSI TERBESAR USER 12476
-- ============================================================================

SELECT
    seller_id,
    buyer_id,
    total AS nilai_transaksi,
    created_at AS tanggal_transaksi
FROM orders
WHERE buyer_id = 12476
ORDER BY 3 DESC
LIMIT 10;

-- ============================================================================
-- TRANSAKSI PER BULAN TAHUN 2020
-- ============================================================================
-- Tujuan: Menampilkan jumlah dan total nilai transaksi setiap bulan pada 2020.

SELECT
    EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan,
    COUNT(1) AS jumlah_transaksi,
    SUM(total) AS total_nilai_transaksi
FROM orders
WHERE created_at >= '2020-01-01'
  AND created_at < '2021-01-01'
GROUP BY 1
ORDER BY 1;

-- ============================================================================
-- PENGGUNA DENGAN RATA-RATA TRANSAKSI TERBESAR DI JANUARI 2020
-- ============================================================================
-- Tujuan: Menampilkan sepuluh pembeli dengan rata-rata transaksi terbesar
-- yang bertransaksi minimal dua kali selama Januari 2020.

SELECT
    buyer_id,
    COUNT(1) AS jumlah_transaksi,
    AVG(total) AS avg_nilai_transaksi
FROM orders
WHERE created_at >= '2020-01-01'
  AND created_at < '2020-02-01'
GROUP BY 1
HAVING COUNT(1) >= 2
ORDER BY 3 DESC
LIMIT 10;

-- ============================================================================
-- TRANSAKSI BESAR DI DESEMBER 2019
-- ============================================================================
-- Tujuan: Menampilkan transaksi minimal Rp20.000.000 selama Desember 2019.

SELECT
    users.nama_user AS nama_pembeli,
    orders.total AS nilai_transaksi,
    orders.created_at AS tanggal_transaksi
FROM orders
INNER JOIN users
    ON orders.buyer_id = users.user_id
WHERE orders.created_at >= '2019-12-01'
  AND orders.created_at < '2020-01-01'
  AND orders.total >= 20000000
ORDER BY 1;

-- ============================================================================
-- KATEGORI PRODUK TERLARIS DI 2020
-- ============================================================================
-- Tujuan: Menampilkan lima kategori dengan total quantity terbanyak untuk
-- transaksi tahun 2020 yang sudah dikirim kepada pembeli.

SELECT
    products.category,
    SUM(order_details.quantity) AS total_quantity,
    SUM(order_details.quantity * order_details.price) AS total_price
FROM orders
INNER JOIN order_details
    USING (order_id)
INNER JOIN products
    USING (product_id)
WHERE orders.created_at >= '2020-01-01'
  AND orders.created_at < '2021-01-01'
  AND orders.delivery_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- ============================================================================
-- MENCARI PEMBELI HIGH VALUE
-- ============================================================================
-- Tujuan: Menampilkan pembeli yang bertransaksi lebih dari lima kali dan
-- setiap transaksinya bernilai lebih dari Rp2.000.000.

SELECT
    users.nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    SUM(orders.total) AS total_nilai_transaksi,
    MIN(orders.total) AS min_nilai_transaksi
FROM orders
INNER JOIN users
    ON orders.buyer_id = users.user_id
GROUP BY
    users.user_id,
    users.nama_user
HAVING COUNT(1) > 5
   AND MIN(orders.total) > 2000000
ORDER BY 3 DESC;

-- ============================================================================
-- MENCARI DROPSHIPPER
-- ============================================================================
-- Tujuan: Menampilkan pembeli dengan minimal sepuluh transaksi yang selalu
-- menggunakan kode pos pengiriman berbeda pada setiap transaksi.

SELECT
    users.nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    COUNT(DISTINCT orders.kodepos) AS distinct_kodepos,
    SUM(orders.total) AS total_nilai_transaksi,
    AVG(orders.total) AS avg_nilai_transaksi
FROM orders
INNER JOIN users
    ON orders.buyer_id = users.user_id
GROUP BY
    users.user_id,
    users.nama_user
HAVING COUNT(1) >= 10
   AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC;

-- ============================================================================
-- MENCARI RESELLER OFFLINE
-- ============================================================================
-- Tujuan: Menampilkan pembeli dengan minimal delapan transaksi, menggunakan
-- alamat utama, dan memiliki rata-rata quantity lebih dari sepuluh per order.

SELECT
    users.nama_user AS nama_pembeli,
    COUNT(1) AS jumlah_transaksi,
    SUM(orders.total) AS total_nilai_transaksi,
    AVG(orders.total) AS avg_nilai_transaksi,
    AVG(summary_order.total_quantity) AS avg_quantity_per_transaksi
FROM orders
INNER JOIN users
    ON orders.buyer_id = users.user_id
INNER JOIN (
    SELECT
        order_id,
        SUM(quantity) AS total_quantity
    FROM order_details
    GROUP BY 1
) AS summary_order
    USING (order_id)
WHERE orders.kodepos = users.kodepos
GROUP BY
    users.user_id,
    users.nama_user
HAVING COUNT(1) >= 8
   AND AVG(summary_order.total_quantity) > 10
ORDER BY 3 DESC;

-- ============================================================================
-- PEMBELI SEKALIGUS PENJUAL
-- ============================================================================
-- Tujuan: Menampilkan penjual yang juga pernah bertransaksi sebagai pembeli
-- minimal tujuh kali.

SELECT
    users.nama_user AS nama_pengguna,
    buyer.jumlah_transaksi_beli,
    seller.jumlah_transaksi_jual
FROM users
INNER JOIN (
    SELECT
        buyer_id,
        COUNT(1) AS jumlah_transaksi_beli
    FROM orders
    GROUP BY 1
) AS buyer
    ON buyer.buyer_id = users.user_id
INNER JOIN (
    SELECT
        seller_id,
        COUNT(1) AS jumlah_transaksi_jual
    FROM orders
    GROUP BY 1
) AS seller
    ON seller.seller_id = users.user_id
WHERE buyer.jumlah_transaksi_beli >= 7
ORDER BY 1;

-- ============================================================================
-- LAMA TRANSAKSI DIBAYAR
-- ============================================================================
-- Tujuan: Menghitung lama waktu pembayaran sejak transaksi dibuat,
-- dikelompokkan berdasarkan bulan.

SELECT
    EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan,
    COUNT(1) AS jumlah_transaksi,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar,
    MIN(DATEDIFF(paid_at, created_at)) AS min_lama_dibayar,
    MAX(DATEDIFF(paid_at, created_at)) AS max_lama_dibayar
FROM orders
WHERE paid_at IS NOT NULL
GROUP BY 1
ORDER BY 1;

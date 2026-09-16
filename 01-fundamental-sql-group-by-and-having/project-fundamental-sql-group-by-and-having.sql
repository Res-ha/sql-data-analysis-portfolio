/*
 * PROJECT FUNDAMENTAL SQL GROUP BY AND HAVING
 * Author : Resha Ananda Rahman
 * Context: Proyek pembelajaran DQLab - penggunaan GROUP BY dan HAVING.
 * Dialect : MySQL / MariaDB
 *
 * CARA MENGGUNAKAN
 * Pilih database latihan yang memiliki tabel customer, subscription,
 * product, dan invoice. Jalankan setiap query secara terpisah sesuai
 * bagian analisis yang dibutuhkan. File ini hanya membaca data.
 *
 * CAKUPAN PERAPIAN
 * Kapitalisasi keyword, indentasi empat spasi, alias tabel, komentar,
 * penomoran latihan, dan titik koma diseragamkan. Logika query asli
 * dipertahankan.
 *
 * DAFTAR LATIHAN
 * 01. Customer dengan total penalty lebih dari 20.000
 * 02. Customer yang mengganti layanan
 */

-- ============================================================================
-- 01. CUSTOMER DENGAN TOTAL PENALTY LEBIH DARI 20.000
-- ============================================================================
-- Tujuan: Menampilkan customer dan total penalty yang melebihi 20.000.

SELECT
    customer_id,
    SUM(pinalty) AS total_pinalty
FROM invoice
GROUP BY customer_id
HAVING SUM(pinalty) > 20000;

-- ============================================================================
-- 02. CUSTOMER YANG MENGGANTI LAYANAN
-- ============================================================================
-- Tujuan: Menampilkan customer dengan lebih dari satu subscription dan
-- menggabungkan seluruh nama produk yang pernah digunakan.

SELECT
    t1.Name AS name,
    GROUP_CONCAT(t3.product_name) AS product_name
FROM customer AS t1
INNER JOIN subscription AS t2
    ON t1.id = t2.customer_id
INNER JOIN product AS t3
    ON t2.product_id = t3.ID
WHERE t1.id IN (
    SELECT customer_id
    FROM subscription
    GROUP BY customer_id
    HAVING COUNT(customer_id) > 1
)
GROUP BY t1.Name;

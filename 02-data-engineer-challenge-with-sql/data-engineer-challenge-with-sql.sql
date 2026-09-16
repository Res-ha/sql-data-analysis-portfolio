/*
 * DATA ENGINEER CHALLENGE WITH SQL
 * Author : Resha Ananda Rahman
 * Context: Proyek pembelajaran DQLab - analisis penjualan DQLab Mart.
 *
 * CARA MENGGUNAKAN
 * Pilih database latihan yang berisi empat tabel berikut, lalu jalankan
 * setiap query secara terpisah untuk membaca hasil masing-masing latihan:
 * ms_produk, ms_pelanggan, tr_penjualan, tr_penjualan_detail.
 * File ini tidak menyertakan skema maupun dataset dan tidak mengubah data.
 * Sintaks sumber berorientasi MySQL; eksekusi ulang belum diverifikasi.
 *
 * CAKUPAN PERAPIAN
 * Kapitalisasi keyword, indentasi empat spasi, alias tabel, penomoran soal,
 * komentar, dan titik koma diseragamkan. Logika query asli dipertahankan.
 * REVIEW menandai keterbatasan yang perlu diperbaiki sebelum dianggap final.
 *
 * DAFTAR LATIHAN
 * 01. Produk dengan rentang harga tertentu
 * 02. Produk Flashdisk
 * 03. Pelanggan bergelar
 * 04. Mengurutkan nama pelanggan
 * 05. Mengurutkan nama tanpa gelar
 * 06. Nama pelanggan terpanjang
 * 07. Nama pelanggan terpanjang dan terpendek
 * 08. Produk dengan kuantitas penjualan tertinggi
 * 09. Pelanggan dengan nilai belanja tertinggi
 * 10. Pelanggan yang belum bertransaksi
 * 11. Transaksi dengan lebih dari satu baris detail
 */

-- ============================================================================
-- 01. PRODUK DENGAN RENTANG HARGA TERTENTU
-- ============================================================================
-- Tujuan: Menampilkan produk seharga 50.000 sampai 150.000, termasuk batasnya.

SELECT
    no_urut,
    kode_produk,
    nama_produk,
    harga
FROM ms_produk
WHERE harga BETWEEN 50000 AND 150000;

-- ============================================================================
-- 02. PRODUK FLASHDISK
-- ============================================================================
-- Tujuan soal: Menampilkan produk yang mengandung kata Flashdisk.
-- REVIEW: Pola asli hanya mencari awalan Flashdisk. Untuk posisi mana pun,
-- gunakan '%Flashdisk%'. Pola asli di bawah dipertahankan.

SELECT
    no_urut,
    kode_produk,
    nama_produk,
    harga
FROM ms_produk
WHERE nama_produk LIKE 'Flashdisk%';

-- ============================================================================
-- 03. PELANGGAN BERGELAR
-- ============================================================================
-- Tujuan: Menampilkan pelanggan bergelar S.H., Ir., atau Drs.
-- Asumsi pola asli: Ir. di awal, Drs. di akhir, dan S.H. di posisi mana pun.
-- REVIEW: Variasi tanda titik dan spasi dapat memerlukan pola tambahan.

SELECT
    no_urut,
    kode_pelanggan,
    nama_pelanggan,
    alamat
FROM ms_pelanggan
WHERE nama_pelanggan LIKE '%S.H.%'
   OR nama_pelanggan LIKE 'Ir.%'
   OR nama_pelanggan LIKE '%Drs.';

-- ============================================================================
-- 04. MENGURUTKAN NAMA PELANGGAN
-- ============================================================================
-- Tujuan: Mengurutkan nama secara menaik sesuai collation database.

SELECT nama_pelanggan
FROM ms_pelanggan
ORDER BY nama_pelanggan ASC;

-- ============================================================================
-- 05. MENGURUTKAN NAMA TANPA GELAR
-- ============================================================================
-- Tujuan soal: Gelar tidak menjadi bagian dari kunci pengurutan.
-- Nama yang ditampilkan tetap lengkap; CASE hanya memengaruhi urutannya.
-- REVIEW: Implementasi asli hanya melewati awalan 'Ir. ' dan mengambil
-- maksimal 100 karakter berikutnya; belum menghapus gelar lain.

SELECT nama_pelanggan
FROM ms_pelanggan
ORDER BY
    CASE
        WHEN LEFT(nama_pelanggan, 3) = 'Ir.'
            THEN SUBSTRING(nama_pelanggan, 5, 100)
        ELSE nama_pelanggan
    END ASC;

-- ============================================================================
-- 06. NAMA PELANGGAN TERPANJANG
-- ============================================================================
-- Tujuan: Menampilkan semua pelanggan yang memiliki panjang nama maksimum.
-- IN dipertahankan dari sumber; subquery MAX menghasilkan satu nilai.
-- REVIEW: Pada MySQL, LENGTH menghitung byte. Untuk jumlah karakter pada
-- nama multibyte, pertimbangkan CHAR_LENGTH secara konsisten.

SELECT nama_pelanggan
FROM ms_pelanggan
WHERE LENGTH(nama_pelanggan) IN (
    SELECT MAX(LENGTH(nama_pelanggan))
    FROM ms_pelanggan
);

-- ============================================================================
-- 07. NAMA PELANGGAN TERPANJANG DAN TERPENDEK
-- ============================================================================
-- Tujuan soal: Semua nama terpanjang, lalu semua nama terpendek, termasuk gelar.
-- REVIEW: LIMIT 1 membuang hasil seri. UNION menghapus duplikat dan tidak
-- menjamin urutan akhir. Query asli belum memenuhi seluruh instruksi soal.

SELECT *
FROM (
    SELECT nama_pelanggan
    FROM ms_pelanggan
    ORDER BY LENGTH(nama_pelanggan) DESC, nama_pelanggan ASC
    LIMIT 1
) AS pelanggan_terpanjang
UNION
SELECT *
FROM (
    SELECT nama_pelanggan
    FROM ms_pelanggan
    ORDER BY LENGTH(nama_pelanggan) ASC, nama_pelanggan ASC
    LIMIT 1
) AS pelanggan_terpendek;

-- ============================================================================
-- 08. PRODUK DENGAN KUANTITAS PENJUALAN TERTINGGI
-- ============================================================================
-- Tujuan soal: Menampilkan semua produk dengan total kuantitas maksimum.
-- REVIEW: Batas tetap >= 7 hanya mencari total minimal tujuh, bukan maksimum.
-- Perlu membandingkan agregasi tiap produk dengan nilai agregasi tertinggi.

SELECT
    p.kode_produk,
    p.nama_produk,
    SUM(d.qty) AS total_qty
FROM ms_produk AS p
JOIN tr_penjualan_detail AS d
    ON p.kode_produk = d.kode_produk
GROUP BY
    p.kode_produk,
    p.nama_produk
HAVING SUM(d.qty) >= 7;

-- ============================================================================
-- 09. PELANGGAN DENGAN NILAI BELANJA TERTINGGI
-- ============================================================================
-- Tujuan soal: Menampilkan semua pelanggan dengan total belanja maksimum.
-- Total belanja dihitung dari harga_satuan * qty seluruh detail transaksi.
-- REVIEW: LIMIT 1 hanya menampilkan satu pelanggan dan tidak mempertahankan
-- hasil seri. Belum memenuhi instruksi jika beberapa pelanggan sama tertinggi.

SELECT
    p.kode_pelanggan,
    p.nama_pelanggan,
    SUM(d.harga_satuan * d.qty) AS total_harga
FROM ms_pelanggan AS p
JOIN tr_penjualan AS t
    ON p.kode_pelanggan = t.kode_pelanggan
JOIN tr_penjualan_detail AS d
    ON t.kode_transaksi = d.kode_transaksi
GROUP BY
    p.kode_pelanggan,
    p.nama_pelanggan
ORDER BY total_harga DESC
LIMIT 1;

-- ============================================================================
-- 10. PELANGGAN YANG BELUM BERTRANSAKSI
-- ============================================================================
-- Tujuan: Mencari pelanggan yang tidak tercatat pada tabel transaksi.
-- REVIEW: NOT IN bermasalah jika hasil subquery mengandung NULL.
-- Pertimbangkan NOT EXISTS atau pastikan kode_pelanggan tidak NULL.

SELECT
    p.kode_pelanggan,
    p.nama_pelanggan,
    p.alamat
FROM ms_pelanggan AS p
WHERE p.kode_pelanggan NOT IN (
    SELECT t.kode_pelanggan
    FROM tr_penjualan AS t
);

-- ============================================================================
-- 11. TRANSAKSI DENGAN LEBIH DARI SATU BARIS DETAIL
-- ============================================================================
-- Tujuan: Menampilkan transaksi yang mempunyai lebih dari satu baris detail.
-- jumlah_detail bukan total unit (SUM qty) atau jumlah produk unik.
-- DISTINCT dipertahankan dari sumber, tetapi tidak diperlukan karena seluruh
-- kolom non-agregat telah tercakup dalam GROUP BY.

SELECT DISTINCT
    t.kode_transaksi,
    t.kode_pelanggan,
    p.nama_pelanggan,
    t.tanggal_transaksi,
    COUNT(d.kode_transaksi) AS jumlah_detail
FROM ms_pelanggan AS p
JOIN tr_penjualan AS t
    ON p.kode_pelanggan = t.kode_pelanggan
JOIN tr_penjualan_detail AS d
    ON t.kode_transaksi = d.kode_transaksi
GROUP BY
    t.kode_transaksi,
    t.kode_pelanggan,
    p.nama_pelanggan,
    t.tanggal_transaksi
HAVING jumlah_detail > 1;

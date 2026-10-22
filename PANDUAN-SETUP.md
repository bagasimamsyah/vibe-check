# Vibe Check: panduan memasang (repository baru)

Aplikasi ini **terpisah** dari Komitmen Quest dan Norma Kelas. Repository yang lama tidak perlu diubah atau dihapus. File `config.js` sudah terisi.

## Langkah 0: Database (cukup sekali)
Vibe Check membutuhkan satu tabel tambahan di Supabase, yaitu `vc_submissions`. Ada dua cara memasangnya:
- **Cara A:** minta Claude memasangnya, lalu setujui saat diminta.
- **Cara B (manual):**
  1. Buka supabase.com, masuk ke proyek yang sama, lalu buka **SQL Editor** dan klik **New query**.
  2. Buka file `supabase/vibe-check.sql` dengan Notepad, salin semua isinya, lalu tempel di Supabase.
  3. Klik **Run**. Pastikan muncul *Success*.

File ini hanya menambah tabel dan fungsi berawalan `vc_`. Isinya tidak mengubah aplikasi lain.

## Langkah 1: Buat repository baru di GitHub
1. Buka github.com, klik **+** → **New repository**, beri nama `vibe-check`, lalu klik **Create repository**.
2. Klik **uploading an existing file**.
3. Ekstrak zip terlebih dahulu. Lalu seret **isi** folder `vibe-check` ke halaman GitHub:
   - `index.html`
   - `config.js`
   - `PANDUAN-SETUP.md`
   - folder `vendor`
   - folder `supabase`
4. Klik **Commit changes**.

## Langkah 2: Tayangkan di Vercel
1. Buka vercel.com, lalu pilih **Add New…** → **Project**.
2. Pilih `vibe-check`, lalu klik **Import**.
3. Pada *Framework Preset*, pilih **Other**, lalu klik **Deploy**.
4. Anda mendapat tautan, misalnya `vibe-check.vercel.app`.

Tidak perlu mengisi Environment Variables. Jangan memakai kunci *service_role* atau *secret*.

## Cara memakai di kelas
1. **Pengajar** (laptop):
   - Buka tautannya, lalu klik **Saya pengajar** → **Buat kelas baru**.
   - Tayangkan papan dengan tombol **Layar penuh**.
2. **Peserta** (HP):
   - Scan QR, isi nama, lalu jawab 6 soal.
   - Kartu karakter belajar langsung muncul dan hasilnya otomatis masuk ke papan.
3. **Papan** menampilkan:
   - Jumlah dan persentase tiap karakter
   - Diagram komposisi kelas
   - Bacaan untuk kelas: karakter yang dominan, yang paling sedikit, dan blind spot yang perlu diwaspadai
4. **Bentuk kelompok beragam:**
   - Isi jumlah orang per kelompok, lalu klik **Bentuk kelompok**. Setiap kelompok otomatis berisi campuran karakter.
   - Klik **Salin daftar kelompok** untuk menempelkannya ke chat Zoom.

## Tombol di papan
| Tombol | Fungsi |
|---|---|
| Tutup / Buka pengisian | Menghentikan atau membuka kiriman baru |
| Reset jawaban | Menghapus semua hasil Vibe Check kelas ini. Klik 2 kali untuk konfirmasi |
| Tampilkan / Sembunyikan nama | Menampilkan nama peserta di kartu karakter |
| Salin tautan kendali | Membuka papan dengan tombol pengatur di laptop lain. **Jangan dibagikan ke peserta** |

## Catatan
- Satu HP dihitung satu peserta. Jika peserta mengulang Vibe Check, hasil lamanya diganti.
- Hasil Vibe Check adalah refleksi ringan, bukan tes psikologi.
- Kode kelas dari Komitmen Quest atau Norma Kelas juga bisa dipakai di sini.

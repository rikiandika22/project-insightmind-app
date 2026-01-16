# 🧠 Insight Mind

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Database-orange?style=for-the-badge)

**Insight Mind** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna memantau kondisi kesehatan mental dan fisik secara mandiri. Aplikasi ini menggabungkan teknologi pemrosesan sinyal digital (untuk biometrik) dan sistem pakar (untuk screening mental) dalam satu platform yang mudah digunakan.

## ✨ Fitur Unggulan

### 1. ❤️ Scan Biometrik Jantung (PPG)
Menggunakan kamera smartphone dan *flash* untuk mendeteksi aliran darah di ujung jari (*Photoplethysmography*). Sistem menghitung rata-rata detak jantung (BPM) secara *real-time* dan memberikan analisa kondisi fisik dasar.

### 2. 📝 Screening Kesehatan Mental
Kuesioner interaktif untuk mendeteksi tingkat stres dan kecemasan pengguna.
- **Analisa Risiko:** Mengkategorikan hasil menjadi Risiko Rendah, Sedang, atau Tinggi.
- **Rekomendasi AI:** Memberikan saran tindakan yang dipersonalisasi berdasarkan skor akhir.

### 3. 📄 Laporan PDF Otomatis
Fitur pembuatan dokumen profesional untuk kebutuhan dokumentasi atau konsultasi lanjut.
- **Laporan Tunggal:** Ekspor hasil screening saat ini.
- **Laporan Riwayat (Full History):** Ekspor rekapitulasi seluruh aktivitas pengguna dalam format tabel yang rapi.

### 4. 📰 Artikel Edukasi (Cloud Integrated)
Menampilkan artikel kesehatan mental terkini dengan gambar berkualitas tinggi yang terintegrasi dengan **Unsplash API**, memastikan tampilan visual yang selalu segar dan menarik.

### 5. 🌓 Tampilan Adaptif (Dark Mode)
Antarmuka pengguna (UI) yang responsif terhadap pengaturan sistem, mendukung mode terang (*Light Mode*) dan gelap (*Dark Mode*) demi kenyamanan mata pengguna.

---

## 📸 Tangkapan Layar (Screenshots)

| Home Page | Biometric Scan | Screening Result | PDF Report |
|:---------:|:--------------:|:----------------:|:----------:|
| <img src="screenshots/home.png" width="200" /> | <img src="screenshots/biometric.png" width="200" /> | <img src="screenshots/result.png" width="200" /> | <img src="screenshots/pdf.png" width="200" /> |

*(Catatan: Gambar di atas adalah representasi. Silakan lihat aplikasi langsung untuk pengalaman terbaik)*

---

## 🛠️ Teknologi (Tech Stack)

Aplikasi ini dibangun menggunakan teknologi modern untuk memastikan performa dan skalabilitas:

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Riverpod](https://riverpod.dev/) (Untuk manajemen data reaktif dan *testable code*)
* **Local Database:** [Hive](https://docs.hivedb.dev/) (NoSQL database yang sangat cepat untuk menyimpan riwayat offline)
* **Hardware Access:** `camera` (Akses kamera untuk PPG), `sensors_plus` (Akses sensor gerak)
* **PDF Engine:** `pdf` & `printing` (Generate dokumen vektor)
* **Networking:** `http` & Image Network (Load gambar artikel)

---

## 📂 Struktur Proyek

Proyek ini menerapkan prinsip **Clean Architecture** (dipisah per fitur) untuk memudahkan pemeliharaan:

```text
lib/
├── features/
│   └── insightmind/
│       ├── business/       # Logic Export PDF & Service
│       ├── data/           # Model data, Hive Adapters, Repository Implementation
│       ├── domain/         # Entities & Usecases (Murni Dart)
│       ├── presentation/   # UI (Pages, Widgets) & State Management (Providers)
│       └── providers/      # Dependency Injection Riverpod
├── main.dart               # Entry point
└── ...

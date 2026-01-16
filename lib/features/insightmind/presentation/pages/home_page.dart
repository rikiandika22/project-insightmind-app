// lib/features/insightmind/presentation/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- IMPORT HALAMAN ---
import 'article_detail_page.dart';
import 'screening_page.dart';
import 'history_page.dart';
import 'analisis_page.dart';
import 'biometric_page.dart';

// --- IMPORT DATA & BUSINESS ---
import '../../domain/entities/article.dart';
import '../../data/local/article_data.dart';
import '../../data/local/screening_record.dart'; 
import '../../business/report_service.dart';      

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE SEARCH ---
  List<Article> filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();

  // --- STATE BANNER (UPDATED: Menggunakan URL Gambar Cloud) ---
  int _currentBannerIndex = 0;
  final List<Map<String, String>> bannerData = [
    {
      "title": "How are You\nToday?", 
      "subtitle": "Cek kondisi mentalmu sekarang", 
      // Gambar: Wanita sedang relaksasi / meditasi
      "image": "https://images.unsplash.com/photo-1544027993-37dbfe43562a?q=80&w=1000&auto=format&fit=crop"
    },
    {
      "title": "Butuh Teman\nCerita?", 
      "subtitle": "Lihat daftar layanan konsultasi", 
      // Gambar: Sesi konseling / berbicara
      "image": "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?q=80&w=1000&auto=format&fit=crop" 
    },
    {
      "title": "Tips Kelola\nStress", 
      "subtitle": "Baca artikel terbaru hari ini", 
      // Gambar: Alam / Ketenangan
      "image": "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=1000&auto=format&fit=crop"
    },
    {
      "title": "Tidur Lebih\nNyenyak", 
      "subtitle": "Pentingnya istirahat berkualitas", 
      // Gambar: Suasana tidur nyaman
      "image": "https://images.unsplash.com/photo-1520206183501-b80df61043c2?auto=format&fit=crop&w=1000&q=80"
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredArticles = mentalHealthArticles;
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        filteredArticles = mentalHealthArticles;
      } else {
        filteredArticles = mentalHealthArticles
            .where((article) => article.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _exportAllHistoryToPDF(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 15),
            Text("Menyiapkan seluruh data riwayat..."),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final box = await Hive.openBox<ScreeningRecord>('screening_records');

      if (box.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Belum ada riwayat untuk diekspor."), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      final List<ScreeningRecord> allRecords = box.values.toList();
      final File pdfFile = await ReportService.generateFullReport(allRecords);
      await ReportService.shareReport(pdfFile);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal ekspor: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDarkMode),
                  const SizedBox(height: 24),
                  _buildCarouselBanner(), // Banner baru ada di sini
                  const SizedBox(height: 32),
                  _buildSectionTitle('Menu Utama', isDarkMode),
                  const SizedBox(height: 16),
                  _buildMenuGrid(context, isDarkMode),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Cari Artikel', isDarkMode),
                  const SizedBox(height: 12),
                  _buildSearchBar(isDarkMode),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Artikel Terkini', isDarkMode),
                  const SizedBox(height: 12),
                  _buildArtikelRow(context, isDarkMode),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildStartButton(context, isDarkMode),
        ],
      ),
    );
  }

  // --- WIDGET CAROUSEL BANNER YANG DIPERBARUI ---
  Widget _buildCarouselBanner() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: bannerData.length,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // LAYER 1: Gambar dari Network (Cloud)
                      Positioned.fill(
                        child: Image.network(
                          bannerData[index]['image']!,
                          fit: BoxFit.cover,
                          // Loading Builder: Tampil saat gambar sedang didownload
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red[800],
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          // Error Builder: Tampil jika tidak ada internet / URL salah
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.white54, size: 40),
                                    SizedBox(height: 8),
                                    Text("Gagal memuat gambar", style: TextStyle(color: Colors.white54, fontSize: 10))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // LAYER 2: Gradient Overlay (Agar teks terbaca jelas)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8), 
                              Colors.black.withOpacity(0.1)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                          )
                        )
                      ),

                      // LAYER 3: Teks Judul & Subjudul
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              bannerData[index]['title']!, 
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                                height: 1.2
                              )
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(
                                bannerData[index]['subtitle']!, 
                                style: const TextStyle(color: Colors.white, fontSize: 12)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Indikator Titik-titik di bawah banner
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(bannerData.length, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 5),
            height: 6, 
            width: _currentBannerIndex == index ? 20 : 6,
            decoration: BoxDecoration(
              color: _currentBannerIndex == index ? Colors.red[800] : Colors.grey[400], 
              borderRadius: BorderRadius.circular(3)
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(color: isDarkMode ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(value),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "Cari judul artikel...",
          hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.red[400] : Colors.red[800]),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildArtikelRow(BuildContext context, bool isDarkMode) {
    if (filteredArticles.isEmpty) return Center(child: Text("Artikel tidak ditemukan", style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black)));
    
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredArticles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final article = filteredArticles[index];
          final bool isNetwork = article.imageUrl.startsWith('http');

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article))),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: isNetwork 
                      ? Image.network(article.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey, height: 110))
                      : Image.asset(article.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey, height: 110)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : Colors.black)),
                        const SizedBox(height: 6),
                        Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return SafeArea(child: Padding(padding: const EdgeInsets.only(top: 16), child: Row(children: [
      Image.asset('assets/images/logo.png', height: 35, errorBuilder: (c,e,s) => const Icon(Icons.psychology, size: 35, color: Colors.red)),
      const SizedBox(width: 12),
      Text('Insight Mind', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDarkMode ? Colors.white : Colors.black)),
    ])));
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) => Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black));

  Widget _buildMenuGrid(BuildContext context, bool isDarkMode) {
    return Row(children: [
      _buildMenuCard(icon: Icons.analytics_rounded, label: 'Analisis', color: Colors.indigo, isDarkMode: isDarkMode, 
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalisisPage()))),
      const SizedBox(width: 12),
      _buildMenuCard(icon: Icons.fingerprint_rounded, label: 'Biometric', color: Colors.red, isDarkMode: isDarkMode, 
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BiometricPage()))),
      const SizedBox(width: 12),
      _buildMenuCard(icon: Icons.picture_as_pdf_rounded, label: 'Ekspor PDF', color: Colors.teal, isDarkMode: isDarkMode, 
        onTap: () => _exportAllHistoryToPDF(context)),
      const SizedBox(width: 12),
      _buildMenuCard(icon: Icons.grid_view_rounded, label: 'Lainnya', color: Colors.blueGrey, isDarkMode: isDarkMode, 
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()))),
    ]);
  }

  Widget _buildMenuCard({required IconData icon, required String label, required Color color, required bool isDarkMode, required VoidCallback onTap}) {
    return Expanded(child: Column(children: [
      InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(
        height: 60, width: double.infinity,
        decoration: BoxDecoration(color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
        child: Icon(icon, color: isDarkMode ? color.withBlue(255) : color, size: 28),
      )),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.black87)),
    ]));
  }

  Widget _buildStartButton(BuildContext context, bool isDarkMode) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(padding: const EdgeInsets.all(20), color: scaffoldColor,
      child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreeningPage())),
        child: const Text('Mulai Screening Mental', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
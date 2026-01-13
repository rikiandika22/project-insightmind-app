// lib/features/insightmind/presentation/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- IMPORT HALAMAN ---
import 'package:insightmind_app/features/insightmind/presentation/pages/screening_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/history_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/analisis_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/biometric_page.dart';
import 'article_detail_page.dart';

// --- IMPORT BUSINESS & DATA ---
import 'package:insightmind_app/features/insightmind/business/report_service.dart';
import '../../domain/entities/article.dart';
import '../../data/local/article_data.dart';
import '../../data/local/screening_record.dart'; // Import Model Data untuk Hive

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  final String logoAsset = 'assets/images/logo.png';
  final String bannerAsset = 'assets/images/banner_hero.png';

  /// [FUNGSI EKSPOR PDF] 
  /// Mengambil semua data dari Hive dan membuat laporan gabungan
  Future<void> _exportAllHistoryToPDF(BuildContext context) async {
    // 1. Tampilkan Feedback Loading
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
      // 2. Akses Database Hive
      // Pastikan box sudah dibuka di main.dart, jika ragu bisa pakai await Hive.openBox(...)
      final box = Hive.box<ScreeningRecord>('screening_records');

      if (box.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Belum ada riwayat untuk diekspor."), 
              backgroundColor: Colors.orange
            ),
          );
        }
        return;
      }

      // 3. Ambil Semua Data & Convert ke List
      final List<ScreeningRecord> allRecords = box.values.toList();

      // 4. Panggil Service Baru untuk Generate PDF Lengkap
      final File pdfFile = await ReportService.generateFullReport(allRecords);
      
      // 5. Bagikan File
      await ReportService.shareReport(pdfFile);

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal ekspor: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [LOGIKA TEMA] Cek apakah sedang mode gelap
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDarkMode),
                    const SizedBox(height: 24),
                    _buildBanner(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Menu Utama', isDarkMode),
                    const SizedBox(height: 16),
                    _buildMenuGrid(context, isDarkMode),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Artikel Terkini', isDarkMode),
                    const SizedBox(height: 12),
                    _buildArtikelRow(context, isDarkMode),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildStartButton(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            Image.asset(logoAsset, height: 35, 
              errorBuilder: (c, e, s) => const Icon(Icons.psychology, size: 35, color: Colors.red)),
            const SizedBox(width: 12),
            Text('Insight Mind',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                letterSpacing: -0.5,
                color: isDarkMode ? Colors.white : Colors.black,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(bannerAsset, width: double.infinity, height: 180, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.red[900])),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('How are You\nToday?',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
                  SizedBox(height: 8),
                  Text('Cek kondisi mentalmu sekarang', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(title, 
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ));
  }

  Widget _buildMenuGrid(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        _buildMenuCard(context,
          icon: Icons.analytics_rounded, label: 'Analisis', color: Colors.indigo, isDarkMode: isDarkMode,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalisisPage())),
        ),
        const SizedBox(width: 12),
        _buildMenuCard(context,
          icon: Icons.fingerprint_rounded, label: 'Biometric', color: Colors.red.shade700, isDarkMode: isDarkMode,
          // [PENTING] Hapus 'const' di sini agar tidak error
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BiometricPage())),
        ),
        const SizedBox(width: 12),
        _buildMenuCard(context,
          icon: Icons.picture_as_pdf_rounded, label: 'Ekspor PDF', color: Colors.teal, isDarkMode: isDarkMode,
          // Panggil fungsi ekspor yang baru
          onTap: () => _exportAllHistoryToPDF(context),
        ),
        const SizedBox(width: 12),
        _buildMenuCard(context,
          icon: Icons.grid_view_rounded, label: 'Lainnya', color: Colors.blueGrey, isDarkMode: isDarkMode,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage())),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap, required bool isDarkMode}) {
    return Expanded(
      child: Column(
        children: [
          Material(
            color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                ),
                child: Icon(icon, color: isDarkMode ? color.withBlue(255) : color, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800]
            ),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// Widget Artikel dengan Smart Logic (Asset vs Network)
  Widget _buildArtikelRow(BuildContext context, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mentalHealthArticles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final article = mentalHealthArticles[index];
          
          // CEK: Apakah URL online (http) atau lokal asset?
          final bool isOnline = article.imageUrl.startsWith('http');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailPage(article: article),
                ),
              );
            },
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GAMBAR (Smart Logic)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: isOnline
                        ? Image.network(
                            article.imageUrl,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                          )
                        : Image.asset(
                            article.imageUrl,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                          ),
                  ),
                  // JUDUL & SUMMARY
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 13,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11, 
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600]
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
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 110,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, -5)
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        // Navigasi ke Screening Page (Pastikan import const jika page nya const)
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreeningPage())),
        child: const Text('Mulai Screening Mental', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
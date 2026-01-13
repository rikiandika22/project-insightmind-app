// lib/features/insightmind/presentation/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/screening_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/history_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/analisis_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/biometric_page.dart';
import 'package:insightmind_app/features/insightmind/business/report_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  final String logoAsset = 'assets/images/logo.png';
  final String bannerAsset = 'assets/images/banner_hero.png';

  /// Fungsi untuk memproses ekspor seluruh tabel riwayat ke PDF
  Future<void> _exportAllHistoryToPDF(BuildContext context) async {
    // Tampilkan Loading Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 15),
            Text("Menyusun tabel riwayat..."),
          ],
        ),
      ),
    );

    try {
      // 1. Generate PDF Tabel dari ReportService
      final File pdfFile = await ReportService.generateFullHistoryPdf();
      
      // 2. Share PDF
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildBanner(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Menu Utama'),
                    const SizedBox(height: 16),
                    _buildMenuGrid(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Artikel Terkini'),
                    const SizedBox(height: 12),
                    _buildArtikelRow(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            Image.asset(logoAsset, height: 35, 
              errorBuilder: (c, e, s) => const Icon(Icons.psychology, size: 35, color: Colors.red)),
            const SizedBox(width: 12),
            const Text('Insight Mind',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Row(
      children: [
        _buildMenuCard(context,
          icon: Icons.analytics_rounded, label: 'Analisis', color: Colors.indigo,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalisisPage())),
        ),
        const SizedBox(width: 12),
        _buildMenuCard(context,
          icon: Icons.fingerprint_rounded, label: 'Biometric', color: Colors.red.shade700,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BiometricPage())),
        ),
        const SizedBox(width: 12),
        // MENU PDF UPDATED
        _buildMenuCard(context,
          icon: Icons.picture_as_pdf_rounded, label: 'Ekspor PDF', color: Colors.teal,
          onTap: () => _exportAllHistoryToPDF(context),
        ),
        const SizedBox(width: 12),
        _buildMenuCard(context,
          icon: Icons.grid_view_rounded, label: 'Aktivitas', color: Colors.blueGrey,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage())),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: Column(
        children: [
          Material(
            color: color.withOpacity(0.1),
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
                child: Icon(icon, color: color, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildArtikelRow() {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(child: Icon(Icons.article_outlined, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreeningPage())),
        child: const Text('Mulai Screening Mental', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
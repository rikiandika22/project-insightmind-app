// lib/features/insightmind/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/screening_page.dart'; 
// [BARU] Import halaman riwayat
import 'package:insightmind_app/features/insightmind/presentation/pages/history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String logoAsset = 'assets/images/logo.png';
  final String bannerAsset = 'assets/images/banner_hero.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [DIUBAH] Header sekarang berisi tombol
                    _buildHeader(context), 
                    const SizedBox(height: 24),
                    _buildBanner(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Menu'),
                    const SizedBox(height: 12),
                    _buildMenuRow(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Artikel'),
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

  // [DIUBAH] Tambahkan BuildContext
  Widget _buildHeader(BuildContext context) { 
    return SafeArea(
      bottom: false, 
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            Image.asset(
              logoAsset, 
              height: 32, 
            ),
            const SizedBox(width: 12),
            const Text(
              'Insight Mind',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), // Dorong tombol ke kanan
            // [BARU] Tombol untuk membuka halaman riwayat
            IconButton(
              icon: Icon(Icons.history_rounded, color: Colors.grey[700]),
              tooltip: 'Lihat Riwayat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (Sisa widget _buildBanner, _buildSectionTitle, _buildMenuRow, _buildArtikelRow, _buildPlaceholderBox, _buildStartButton tidak berubah) ...
  Widget _buildBanner(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            bannerAsset,
            width: double.infinity,
            height: 180, 
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 100.0), 
          child: Text(
            'How are You\nToday?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuRow() {
    return Row(
      children: [
        Expanded(child: _buildPlaceholderBox(height: 75)), 
        const SizedBox(width: 12), 
        Expanded(child: _buildPlaceholderBox(height: 75)),
        const SizedBox(width: 12),
        Expanded(child: _buildPlaceholderBox(height: 75)),
        const SizedBox(width: 12),
        Expanded(child: _buildPlaceholderBox(height: 75)),
      ],
    );
  }

  Widget _buildArtikelRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlaceholderBox(width: 140, height: 100),
          const SizedBox(width: 12),
          _buildPlaceholderBox(width: 140, height: 100),
          const SizedBox(width: 12),
          _buildPlaceholderBox(width: 140, height: 100),
          const SizedBox(width: 12),
          _buildPlaceholderBox(width: 140, height: 100),
          const SizedBox(width: 12),
          _buildPlaceholderBox(width: 140, height: 100),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox({double? width, required double height}) {
    return Container(
      width: width, 
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200], 
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), 
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Aksi untuk mulai screening
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScreeningPage()),
          );
        },
        child: const Text(
          'Mulai Screening',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/screening_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/history_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/analisis_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/providers/report_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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
                    _buildBanner(),
                    const SizedBox(height: 32),
                    const Text(
                      'Menu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Baris menu utama dengan 4 kolom
                    _buildMenuRow(context, ref),
                    const SizedBox(height: 32),
                    const Text(
                      'Artikel Terbaru',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFFC62828), size: 32),
            const SizedBox(width: 12),
            const Text(
              'Insight Mind',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'How are You Today?',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 1. Menu Analytics
        Expanded(
          child: _buildMenuItem(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalisisPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Menu PDF Report (Fitur Agung)
        Expanded(
          child: _buildMenuItem(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF Report',
            color: const Color(0xFFC62828),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Memproses Laporan & Simpan Data...")),
              );
              // Memanggil fungsi utama di ReportProvider
              await ref.read(reportProvider).processFullReport(85.0, "Risiko Rendah");
            },
          ),
        ),

        const SizedBox(width: 12),
        // 3. Placeholder Box 1
        Expanded(child: _buildPlaceholderBox()),
        const SizedBox(width: 12),
        // 4. Placeholder Box 2
        Expanded(child: _buildPlaceholderBox()),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBox() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildArtikelRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlaceholderBoxArtikel(),
          const SizedBox(width: 12),
          _buildPlaceholderBoxArtikel(),
          const SizedBox(width: 12),
          _buildPlaceholderBoxArtikel(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBoxArtikel() {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScreeningPage()),
          ),
          child: const Text(
            'Mulai Screening',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
// lib/features/insightmind/presentation/pages/result_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORT ENTITY & BUSINESS ---
import '../../domain/entities/mental_result.dart';
import '../../business/report_service.dart'; // Import Report Service
import '../providers/questionnaire_provider.dart'; 

class ResultPage extends ConsumerWidget {
  // Data hasil WAJIB diterima dari halaman sebelumnya (Processing/Biometric)
  final MentalResult result;

  const ResultPage({super.key, required this.result});

  // --- FUNGSI EKSPOR PDF (SINGLE) ---
  Future<void> _exportPdf(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              SizedBox(width: 15),
              Text("Menyiapkan dokumen PDF..."),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // Panggil fungsi generatePdfReport (Laporan Tunggal) dari ReportService
      // [PERBAIKAN] Kirim riskLevel murni agar tampilan di PDF lebih rapi
      final File pdfFile = await ReportService.generatePdfReport(
        result.score, 
        result.riskLevel 
      );
      
      // Bagikan File
      await ReportService.shareReport(pdfFile);
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal ekspor PDF: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Deteksi Tema
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    // Tentukan Warna Status berdasarkan String Risiko
    Color statusColor;
    IconData statusIcon;

    if (result.riskLevel.toLowerCase().contains("tinggi")) {
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
    } else if (result.riskLevel.toLowerCase().contains("sedang")) {
      statusColor = Colors.orange;
      statusIcon = Icons.info_outline_rounded;
    } else {
      // Hijau untuk "Rendah" atau "Stabil" (Biometrik)
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Hasil Screening", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        foregroundColor: statusColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        actions: [
          // Tombol Share di Pojok Kanan Atas
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _exportPdf(context),
            tooltip: "Bagikan Hasil",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. KARTU HASIL UTAMA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, size: 60, color: statusColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.riskLevel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // Jika Biometrik, tampilkan "BPM", jika Screening biasa tampilkan angka
                      result.riskLevel.toLowerCase().contains('biometrik') 
                          ? "Denyut: ${result.score.toStringAsFixed(0)} BPM"
                          : "Total Skor: ${result.score.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. PESAN ANALISA AI
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Analisa AI:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Text(
                result.riskMessage,
                style: TextStyle(fontSize: 15, height: 1.5, color: textColor),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 24),
            
            // 3. REKOMENDASI (Ditampilkan jika ada)
            if (result.recommendations.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Rekomendasi:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ),
              const SizedBox(height: 10),
              ...result.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 20, color: statusColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(rec, style: TextStyle(color: textColor, height: 1.3)),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 30),
            ],

            // 4. TOMBOL AKSI
            Row(
              children: [
                // Tombol PDF
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportPdf(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Unduh PDF"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Selesai
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(questionnaireProvider); // Reset Kuesioner
                      Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke Home
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text("Selesai"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
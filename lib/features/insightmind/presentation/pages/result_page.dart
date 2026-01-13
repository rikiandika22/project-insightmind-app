// lib/features/insightmind/presentation/pages/result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// --- Imports Entitas & Provider ---
import '../../domain/entities/mental_result.dart'; 
// Gunakan Package Import untuk menjamin tipe data ScoreState dan scoreProvider terbaca
import 'package:insightmind_app/features/insightmind/presentation/providers/score_provider.dart';

// Import Model Database & Halaman Analisis
import '../../data/local/screening_record.dart';
import 'analisis_page.dart'; 

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  // --- LOGIKA WARNA UI (TEMA MERAH) ---
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'tinggi': return Colors.red.shade900;
      case 'sedang': return Colors.orange.shade800;
      case 'rendah': return Colors.green.shade700;
      default: return Colors.grey;
    }
  }

  // --- FUNGSI EKSPOR PDF ---
  Future<void> _generateAndPrintPdf(MentalResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("INSIGHT MIND", 
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  pw.Text("Tanggal: ${DateTime.now().toString().substring(0, 10)}", 
                    style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.red100),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text("LAPORAN HASIL SCREENING MENTAL",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.red100),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.red50),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Center(child: pw.Text("Parameter"))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Center(child: pw.Text("Detail Hasil"))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Skor Kalkulasi AI")),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(result.score.toStringAsFixed(1))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Kategori Risiko")),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(result.riskLevel.toUpperCase())),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text("REKOMENDASI AI:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(result.recommendations.join(". ")),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // --- FUNGSI PENYIMPANAN KE HIVE ---
  void _saveAndNavigate(BuildContext context, MentalResult result) {
    try {
      final box = Hive.box<ScreeningRecord>('screening_records');
      final newRecord = ScreeningRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        score: result.score,
        riskLevel: result.riskLevel,
        riskMessage: result.recommendations.join(". "), 
        confidence: result.confidence,
      );

      box.add(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Hasil tersimpan di Riwayat!"), backgroundColor: Colors.red.shade800),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalisisPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.black),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state dari scoreProvider
    final scoreState = ref.watch(scoreProvider);
    final primaryRed = Colors.red.shade800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: primaryRed, 
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      // Meneruskan scoreState ke fungsi buildBody
      body: _buildBody(context, scoreState),
    );
  }

  // Perbaikan: Pastikan tipe data ScoreState dikenali
  Widget _buildBody(BuildContext context, ScoreState state) {
    final primaryRed = Colors.red.shade800;

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryRed),
            const SizedBox(height: 16),
            const Text('Menghitung risiko dengan model AI...'),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(state.errorMessage!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Kembali"),
            ),
          ],
        ),
      );
    }

    if (state.result != null) {
      return _buildContent(context, state.result!);
    }

    return const Center(child: Text("Tidak ada data untuk dianalisis."));
  }

  Widget _buildContent(BuildContext context, MentalResult result) {
    final riskColor = _getRiskColor(result.riskLevel);
    final primaryRed = Colors.red.shade800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.psychology_alt, size: 60, color: primaryRed),
          const SizedBox(height: 16),
          Text('Tingkat Risiko Anda:', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            result.riskLevel.toUpperCase(),
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
          ),
          const Divider(height: 32),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(context, 'Final Score:', result.score.toStringAsFixed(3)),
                  const Divider(),
                  _buildDetailRow(context, 'Kepercayaan AI:', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Rekomendasi Kami:', 
              style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(height: 12),
          ...result.recommendations.map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: primaryRed, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(rec)),
              ],
            ),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _generateAndPrintPdf(result),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Ekspor Hasil ke PDF"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: primaryRed,
                side: BorderSide(color: primaryRed, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveAndNavigate(context, result),
              icon: const Icon(Icons.save_as_rounded),
              label: const Text("Simpan & Lihat Dashboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
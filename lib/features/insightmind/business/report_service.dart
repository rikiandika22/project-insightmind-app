import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

// Pastikan path import ini benar sesuai struktur folder Anda
import '../data/local/screening_record.dart';

class ReportService {
  // ==========================================================
  // BAGIAN 1: DATABASE LOKAL (HIVE)
  // ==========================================================

  /// Menyimpan hasil screening secara otomatis
  static Future<void> autoSaveResult(
    double score,
    String risk, {
    String message = "Tidak ada pesan khusus",
    double confidence = 0.0,
  }) async {
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    String uniqueId = const Uuid().v4();

    final newRecord = ScreeningRecord(
      id: uniqueId,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: risk,
      riskMessage: message,
      confidence: confidence,
    );

    await box.add(newRecord);
    print("Auto-save berhasil: $risk | Time: ${newRecord.timestamp}");
  }

  /// Mengambil seluruh riwayat untuk ditampilkan di Dashboard
  static Future<List<ScreeningRecord>> getHistory() async {
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    List<ScreeningRecord> history = box.values.toList();
    // Mengurutkan dari yang terbaru ke terlama
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  // ==========================================================
  // BAGIAN 2: PDF REPORTING (DOKUMEN FORMAL)
  // ==========================================================

  /// [FUNGSI BARU] Membuat PDF berisi tabel seluruh riwayat (untuk menu Home)
  static Future<File> generateFullHistoryPdf() async {
    final pdf = pw.Document();
    final history = await getHistory();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Tabel
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("INSIGHT MIND - RIWAYAT SCREENING",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text("Unduh: ${DateTime.now().toString().substring(0, 10)}"),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 15),

            // Tabel Data Riwayat
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellPadding: const pw.EdgeInsets.all(5),
              headers: ['No', 'Tanggal', 'Skor', 'Kategori Risiko', 'Confidence'],
              data: List<List<dynamic>>.generate(
                history.length,
                (index) => [
                  index + 1,
                  history[index].timestamp.toString().substring(0, 16),
                  history[index].score.toStringAsFixed(1),
                  history[index].riskLevel.toUpperCase(),
                  "${(history[index].confidence * 100).toStringAsFixed(0)}%",
                ],
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "Catatan: Laporan ini merangkum seluruh aktivitas screening Anda secara kronologis.",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    return await _savePdfFile(pdf, "Full_History_Report");
  }

  /// Membuat file PDF tunggal (Single Result)
  static Future<File> generatePdfReport(double score, String risk) async {
    final pdf = pw.Document();

    String recommendationText = _getRecommendation(risk);
    PdfColor statusColor = _getStatusColor(risk);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("INSIGHT MIND", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blueGrey800)),
                    pw.Text("Tanggal: ${DateTime.now().toString().substring(0, 10)}", style: const pw.TextStyle(color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text("LAPORAN HASIL SCREENING MENTAL", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
                  data: <List<String>>[
                    ['Parameter', 'Detail Hasil'],
                    ['Skor Kalkulasi AI', score.toStringAsFixed(1)],
                    ['Kategori Risiko', risk.toUpperCase()],
                    ['Waktu Pengambilan', DateTime.now().toString().substring(0, 16)],
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border(left: pw.BorderSide(color: statusColor, width: 4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("REKOMENDASI AI", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor)),
                      pw.SizedBox(height: 6),
                      pw.Text(recommendationText, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.Text("PENAFIAN (DISCLAIMER):", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.Text(
                  "Dokumen ini merupakan hasil analisis otomatis menggunakan kecerdasan buatan (AI). Laporan ini TIDAK menggantikan diagnosis medis profesional.",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.justify,
                ),
              ],
            ),
          );
        },
      ),
    );

    return await _savePdfFile(pdf, "Screening_Report");
  }

  // ==========================================================
  // HELPER METHODS
  // ==========================================================

  static Future<File> _savePdfFile(pw.Document pdf, String prefix) async {
    final output = await getTemporaryDirectory();
    final fileName = "${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _getRecommendation(String risk) {
    if (risk.toLowerCase().contains("tinggi")) {
      return "Skor menunjukkan indikasi stres tingkat tinggi. Sangat disarankan untuk segera berkonsultasi dengan psikolog atau tenaga medis profesional.";
    } else if (risk.toLowerCase().contains("sedang")) {
      return "Terdeteksi gejala stres ringan hingga sedang. Disarankan untuk meluangkan waktu istirahat atau mempraktikkan teknik relaksasi.";
    } else {
      return "Kondisi mental Anda tampak stabil dalam rentang normal. Pertahankan pola hidup sehat untuk menjaga stabilitas emosi.";
    }
  }

  static PdfColor _getStatusColor(String risk) {
    if (risk.toLowerCase().contains("tinggi")) return PdfColors.red700;
    if (risk.toLowerCase().contains("sedang")) return PdfColors.orange700;
    return PdfColors.green700;
  }

  /// Membagikan file PDF ke aplikasi lain
  static Future<void> shareReport(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Berikut adalah Laporan Hasil Screening Kesehatan Mental saya dari aplikasi Insight Mind.',
    );
  }
}
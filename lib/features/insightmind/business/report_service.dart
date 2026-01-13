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
    // Membuka box dengan aman
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    
    // Membuat ID unik
    String uniqueId = const Uuid().v4();

    // Membuat objek record sesuai Model terbaru
    final newRecord = ScreeningRecord(
      id: uniqueId,
      timestamp: DateTime.now(), // Menggunakan 'timestamp'
      score: score,
      riskLevel: risk,
      riskMessage: message,
      confidence: confidence,
    );

    await box.add(newRecord);
    print("Auto-save berhasil: $risk | Time: ${newRecord.timestamp}");
  }

  /// Mengambil seluruh riwayat untuk ditampilkan di Dashboard (Fitur Anggota 2)
  static Future<List<ScreeningRecord>> getHistory() async {
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    
    // Mengambil data dan mengurutkannya dari yang terbaru ke terlama
    List<ScreeningRecord> history = box.values.toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp)); 
    
    return history;
  }

  // ==========================================================
  // BAGIAN 2: PDF REPORTING (DOKUMEN FORMAL)
  // ==========================================================

  /// Membuat file PDF profesional dengan rekomendasi dan disclaimer
  static Future<File> generatePdfReport(double score, String risk) async {
    final pdf = pw.Document();

    // Logika Rekomendasi (Actionable Insight)
    String recommendationText = "";
    if (risk.toLowerCase().contains("tinggi")) {
      recommendationText = "Skor menunjukkan indikasi stres tingkat tinggi. Sangat disarankan untuk segera berkonsultasi dengan psikolog atau tenaga medis profesional. Hindari melakukan diagnosis mandiri.";
    } else if (risk.toLowerCase().contains("sedang")) {
      recommendationText = "Terdeteksi gejala stres ringan hingga sedang. Disarankan untuk meluangkan waktu istirahat, melakukan hobi yang menyenangkan, atau mempraktikkan teknik relaksasi pernapasan.";
    } else {
      recommendationText = "Kondisi mental Anda tampak stabil dalam rentang normal. Pertahankan pola hidup sehat, tidur yang cukup, dan olahraga teratur untuk menjaga stabilitas emosi.";
    }

    // Menentukan Warna Status
    PdfColor statusColor = risk.toLowerCase().contains("tinggi") 
        ? PdfColors.red700 
        : (risk.toLowerCase().contains("sedang") ? PdfColors.orange700 : PdfColors.green700);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. Header Laporan
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("INSIGHT MIND", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blueGrey800)),
                    pw.Text("Tanggal: ${DateTime.now().toString().substring(0, 10)}", style: const pw.TextStyle(color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 20),

                // 2. Judul Dokumen
                pw.Center(
                  child: pw.Text(
                    "LAPORAN HASIL SCREENING MENTAL",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),

                // 3. Tabel Data Utama
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey50),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                  cellPadding: const pw.EdgeInsets.all(8),
                  data: <List<String>>[
                    ['Parameter', 'Detail Hasil'],
                    ['Skor Kalkulasi AI', score.toStringAsFixed(1)],
                    ['Kategori Risiko', risk.toUpperCase()],
                    ['Waktu Pengambilan', DateTime.now().toString().substring(0, 16)],
                  ],
                ),
                pw.SizedBox(height: 20),

                // 4. Kotak Rekomendasi (Actionable Insight)
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
                      pw.Text(
                        "REKOMENDASI AI",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        recommendationText,
                        style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(), // Mendorong Disclaimer ke paling bawah

                // 5. Footer / Disclaimer (Aspek Keamanan & Hukum)
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Text(
                  "PENAFIAN (DISCLAIMER):",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                ),
                pw.Text(
                  "Dokumen ini merupakan hasil analisis otomatis menggunakan kecerdasan buatan (AI) berdasarkan data yang Anda masukkan. Laporan ini TIDAK menggantikan diagnosis medis profesional. Segala keputusan terkait kesehatan harus dikonsultasikan dengan dokter atau psikolog berlisensi.",
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 4),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Generated by InsightMind App",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Menyimpan file
    final output = await getTemporaryDirectory();
    final fileName = "InsightMind_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Membagikan file PDF ke aplikasi lain
  static Future<void> shareReport(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Berikut adalah Laporan Hasil Screening Kesehatan Mental saya dari aplikasi Insight Mind.',
    );
  }
}
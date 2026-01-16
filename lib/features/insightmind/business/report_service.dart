// lib/features/insightmind/business/report_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Pastikan path import ini benar sesuai struktur folder Anda
import '../data/local/screening_record.dart';

class ReportService {
  
  // ==========================================================
  // BAGIAN 1: DATABASE LOKAL (HIVE)
  // ==========================================================

  /// Menyimpan hasil screening/biometrik secara otomatis ke Hive
  static Future<void> autoSaveResult(
    double score,
    String risk, {
    String message = "Tidak ada pesan khusus",
    double confidence = 0.0,
  }) async {
    // Buka box database
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    
    // Generate ID unik
    String uniqueId = const Uuid().v4();

    // Buat objek record baru
    final newRecord = ScreeningRecord(
      id: uniqueId,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: risk,
      riskMessage: message,
      confidence: confidence,
    );

    // Simpan ke database
    await box.add(newRecord);
    print("Auto-save berhasil: $risk | Time: ${newRecord.timestamp}");
  }

  /// Mengambil seluruh riwayat dari Hive
  static Future<List<ScreeningRecord>> getHistory() async {
    var box = await Hive.openBox<ScreeningRecord>('screening_records');
    List<ScreeningRecord> history = box.values.toList();
    
    // Urutkan dari yang terbaru ke terlama (Descending)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return history;
  }

  // ==========================================================
  // BAGIAN 2: PDF REPORTING (LENGKAP)
  // ==========================================================

  /// [FITUR UTAMA] Generate PDF Laporan Lengkap (Tabel Gabungan)
  /// Menerima List<ScreeningRecord> agar fleksibel
  static Future<File> generateFullReport(List<ScreeningRecord> records) async {
    final pdf = pw.Document();
    
    // Urutkan data biar rapi (Terbaru di atas)
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSummary(records), // Statistik Singkat
            pw.SizedBox(height: 20),
            pw.Text("Rincian Riwayat Aktivitas:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            _buildTable(records),   // Tabel Data
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return await _saveDocument(pdf, "Laporan_Lengkap_InsightMind.pdf");
  }

  /// Membuat PDF Laporan Satuan (Single Result) - Dipakai di ResultPage
  static Future<File> generatePdfReport(double score, String risk) async {
    final pdf = pw.Document();
    final statusColor = _getStatusColor(risk);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 20),
                
                pw.Center(
                  child: pw.Text(
                    "HASIL PEMERIKSAAN TUNGGAL", 
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tabel Detail
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: <List<String>>[
                    ['Parameter', 'Detail'],
                    ['Waktu Pemeriksaan', DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())],
                    ['Kategori Risiko', risk],
                    ['Skor Numerik', score.toStringAsFixed(1)],
                  ],
                ),
                
                pw.SizedBox(height: 20),

                // Kotak Rekomendasi
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border(left: pw.BorderSide(color: statusColor, width: 5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("ANALISA & REKOMENDASI", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor)),
                      pw.SizedBox(height: 8),
                      pw.Text(_getRecommendation(risk), style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    return await _saveDocument(pdf, "Single_Result_Report.pdf");
  }


  // ==========================================================
  // HELPER WIDGETS (PDF COMPONENT)
  // ==========================================================

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("INSIGHT MIND", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
            pw.Text("Laporan Kesehatan Mental & Biometrik", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.PdfLogo(), 
      ],
    );
  }

  static pw.Widget _buildSummary(List<ScreeningRecord> records) {
    // Hitung jumlah tipe
    int totalScreening = records.where((e) => !e.riskLevel.toLowerCase().contains('biometri')).length;
    int totalBiometric = records.where((e) => e.riskLevel.toLowerCase().contains('biometri')).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Aktivitas", "${records.length}"),
          _buildStatItem("Mental Screening", "$totalScreening"),
          _buildStatItem("Biometric Scan", "$totalBiometric"),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
      ],
    );
  }

  static pw.Widget _buildTable(List<ScreeningRecord> records) {
    return pw.TableHelper.fromTextArray(
      headers: ['Tanggal', 'Jam', 'Tipe Tes', 'Skor', 'Status'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      data: records.map((record) {
        // Format Tanggal
        final date = DateFormat('dd MMM yyyy', 'id_ID').format(record.timestamp);
        final time = DateFormat('HH:mm', 'id_ID').format(record.timestamp);
        
        // Cek Tipe berdasarkan teks risiko (Biometrik atau Screening)
        final isBiometric = record.riskLevel.toLowerCase().contains('biometri');
        
        final type = isBiometric ? "Biometric Scan" : "Kuesioner";
        // Jika Biometrik tampilkan BPM, jika Kuesioner tampilkan angka biasa
        final scoreDisplay = isBiometric 
            ? "${record.score.toStringAsFixed(0)} BPM" 
            : record.score.toStringAsFixed(0);

        return [
          date,
          time,
          type,
          scoreDisplay,
          record.riskLevel,
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Text(
          "Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}",
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.Text(
          "Disclaimer: Hasil ini merupakan analisis AI dan bukan diagnosa medis. Hubungi profesional untuk penanganan lebih lanjut.",
          style:  pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  // ==========================================================
  // UTILITIES
  // ==========================================================

  static PdfColor _getStatusColor(String risk) {
    if (risk.toLowerCase().contains("tinggi")) return PdfColors.red700;
    if (risk.toLowerCase().contains("sedang")) return PdfColors.orange700;
    return PdfColors.green700;
  }

  static String _getRecommendation(String risk) {
    if (risk.toLowerCase().contains("biometri")) {
      return "Hasil ini berdasarkan pengukuran detak jantung via kamera. Jika BPM terlalu tinggi/rendah saat istirahat, konsultasikan ke dokter.";
    }
    if (risk.toLowerCase().contains("tinggi")) {
      return "Indikasi stres tinggi. Segera hubungi profesional, ambil jeda istirahat, dan hindari pemicu stres berlebih.";
    } else if (risk.toLowerCase().contains("sedang")) {
      return "Indikasi tekanan mental ringan. Lakukan relaksasi, perbaiki pola tidur, dan kurangi penggunaan media sosial.";
    } else {
      return "Kondisi mental stabil. Pertahankan gaya hidup sehat dan tetap terhubung dengan orang-orang terdekat.";
    }
  }

  static Future<File> _saveDocument(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Membagikan file PDF
  static Future<void> shareReport(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Berikut adalah laporan riwayat kesehatan mental saya dari Insight Mind.',
    );
  }
}
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../entities/mental_result.dart';

class ReportGenerator {
  Future<Uint8List> createPdf(MentalResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              // PERBAIKAN: Gunakan nama parameter lengkap 'crossAxisAlignment'
              crossAxisAlignment: pw.CrossAxisAlignment.start, 
              children: [
                pw.Text("LAPORAN HASIL SCREENING INSIGHTMIND", 
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text("Detail Hasil:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text("Tingkat Risiko: ${result.riskLevel}"),
                pw.Text("Skor Akhir: ${result.score.toStringAsFixed(3)}"),
                pw.Text("Tingkat Kepercayaan AI: ${(result.confidence * 100).toStringAsFixed(1)}%"),
                pw.SizedBox(height: 30),
                pw.Text("Saran & Rekomendasi:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Silakan konsultasikan hasil ini dengan tenaga profesional kesehatan mental jika diperlukan."),
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Dicetak pada: ${DateTime.now().toString()}"),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
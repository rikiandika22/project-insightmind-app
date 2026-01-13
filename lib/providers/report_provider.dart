import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/report_service.dart';

final reportProvider = Provider((ref) => ReportController());

class ReportController {
  Future<void> processFullReport(double score, String risk) async {
    // Jalankan semua tugas Agung secara berurutan
    await ReportService.autoSaveResult(score, risk);
    final pdfFile = await ReportService.generatePdfReport(score, risk);
    await ReportService.shareReport(pdfFile);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/report_service.dart';

final reportProvider = Provider((ref) => ReportNotifier());

class ReportNotifier {
  Future<void> processFullReport(double score, String risk) async {
    // Jalankan Auto-save
    await ReportService.autoSaveResult(score, risk);
    
    // Generate PDF
    final pdfFile = await ReportService.generatePdfReport(score, risk);
    
    // Share
    await ReportService.shareReport(pdfFile);
  }
}
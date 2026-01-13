import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../domain/usecases/report_generator.dart';
import '../../domain/entities/mental_result.dart';

class ReportProvider extends ChangeNotifier {
  final ReportGenerator _generator = ReportGenerator();
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  Future<void> shareReport(MentalResult result) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final pdfBytes = await _generator.createPdf(result);
      
      // Menggunakan printing library untuk Share
      await Printing.sharePdf(
        bytes: pdfBytes, 
        filename: 'Report_InsightMind_${DateTime.now().millisecondsSinceEpoch}.pdf'
      );
    } catch (e) {
      debugPrint("Error sharing report: $e");
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
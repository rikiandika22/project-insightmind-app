import 'package:equatable/equatable.dart';

// MentalResult merepresentasikan hasil akhir prediksi risiko mental
// dari model AI, termasuk skor, level, dan keyakinan.
class MentalResult extends Equatable {
  // Skor akhir yang dihitung oleh model AI (biasanya antara 0.0 hingga 1.0)
  final double score; 

  // Tingkat risiko yang ditentukan setelah thresholding (e.g., 'Tinggi', 'Sedang', 'Rendah')
  final String riskLevel;
  
  // Pesan/Deskripsi risiko untuk ditampilkan kepada pengguna
  final String riskMessage;
  
  // Tingkat keyakinan model AI terhadap prediksinya (misalnya, 0.90 = 90% confidence)
  final double confidence;

  // Daftar saran tindakan nyata bagi pengguna berdasarkan hasil analisis
  final List<String> recommendations; // PERBAIKAN: Tambahkan field ini

  const MentalResult({
    required this.score, 
    required this.riskLevel,
    required this.riskMessage, 
    required this.confidence,
    required this.recommendations, // PERBAIKAN: Tambahkan ke konstruktor
  });

  // Equatable digunakan untuk membandingkan objek berdasarkan nilainya
  @override
  List<Object> get props => [
        score, 
        riskLevel, 
        riskMessage, 
        confidence,
        recommendations, // Tambahkan ke props agar perbandingan list akurat
      ];
}
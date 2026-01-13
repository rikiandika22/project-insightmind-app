import '../../domain/entities/feature_vector.dart';
import '../../domain/entities/mental_result.dart';
import '../../domain/usecases/predict_risk_ai.dart';

// Nilai bobot untuk Weighted Scoring
const double _wQuestionnaire = 0.5; // Bobot Kuesioner (50%)
const double _wHeartRate = 0.3;     // Bobot Sensor Jantung (30%)
const double _wSleepQuality = 0.2;  // Bobot Kualitas Tidur/Akselerometer (20%)

class PredictRiskAIImpl implements PredictRiskAI {
  
  @override
  Future<MentalResult> execute(FeatureVector vector) async {
    // 1. Logika Weighted Scoring & Normalisasi
    // Pastikan nilai input tidak membuat skor melampaui 1.0
    final double normalizedHR = (vector.heartRateBPM / 120).clamp(0.0, 1.0);
    final double normalizedSleep = (vector.sleepQualityIndex / 20).clamp(0.0, 1.0);
    final double normalizedQuest = (vector.questionnaireScore / 50).clamp(0.0, 1.0);

    final double finalScore = (normalizedQuest * _wQuestionnaire) +
        (normalizedHR * _wHeartRate) +
        (normalizedSleep * _wSleepQuality);

    // 2. Menghitung Confidence Score (Tingkat Keyakinan AI)
    // Jika data usia tersedia, keyakinan dianggap lebih tinggi
    double confidenceScore = (vector.ageGroup > 0) ? 0.92 : 0.78; 

    // 3. Mengatur Ambang Batas Risiko (Thresholding)
    String riskLevel = _calculateRiskLevel(finalScore);
    
    // 4. Menghasilkan Pesan Risiko (Deskripsi untuk User)
    String riskMessage = _generateRiskMessage(riskLevel);

    // 5. Menghasilkan Rekomendasi (Daftar Tindakan)
    List<String> recommendations = _generateRecommendations(riskLevel);

    // 6. Mengembalikan MentalResult dengan parameter lengkap sesuai Entity di Domain
    return MentalResult(
      score: finalScore,
      riskLevel: riskLevel,
      riskMessage: riskMessage, 
      confidence: confidenceScore,
      recommendations: recommendations,
    );
  }

  // Menentukan label risiko berdasarkan skor akhir
  String _calculateRiskLevel(double score) {
    if (score >= 0.70) return 'Tinggi';
    if (score >= 0.40) return 'Sedang';
    return 'Rendah';
  }

  // Membuat pesan deskriptif yang ramah pengguna
  String _generateRiskMessage(String level) {
    switch (level) {
      case 'Tinggi':
        return 'Hasil analisis menunjukkan indikasi tekanan emosional yang tinggi. Kami menyarankan Anda untuk beristirahat sejenak.';
      case 'Sedang':
        return 'Kondisi Anda saat ini berada dalam tingkat risiko sedang. Perhatikan pola istirahat dan manajemen stres Anda.';
      case 'Rendah':
        return 'Kondisi mental dan fisik Anda terpantau stabil. Pertahankan gaya hidup sehat yang sedang Anda jalankan.';
      default:
        return 'Data tidak cukup untuk menentukan analisis risiko.';
    }
  }

  // Daftar saran konkret yang akan ditampilkan di ResultPage
  List<String> _generateRecommendations(String level) {
    if (level == 'Tinggi') {
      return [
        'Hubungi konselor atau psikolog profesional',
        'Lakukan teknik pernapasan 4-7-8 selama 5 menit',
        'Kurangi konsumsi kafein dan layar gadget',
        'Cari lingkungan yang tenang untuk relaksasi'
      ];
    } else if (level == 'Sedang') {
      return [
        'Coba meditasi terbimbing di aplikasi',
        'Pastikan tidur malam minimal 7-8 jam',
        'Luangkan waktu untuk hobi atau jalan santai',
        'Tuliskan perasaan Anda dalam jurnal harian'
      ];
    } else {
      return [
        'Lanjutkan rutinitas olahraga Anda',
        'Pertahankan pola makan bergizi seimbang',
        'Lakukan interaksi sosial yang bermakna',
        'Praktikkan rasa syukur setiap pagi'
      ];
    }
  }
}
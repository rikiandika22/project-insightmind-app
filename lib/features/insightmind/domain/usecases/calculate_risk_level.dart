// lib/features/insightmind/domain/usecases/calculate_risk_level.dart

import '../entities/mental_result.dart';

class CalculateRiskLevel {
  
  static const int _riskRendahThreshold = 9;
  static const int _riskSedangThreshold = 14;

  MentalResult execute(int score) {
    if (score <= _riskRendahThreshold) {
      return MentalResult(
        score: score.toDouble(), 
        riskLevel: 'Rendah',
        riskMessage: 'Pertahankan kebiasaan baik, jaga tidur, makan dan olahraga.',
        confidence: 100.0, 
        recommendations: const [
          "Lanjutkan rutinitas positif Anda.",
          "Tetap jaga keseimbangan hidup.",
        ],
      );
    } else if (score <= _riskSedangThreshold) {
      return MentalResult(
        score: score.toDouble(),
        riskLevel: 'Sedang',
        riskMessage: 'Anda mungkin perlu istirahat. Coba teknik relaksasi dan kurangi stres.',
        confidence: 100.0,
        recommendations: const [
          "Lakukan latihan pernapasan.",
          "Kurangi begadang.",
          "Luangkan waktu untuk hobi.",
        ],
      );
    } else {
      // Skor > 14
      return MentalResult(
        score: score.toDouble(),
        riskLevel: 'Tinggi',
        riskMessage: 'Sebaiknya konsultasikan perasaan Anda dengan profesional. Jangan ragu mencari bantuan.',
        confidence: 100.0,
        recommendations: const [
          "Segera hubungi profesional (psikolog/konselor).",
          "Ceritakan masalah pada orang terdekat.",
          "Hindari menyendiri terlalu lama.",
        ],
      );
    }
  }
}
import '../entities/mental_result.dart';

class CalculateRiskLevel {
  
  static const int _riskRendahThreshold = 9;
  static const int _riskSedangThreshold = 14;

  MentalResult execute(int score) {
    if (score <= _riskRendahThreshold) {
      return MentalResult(
        score: score,
        riskLevel: 'Rendah',
        riskMessage: 'Pertahankan kebiasaan baik, jaga tidur, makan dan olahraga.',
      );
    } else if (score <= _riskSedangThreshold) {
      return MentalResult(
        score: score,
        riskLevel: 'Sedang',
        riskMessage: 'Anda mungkin perlu istirahat. Coba teknik relaksasi dan kurangi stres.',
      );
    } else {
      // (Skor di atas 14)
      return MentalResult(
        score: score,
        riskLevel: 'Tinggi',
        riskMessage: 'Sebaiknya konsultasikan perasaan Anda dengan profesional. Jangan ragu mencari bantuan.',
      );
    }
  }
}
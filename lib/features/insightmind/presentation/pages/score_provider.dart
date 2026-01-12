// lib/features/insightmind/presentation/providers/score_provider.dart (PEMBARUAN)

// ... import lainnya
import '../../../domain/entities/feature_vector.dart';
import '../../../domain/usecases/predict_risk_ai.dart';

// Pastikan Anda menginjeksikan (inject) implementasi PredictRiskAI 
// melalui constructor atau dependency injection (DI)

class ScoreProvider with ChangeNotifier {
  final PredictRiskAI _predictRiskAI;
  
  // Asumsikan data sensor dan kuesioner sudah dikumpulkan
  double _rawQuestionnaireScore = 0.0;
  double _currentHeartRate = 75.0; // Data Sensor
  double _currentSleepQuality = 0.8; // Data Sensor
  int _currentAgeGroup = 2; // Data Lain

  MentalResult? _result;

  ScoreProvider({required PredictRiskAI predictRiskAI})
      : _predictRiskAI = predictRiskAI;

  // Fungsi untuk memicu prediksi AI
  Future<void> calculateFinalRisk() async {
    // 1. Buat FeatureVector dari data yang ada
    final vector = FeatureVector(
      // Catatan: Pastikan _rawQuestionnaireScore dinormalisasi sebelum digunakan
      questionnaireScore: _rawQuestionnaireScore / 10.0, // Contoh normalisasi
      heartRateBPM: _currentHeartRate / 100.0, // Contoh normalisasi
      sleepQualityIndex: _currentSleepQuality,
      ageGroup: _currentAgeGroup,
    );
    
    // 2. Panggil Use Case AI
    _result = await _predictRiskAI.execute(vector);

    // Notifikasi UI
    notifyListeners();
  }

  // ... fungsi dan properti lainnya
}
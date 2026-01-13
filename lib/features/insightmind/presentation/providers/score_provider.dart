// lib/features/insightmind/presentation/providers/score_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pastikan path import ini benar. Jika merah, cek folder domain/entities Anda.
import '../../domain/entities/feature_vector.dart';
import '../../domain/entities/mental_result.dart';
import '../../domain/usecases/predict_risk_ai.dart';
import 'sensors_provider.dart';

/// ---------------------------------------------------------------------------
/// 1. STATE MODEL
/// ---------------------------------------------------------------------------
class ScoreState {
  final MentalResult? result;
  final bool isLoading;
  final String? errorMessage;

  ScoreState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  ScoreState copyWith({
    MentalResult? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScoreState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. GLOBAL PROVIDERS
/// ---------------------------------------------------------------------------

// Provider untuk menyimpan list jawaban kuesioner
final answersProvider = StateProvider<List<int>>((ref) => []);

// Provider untuk status screening (Full vs Sensor Only)
final isFullScreeningProvider = StateProvider<bool>((ref) => false);

// Provider untuk kalkulasi skor kuesioner (Logic decoupled dari UI)
final rawQuestionnaireScoreProvider = Provider<double>((ref) {
  final answers = ref.watch(answersProvider);
  if (answers.isEmpty) return 0.0;
  return answers.fold(0, (sum, element) => sum + element).toDouble();
});

// Provider utama untuk memantau status prediksi AI
final scoreProvider = StateNotifierProvider<ScoreNotifier, ScoreState>((ref) {
  final predictRiskAI = ref.watch(predictRiskAIProvider); 
  return ScoreNotifier(predictRiskAI, ref);
});

// Provider untuk Dependency Injection Use Case
final predictRiskAIProvider = Provider<PredictRiskAI>((ref) => PredictRiskAIImpl());


/// ---------------------------------------------------------------------------
/// 3. NOTIFIER LOGIC
/// ---------------------------------------------------------------------------
class ScoreNotifier extends StateNotifier<ScoreState> {
  final PredictRiskAI _predictRiskAI;
  final Ref _ref;

  ScoreNotifier(this._predictRiskAI, this._ref) : super(ScoreState());

  Future<void> calculateFinalRisk() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Mengambil data terbaru dari provider lain (Sensors & Questionnaire)
      final ppgData = _ref.read(ppgProvider);
      final accelData = _ref.read(accelFeatureProvider);
      final isFull = _ref.read(isFullScreeningProvider);
      
      final rawScore = isFull ? _ref.read(rawQuestionnaireScoreProvider) : 0.0;

      // Konstruksi Vektor Fitur untuk input model AI
      final vector = FeatureVector(
        questionnaireScore: rawScore, 
        heartRateBPM: ppgData.mean > 0 ? ppgData.mean : 72.0, 
        sleepQualityIndex: accelData.variance, 
        ppgMean: ppgData.mean > 0 ? ppgData.mean : 0.5,
        accelFeatVariance: accelData.variance,
        ageGroup: 1, 
      );

      // Menjalankan Use Case Prediksi
      final result = await _predictRiskAI.execute(vector);
      
      // Update state dengan data sukses
      state = state.copyWith(result: result, isLoading: false);
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: "Gagal memproses data AI: ${e.toString()}"
      );
    }
  }

  void reset() {
    state = ScoreState();
  }
}

/// ---------------------------------------------------------------------------
/// 4. MOCK IMPLEMENTATION (Sinkron dengan MentalResult Entity)
/// ---------------------------------------------------------------------------
class PredictRiskAIImpl implements PredictRiskAI {
  @override
  Future<MentalResult> execute(FeatureVector vector) async {
    // Simulasi waktu proses server/model AI
    await Future.delayed(const Duration(seconds: 2));

    // Logika kalkulasi sederhana (Mockup)
    double calculatedScore = (vector.questionnaireScore * 0.7) + (vector.heartRateBPM * 0.05);
    
    String level;
    String message;
    List<String> advice;

    if (calculatedScore > 15) {
      level = "Tinggi";
      message = "Hasil menunjukkan tingkat stres atau risiko mental yang signifikan.";
      advice = ["Segera konsultasi dengan psikolog profesional", "Praktikkan teknik pernapasan 4-7-8"];
    } else if (calculatedScore > 8) {
      level = "Sedang";
      message = "Terdapat indikasi kelelahan mental ringan hingga sedang.";
      advice = ["Lakukan meditasi 10 menit", "Kurangi waktu layar (screen time) sebelum tidur"];
    } else {
      level = "Rendah";
      message = "Kondisi mental Anda terpantau stabil dan sehat.";
      advice = ["Pertahankan pola tidur teratur", "Lanjutkan aktivitas olahraga rutin"];
    }

    // Mengembalikan objek MentalResult dengan parameter lengkap (Menghindari Error Required Parameter)
    return MentalResult(
      score: calculatedScore,
      riskLevel: level,
      riskMessage: message,
      confidence: 0.95,
      recommendations: advice,
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Imports dari Data & Domain Layer ---
import '../../domain/entities/feature_vector.dart';
import '../../domain/entities/mental_result.dart';
import '../../data/local/screening_record.dart'; // Import Model Hive

// Use Case (Kontrak & Implementasi)
import '../../domain/usecases/predict_risk_ai.dart'; 
import '../../data/repositories/predict_risk_ai_impl.dart';

// Repositori Data
import '../../data/repositories/score_repository.dart';
import '../../data/repositories/history_repository.dart';

// =========================================================================
// 1. STATE DASAR (INPUT)
// =========================================================================

/// StateProvider untuk menyimpan daftar jawaban kuesioner mentah dari UI.
final answersProvider = StateProvider<List<int>>((ref) => []);

// =========================================================================
// 2. DEPENDENCY INJECTION (DI)
// =========================================================================

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final predictRiskAIImplProvider = Provider<PredictRiskAI>((ref) {
  return PredictRiskAIImpl(); 
});

// =========================================================================
// 3. LOGIKA PEMROSESAN (SKOR MENTAH)
// =========================================================================

final rawQuestionnaireScoreProvider = Provider<double>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  final answers = ref.watch(answersProvider);
  
  if (answers.isEmpty) return 0.0;
  return repo.calculateScore(answers).toDouble();
});

// =========================================================================
// 4. LOGIKA UTAMA (PREDIKSI AI + PENYIMPANAN RIWAYAT)
// =========================================================================

final resultProvider = FutureProvider.family<MentalResult, FeatureVector>((ref, fv) async {
  final aiPredictor = ref.watch(predictRiskAIImplProvider);
  final historyRepo = ref.watch(historyRepositoryProvider);
  
  // Simulasi waktu loading agar transisi UI terasa natural
  await Future.delayed(const Duration(milliseconds: 1500)); 

  try {
      // 1. Eksekusi Prediksi AI (Hasil berupa MentalResult Entity)
      final result = await aiPredictor.execute(fv);

      // 2. OTOMATIS SIMPAN KE RIWAYAT (Mapping ke ScreeningRecord di dalam repo)
      await historyRepo.saveToHistory(result);

      // 3. Refresh provider riwayat agar list di UI langsung terupdate
      // Kita panggil invalidate pada provider yang ada di history_providers.dart
      ref.invalidate(historyListProvider);

      return result;
  } catch (e) {
      throw Exception('Gagal menghitung risiko mental: ${e.toString()}');
  }
});

// =========================================================================
// 5. PROVIDER UNTUK HALAMAN RIWAYAT (DATA DARI HIVE)
// =========================================================================

/// Provider ini mengambil data dalam bentuk ScreeningRecord (Model Database)
/// agar sinkron dengan tipe data yang ada di Hive.
final historyListProvider = FutureProvider<List<ScreeningRecord>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  
  // PERBAIKAN: Memanggil getAllRecords() sesuai nama di repository terbaru
  return await repo.getAllRecords();
});
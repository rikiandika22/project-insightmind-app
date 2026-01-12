import '../entities/feature_vector.dart';
import '../entities/mental_result.dart';

/// PredictRiskAI adalah Use Case (Contract) untuk memproses data biometrik
/// dan kuesioner menjadi hasil analisis risiko kesehatan mental.
/// 
/// Sesuai prinsip Clean Architecture, file di layer Domain hanya berisi 
/// Abstract Class agar tidak tergantung pada implementasi tertentu.
abstract class PredictRiskAI {
  
  /// Menjalankan analisis AI berdasarkan [FeatureVector] yang dikirimkan.
  /// Mengembalikan [MentalResult] yang berisi skor, tingkat risiko, dan saran.
  Future<MentalResult> execute(FeatureVector vector);
}
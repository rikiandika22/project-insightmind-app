// lib/features/insightmind/data/models/history_model.dart

import 'package:equatable/equatable.dart';

// Model yang digunakan untuk menyimpan hasil skrining ke database lokal (misalnya Hive/SQLite)
class HistoryModel extends Equatable {
  final int id;
  // SCORE harus bertipe DOUBLE agar kompatibel dengan MentalResult.score
  final double score; 
  final String riskLevel;
  final DateTime timestamp;

  const HistoryModel({
    required this.id,
    required this.score,
    required this.riskLevel,
    required this.timestamp,
  });

  // Metode untuk mengkonversi dari Model ke Entity
  // (Jika diperlukan di Data Layer)
  // HistoryEntity toEntity() {
  //   return HistoryEntity(
  //     score: score,
  //     riskLevel: riskLevel,
  //     timestamp: timestamp,
  //   );
  // }

  @override
  List<Object> get props => [id, score, riskLevel, timestamp];
}
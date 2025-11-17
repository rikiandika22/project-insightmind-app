// lib/features/insightmind/data/local/screening_record.dart

import 'package:hive/hive.dart';

// Jalankan build_runner untuk membuat file ini
part 'screening_record.g.dart';

@HiveType(typeId: 0) // Beri ID unik untuk model ini
class ScreeningRecord extends HiveObject {
  
  @HiveField(0) // Kolom 0
  final String id;

  @HiveField(1) // Kolom 1
  final DateTime timestamp;

  @HiveField(2) // Kolom 2
  final int score;

  @HiveField(3) // Kolom 3
  final String riskLevel;
  
  // (Anda bisa tambahkan riskMessage di sini jika mau)
  // @HiveField(4)
  // final String riskMessage; 

  ScreeningRecord({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.riskLevel,
  });
}
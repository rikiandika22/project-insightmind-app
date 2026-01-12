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

  @HiveField(2) // Kolom 2: PERBAIKAN TIPE DATA INT -> DOUBLE
  final double score; 

  @HiveField(3) // Kolom 3
  final String riskLevel;
  
  // TAMBAHAN: Menyimpan pesan risiko
  @HiveField(4)
  final String riskMessage;
  
  // TAMBAHAN: Menyimpan confidence score
  @HiveField(5)
  final double confidence; 

  ScreeningRecord({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.riskLevel,
    required this.riskMessage, // <--- Diperlukan jika ditambahkan
    required this.confidence,  // <--- Diperlukan jika ditambahkan
  });
}
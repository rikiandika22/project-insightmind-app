import 'package:hive/hive.dart';

part 'screening_record.g.dart'; // Pastikan nama file ini sesuai

@HiveType(typeId: 0) // Pastikan typeId unik
class ScreeningRecord extends HiveObject {
  @HiveField(0)
  final String id; // ID Unik

  @HiveField(1)
  final double score;

  @HiveField(2)
  final String riskLevel;

  @HiveField(3)
  final DateTime date; // Kita pakai bahasa Inggris standar: 'date'

  ScreeningRecord({
    required this.id,
    required this.score,
    required this.riskLevel,
    required this.date,
  });
}
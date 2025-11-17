// lib/features/insightmind/data/repositories/history_repository.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../local/screening_record.dart';
import '../../domain/entities/mental_result.dart';

class HistoryRepository {
  // Nama Box harus SAMA dengan yang dibuka di main.dart
  static const String _boxName = 'screening_records';

  // Dapatkan Box yang sudah dibuka
  Box<ScreeningRecord> _getBox() => Hive.box<ScreeningRecord>(_boxName);

  // CREATE: Tambah satu record
  Future<void> addRecord(MentalResult result) async {
    final box = _getBox();
    final newId = const Uuid().v4(); // Buat ID unik

    final newRecord = ScreeningRecord(
      id: newId,
      timestamp: DateTime.now(), // Waktu saat ini
      score: result.score,
      riskLevel: result.riskLevel,
      // riskMessage: result.riskMessage, // (Tambahkan ini jika Anda simpan)
    );

    // Simpan ke database menggunakan ID sebagai key
    await box.put(newId, newRecord);
  }

  // READ: Ambil semua record
  Future<List<ScreeningRecord>> getAllRecords() async {
    final box = _getBox();
    final records = box.values.toList();

    // Urutkan: yang terbaru di atas
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  // DELETE: Hapus satu record
  Future<void> deleteRecord(String id) async {
    final box = _getBox();
    await box.delete(id);
  }

  // DELETE ALL: Kosongkan box
  Future<void> clearAll() async {
    final box = _getBox();
    await box.clear();
  }
}
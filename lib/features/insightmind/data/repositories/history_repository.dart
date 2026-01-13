import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../local/screening_record.dart';
import '../../domain/entities/mental_result.dart';

class HistoryRepository {
  static const String _boxName = 'screening_records';

  // Helper untuk buka Box
  Future<Box<ScreeningRecord>> _getOpenBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ScreeningRecord>(_boxName);
    }
    return Hive.box<ScreeningRecord>(_boxName);
  }

  // PERBAIKAN: Pastikan namanya 'getAllRecords'
  Future<List<ScreeningRecord>> getAllRecords() async {
    final box = await _getOpenBox();
    final records = box.values.toList();
    // Urutkan: terbaru di atas
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  // PERBAIKAN: Pastikan namanya 'clearAll'
  Future<void> clearAll() async {
    final box = await _getOpenBox();
    await box.clear();
  }

  // Fungsi simpan tetap ada
  Future<void> saveToHistory(MentalResult result) async {
    final box = await _getOpenBox();
    final newId = const Uuid().v4();

    final newRecord = ScreeningRecord(
      id: newId,
      timestamp: DateTime.now(),
      score: result.score,
      riskLevel: result.riskLevel,
      riskMessage: result.riskMessage,
      confidence: result.confidence,
    );

    await box.put(newId, newRecord);
  }

  // Fungsi hapus satu data
  Future<void> deleteRecord(String targetId) async {
    final box = await _getOpenBox();
    
    // 1. Cari Key Hive yang asli berdasarkan targetId
    // Kita looping keys-nya untuk mencocokkan field 'id' di dalam datanya
    final keyToDelete = box.keys.firstWhere(
      (k) {
        final record = box.get(k);
        return record?.id == targetId;
      }, 
      orElse: () => null
    );

    // 2. Jika Key ketemu, hapus berdasarkan Key tersebut
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
      print("Berhasil menghapus record dengan ID: $targetId (Key: $keyToDelete)");
    } else {
      print("Gagal: ID $targetId tidak ditemukan di dalam Box.");
    }
  }
}
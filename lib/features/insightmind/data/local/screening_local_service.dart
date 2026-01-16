import 'package:hive_flutter/hive_flutter.dart';
import 'screening_record.dart';

class ScreeningLocalService {
  // Nama box harus sama dengan yang kita pakai di ReportService
  static const String _boxName = 'screening_records';

  /// Simpan data ke Hive (Database Lokal)
  Future<void> saveRecord(ScreeningRecord record) async {
    // Buka box (database)
    final box = await Hive.openBox<ScreeningRecord>(_boxName);
    
    // Simpan objek langsung (Hive tidak butuh toJson)
    await box.add(record);
    
    // Opsional: print untuk debug
    print("Data berhasil disimpan ke Hive: ${record.id}");
  }

  /// Ambil semua data dari Hive
  Future<List<ScreeningRecord>> getHistory() async {
    // Buka box
    final box = await Hive.openBox<ScreeningRecord>(_boxName);
    
    // Ambil semua data dan jadikan List
    // Kita cast ke List<ScreeningRecord> agar aman
    List<ScreeningRecord> history = box.values.toList().cast<ScreeningRecord>();
    
    // Urutkan dari yang terbaru (opsional, tapi bagus untuk UX)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return history;
  }
  
  /// (Opsional) Menghapus seluruh riwayat
  Future<void> clearHistory() async {
    final box = await Hive.openBox<ScreeningRecord>(_boxName);
    await box.clear();
  }
}
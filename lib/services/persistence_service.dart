import 'package:hive_flutter/hive_flutter.dart';

class PersistenceService {
  static const String boxName = 'screening_results';

  // Fungsi untuk menyimpan hasil screening secara otomatis
  static Future<void> saveScreening(Map<String, dynamic> data) async {
    var box = Hive.box(boxName);
    
    // Menambahkan timestamp agar data tercatat waktunya
    data['timestamp'] = DateTime.now().toIso8601String();
    
    await box.add(data);
    print("Data berhasil disimpan otomatis ke lokal.");
  }

  // Mengambil semua riwayat untuk ditampilkan di grafik (Tugas Rahman)
  static List<dynamic> getAllHistory() {
    var box = Hive.box(boxName);
    return box.values.toList();
  }
}
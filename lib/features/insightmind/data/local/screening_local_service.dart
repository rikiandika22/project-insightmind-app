import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../local/screening_record.dart';

class ScreeningLocalService {
  static const String _key = 'screening_history';

  // Simpan hasil secara otomatis
  Future<void> saveRecord(ScreeningRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    // Convert record ke JSON string
    history.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_key, history);
  }

  // Ambil semua data histori
  Future<List<ScreeningRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    return history.map((item) => ScreeningRecord.fromJson(jsonDecode(item))).toList();
  }
}
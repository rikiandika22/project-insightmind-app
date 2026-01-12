import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/local/screening_record.dart';

/// 1. Provider untuk Repository
/// Menyediakan instance HistoryRepository agar bisa digunakan oleh provider lain atau UI.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// 2. Provider untuk Daftar Riwayat (List)
/// FutureProvider ini mengambil data dari Hive melalui Repository.
/// Menggunakan .autoDispose agar data di-reset saat pindah halaman.
final historyListProvider = FutureProvider.autoDispose<List<ScreeningRecord>>((ref) async {
  // Mengambil instance repository
  final repo = ref.watch(historyRepositoryProvider);
  
  // Memanggil fungsi getAllRecords (Pastikan nama ini ada di HistoryRepository)
  return await repo.getAllRecords();
});

/// 3. Helper Provider untuk Menghitung Jumlah Riwayat
final historyCountProvider = Provider.autoDispose<int>((ref) {
  final historyAsync = ref.watch(historyListProvider);
  return historyAsync.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});
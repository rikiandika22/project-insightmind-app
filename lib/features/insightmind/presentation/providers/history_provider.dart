// lib/features/insightmind/presentation/providers/history_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/local/screening_record.dart';

// 1. Provider untuk Repository
// Ini hanya membuat instance dari repository
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

// 2. Provider untuk Daftar Riwayat
// Ini adalah FutureProvider yang memanggil repo dan mengambil data
final historyListProvider = FutureProvider<List<ScreeningRecord>>((ref) async {
  // Dapatkan repo
  final repo = ref.watch(historyRepositoryProvider);
  // Panggil fungsi untuk mengambil semua data
  return repo.getAllRecords();
});
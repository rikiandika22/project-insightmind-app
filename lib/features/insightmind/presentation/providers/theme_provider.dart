// lib/features/insightmind/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider ini yang akan dipanggil di UI dan Main
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// 2. Class logika pengatur tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Default saat aplikasi dibuka: Ikuti pengaturan HP (System)
  ThemeNotifier() : super(ThemeMode.system);

  // Fungsi ganti tema
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
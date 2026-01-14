// lib/features/insightmind/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  // Fungsi untuk mengubah tema
  void toggleTheme(bool isDark) {
    // Memberikan delay sangat singkat (10ms) bisa membantu kestabilan transisi di beberapa device
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Fungsi tambahan untuk kembali ke pengaturan sistem
  void setSystemTheme() {
    state = ThemeMode.system;
  }
}
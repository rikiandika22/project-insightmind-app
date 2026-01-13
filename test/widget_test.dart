// Lokasi: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/app.dart';

void main() {
  testWidgets('FAB opens dialog, enters value, and adds a Chip', (
    WidgetTester tester,
  ) async {
    // 1. Build aplikasi
    await tester.pumpWidget(const ProviderScope(child: InsightMindApp()));

    // 2. Pastikan halaman awal benar dan tidak ada Chip
    expect(find.textContaining('Simulasi Jawaban'), findsOneWidget);
    expect(find.byType(Chip), findsNothing);

    // [FIX] Ini adalah alur tes yang benar untuk dialog

    // 3. Tekan tombol FAB
    await tester.tap(find.byIcon(Icons.add));
    // 4. Tunggu dialog selesai muncul
    await tester.pumpAndSettle();

    // 5. Pastikan dialognya benar-benar muncul
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Masukkan nilai 0-3'), findsOneWidget);

    // 6. Masukkan angka '2' ke dalam TextField
    await tester.enterText(find.byType(TextField), '2');

    // 7. Tekan tombol "OK"
    await tester.tap(find.text('OK'));
    // 8. Tunggu dialognya hilang dan halaman di-refresh
    await tester.pumpAndSettle();

    // 9. Sekarang, pastikan Chip-nya muncul
    expect(find.byType(Chip), findsOneWidget);
    // 10. Pastikan juga isi Chip-nya adalah '2'
    expect(find.text('2'), findsOneWidget);
  });
}

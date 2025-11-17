// lib/features/insightmind/presentation/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal

// Import provider dan model data kita
import '../providers/history_provider.dart';
import '../../data/local/screening_record.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Pantau provider riwayat
    final historyListAsync = ref.watch(historyListProvider);
    final Color primaryRed = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Screening'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F8FA), // Background abu-abu muda
      
      // 2. Gunakan .when() untuk handle state data, loading, dan error
      body: historyListAsync.when(
        
        // --- STATE DATA BERHASIL ---
        data: (items) {
          // Jika tidak ada item
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat screening tersimpan.'),
            );
          }

          // Jika ada item, tampilkan ListView
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final record = items[index];
              // Format tanggal agar mudah dibaca
              final formattedDate = DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                  .format(record.timestamp);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    'Skor: ${record.score} (Risiko ${record.riskLevel})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                  subtitle: Text('Diambil pada: $formattedDate\nID: ${record.id}'), // Tampilkan ID (opsional)
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey[600]),
                    tooltip: 'Hapus item ini',
                    onPressed: () async {
                      // 4. Logika Hapus per item
                      // Panggil repo untuk menghapus
                      await ref
                          .read(historyRepositoryProvider)
                          .deleteRecord(record.id);
                      // Refresh provider agar UI update
                      ref.refresh(historyListProvider); 
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Satu item riwayat dihapus.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },

        // --- STATE LOADING ---
        loading: () => const Center(child: CircularProgressIndicator()),

        // --- STATE ERROR ---
        error: (e, stack) => Center(child: Text('Error memuat data: $e')),
      ),

      // 3. Tombol "Kosongkan Semua" di bawah
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Kosongkan Semua Riwayat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              // 5. Logika Hapus Semua
              final bool? ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text(
                      'Anda yakin ingin menghapus semua riwayat? Tindakan ini tidak dapat dibatalkan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              // Jika user menekan "Hapus"
              if (ok == true) {
                await ref.read(historyRepositoryProvider).clearAll();
                ref.refresh(historyListProvider); // Refresh UI
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua riwayat telah dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
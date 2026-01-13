// lib/features/insightmind/presentation/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Pastikan path import ini sesuai dengan folder Anda
import '../providers/history_provider.dart';
import '../../data/local/screening_record.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  // [LOGIKA WARNA] Helper untuk warna Teks/Icon berdasarkan risiko & tema
  Color _getRiskColor(String riskLevel, bool isDarkMode) {
    final risk = riskLevel.toLowerCase();
    if (risk.contains('tinggi')) {
      return isDarkMode ? Colors.redAccent.shade100 : Colors.red.shade700;
    }
    if (risk.contains('sedang')) {
      return isDarkMode ? Colors.orangeAccent.shade100 : Colors.orange.shade800;
    }
    // Rendah / Normal
    return isDarkMode ? Colors.greenAccent.shade100 : Colors.green.shade700;
  }

  // [LOGIKA WARNA] Helper untuk Background Kartu agar tidak silau di Dark Mode
  Color _getCardBackgroundColor(String riskLevel, bool isDarkMode) {
    final risk = riskLevel.toLowerCase();
    
    if (isDarkMode) {
      // Warna Gelap (Transparan) untuk Dark Mode
      if (risk.contains('tinggi')) return Colors.red.withOpacity(0.15);
      if (risk.contains('sedang')) return Colors.orange.withOpacity(0.15);
      return Colors.green.withOpacity(0.15);
    } else {
      // Warna Terang (Pastel) untuk Light Mode
      if (risk.contains('tinggi')) return Colors.red.shade50;
      if (risk.contains('sedang')) return Colors.orange.shade50;
      return Colors.green.shade50;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyListAsync = ref.watch(historyListProvider);
    
    // [DETEKSI TEMA]
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Variabel warna umum
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final appBarColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Riwayat Screening',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textColor), // Warna icon back/menu
      ),
      
      body: historyListAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat tersimpan.',
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = items[index];
              
              // Format Tanggal
              String formattedDate;
              try {
                formattedDate = DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                    .format(record.timestamp);
              } catch (e) {
                formattedDate = record.timestamp.toString().substring(0, 16);
              }

              return Dismissible(
                key: Key(record.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[900], // Merah gelap saat di-swipe
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmDialog(context, isDarkMode);
                },
                onDismissed: (direction) {
                  _deleteItem(context, ref, record.id);
                },
                child: Card(
                  elevation: 0,
                  // Gunakan helper warna kartu yang baru
                  color: _getCardBackgroundColor(record.riskLevel, isDarkMode),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      // Border tipis agar terlihat rapi di dark mode
                      color: _getRiskColor(record.riskLevel, isDarkMode).withOpacity(0.3), 
                      width: 1
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // CHIP STATUS RISIKO
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRiskColor(record.riskLevel, isDarkMode),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                record.riskLevel,
                                style: TextStyle(
                                  // Teks di dalam chip selalu putih/kontras
                                  color: isDarkMode ? Colors.black87 : Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                            // TOMBOL SAMPAH KECIL
                            InkWell(
                              onTap: () async {
                                final confirm = await _showDeleteConfirmDialog(context, isDarkMode);
                                if (confirm == true) {
                                  _deleteItem(context, ref, record.id);
                                }
                              },
                              child: Icon(Icons.delete_outline, 
                                color: subTextColor, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // SKOR
                        Row(
                          children: [
                            Text(
                              "Skor: ${record.score.toStringAsFixed(1)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor, // Warna skor adaptif
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // TANGGAL
                        Text(
                          "Diambil pada: $formattedDate",
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                        
                        // ID (Opsional, kecil)
                        const SizedBox(height: 4),
                        Text(
                          "ID: ${record.id}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e', style: TextStyle(color: textColor))),
      ),

      // TOMBOL HAPUS SEMUA (Footer)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Warna tombol adaptif
              backgroundColor: isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red, width: 1),
              ),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  title: Text('Hapus Semua Data?', style: TextStyle(color: textColor)),
                  content: Text('Tindakan ini tidak bisa dibatalkan.', style: TextStyle(color: subTextColor)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(historyRepositoryProvider).clearAll();
                ref.invalidate(historyListProvider); 
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua riwayat berhasil dikosongkan")),
                  );
                }
              }
            },
            child: const Text("Kosongkan Semua Riwayat", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // LOGIKA HAPUS ITEM
  Future<void> _deleteItem(BuildContext context, WidgetRef ref, String id) async {
    await ref.read(historyRepositoryProvider).deleteRecord(id);
    ref.invalidate(historyListProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil dihapus"), duration: Duration(seconds: 2)),
      );
    }
  }

  // DIALOG KONFIRMASI (Adaptif)
  Future<bool?> _showDeleteConfirmDialog(BuildContext context, bool isDarkMode) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Hapus Data Ini?', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: Text('Data yang dihapus tidak dapat dikembalikan.', 
          style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.black87)),
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
  }
}
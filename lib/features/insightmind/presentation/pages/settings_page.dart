import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart'; // Import untuk fitur Reset Data


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau status tema (Gelap/Terang)
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    
    // Warna Background (Abu-abu muda seperti di gambar)
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F5F7);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: cardColor,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          
          // --- BAGIAN 1: PERSONALISASI ---
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 5),
            child: Text("Personalisasi", 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Mode gelap", style: TextStyle(fontWeight: FontWeight.w600)),
                  secondary: Icon(Icons.dark_mode_outlined, color: Colors.purple.shade300),
                  value: isDarkMode,
                  activeColor: Colors.purple,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- BAGIAN 2: TENTANG APLIKASI ---
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 5),
            child: Text("Tentang Aplikasi", 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.psychology, color: Colors.red),
                  ),
                  title: const Text("Insight Mind", style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: const Text("v 1.0", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),
                // CONTOH SARAN FITUR: PROFIL KELOMPOK
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.groups, color: Colors.blue),
                  ),
                  title: const Text("Tim Pengembang", style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    _showTeamDialog(context); // Tampilkan Dialog Anggota
                  },
                ),
              ],
            ),
          ),

           const SizedBox(height: 24),

          // --- BAGIAN 3: MANAJEMEN DATA (Sangat Berguna saat Demo) ---
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 5),
            child: Text("Data & Privasi", 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
           Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_forever, color: Colors.orange),
              ),
              title: const Text("Reset Aplikasi", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
              subtitle: const Text("Hapus semua riwayat screening"),
              onTap: () async {
                 _showResetConfirmDialog(context, ref);
              },
            ),
          ),

          const SizedBox(height: 40),

          // --- FOOTER DISCLAIMER (Seperti di Gambar) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "InsightMind adalah aplikasi pemantauan kesehatan mental berbasis AI On-Device yang mengutamakan privasi pengguna. Aplikasi ini menggunakan model Rule-Based AI dengan metode Weighted Scoring untuk mendeteksi tingkat risiko stres secara cepat dan aman langsung di perangkat Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LOGIKA POPUP ---

  void _showTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tim InsightMind"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. Muhamad Dava Maulana (5230411281) - AI Dev"),
            SizedBox(height: 8),
            Text("2. Muhammad Aulia Rahman  (5230411308) - UI/UX"),
            SizedBox(height: 8),
            Text("3. Muhammad Agung Hendi Irawan (5230411312) - Backend"),
            SizedBox(height: 8),
            Text("4. Riki Andika Khusna Saputra (5230411280) - QA/DevOps"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup"))],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Semua Data?"),
        content: const Text("Aplikasi akan kembali bersih seperti baru diinstall. Tindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              // Panggil fungsi Clear All dari Repository
              await ref.read(historyRepositoryProvider).clearAll();
              ref.invalidate(historyListProvider); // Refresh UI
              if(context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aplikasi berhasil di-reset!")));
              }
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
// lib/features/insightmind/presentation/pages/result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // [BARU] Untuk database

// Import entitas dan provider
import '../../domain/entities/feature_vector.dart'; 
import '../../domain/entities/mental_result.dart'; 
import '../providers/score_provider.dart'; 

// [BARU] Import Model Database & Halaman Analisis
import '../../data/local/screening_record.dart';
import 'analisis_page.dart'; 

class ResultPage extends ConsumerWidget {
  final FeatureVector featureVector; 

  const ResultPage({
    super.key,
    required this.featureVector,
  });

  // --- LOGIKA REKOMENDASI & WARNA (Sama seperti sebelumnya) ---
  String _getRecommendation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'tinggi':
        return 'Pertimbangkan berbicara dengan konselor/psikolog. Kurangi beban, istirahat cukup, dan hubungi layanan dukungan profesional secepatnya.';
      case 'sedang':
        return 'Lakukan aktivitas relaksasi (napas dalam, olahraga ringan), atur waktu, dan evaluasi beban kuliah/kerja. Perhatikan perubahan suasana hati.';
      case 'rendah':
        return 'Pertahankan kebiasaan baik. Jaga tidur, makan, dan olahraga yang teratur. Rutin melakukan mindfulness.';
      default:
        return 'Hasil skrining tidak terdefinisi.';
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'tinggi': return Colors.red.shade700;
      case 'sedang': return Colors.orange.shade700;
      case 'rendah': return Colors.green.shade700;
      default: return Colors.grey;
    }
  }

  // --- [BARU] FUNGSI PENYIMPANAN KE HIVE ---
  void _saveAndNavigate(BuildContext context, MentalResult result) {
    // 1. Ambil Box Hive
    final box = Hive.box<ScreeningRecord>('screening_records');

    // 2. Buat Data Record Baru
    final newRecord = ScreeningRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      score: result.score,
      riskLevel: result.riskLevel,
      riskMessage: _getRecommendation(result.riskLevel), // Simpan rekomendasi
      confidence: result.confidence,
    );

    // 3. Simpan ke Database
    box.add(newRecord);

    // 4. Feedback Snack Bar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hasil tersimpan di Riwayat!"),
        backgroundColor: Colors.indigo,
        duration: Duration(seconds: 1),
      ),
    );

    // 5. Navigasi ke AnalisisPage
    // Menggunakan pushReplacement agar user tidak back ke result page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalisisPage()),
    );
  }

  // --- UI KONTEN ---
  Widget _buildContent(BuildContext context, MentalResult result) {
    final recommendation = _getRecommendation(result.riskLevel);
    final riskColor = _getRiskColor(result.riskLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.psychology_alt, size: 60, color: Colors.indigo),
          const SizedBox(height: 16),
          
          Text(
            'Tingkat Risiko Anda:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            result.riskLevel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
          ),
          const Divider(height: 32),

          // Detail Scoring
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(context, 'Final Score:', result.score.toStringAsFixed(3)),
                  const Divider(),
                  _buildDetailRow(context, 'Kepercayaan AI:', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Rekomendasi
          Text(
            'Rekomendasi Kami:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: riskColor.withOpacity(0.5)),
            ),
            child: Text(
              recommendation,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          const SizedBox(height: 32),

          // --- [BARU] TOMBOL AKSI SIMPAN ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveAndNavigate(context, result),
              icon: const Icon(Icons.save_as_rounded),
              label: const Text("Simpan & Lihat Dashboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tombol alternatif kembali ke beranda
          TextButton(
             onPressed: () {
               // Pop sampai halaman pertama (Home)
               Navigator.of(context).popUntil((route) => route.isFirst);
             },
             child: const Text("Kembali ke Beranda (Tanpa Simpan)"),
          ),

          const SizedBox(height: 24),
          const Text(
            '*Disclaimer: InsightMind bersifat edukatif, bukan alat diagnosis medis. Hasil ini dihasilkan oleh model AI berdasarkan kuesioner dan data sensor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memanggil provider dengan FeatureVector
    final resultAsync = ref.watch(resultProvider(featureVector)); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: Colors.indigo, 
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hilangkan tombol back default agar user pakai tombol bawah
      ),
      body: resultAsync.when(
        data: (result) => _buildContent(context, result),
        
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 16),
              Text('Menghitung risiko dengan model AI...', style: TextStyle(color: Colors.indigo)),
            ],
          ),
        ),
        
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Terjadi kesalahan:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kembali"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
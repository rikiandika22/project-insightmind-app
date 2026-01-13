// lib/features/insightmind/presentation/pages/result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import entitas dan provider yang diperlukan
import '../../domain/entities/feature_vector.dart'; 
import '../../domain/entities/mental_result.dart'; 
// Asumsi: resultProvider adalah FutureProvider.family<MentalResult, FeatureVector>
// Jika Anda tidak menggunakan family, Anda perlu membuat StateProvider<FeatureVector> terpisah
import '../providers/score_provider.dart'; 

// [PERBAIKAN KRITIS]: Menerima FeatureVector di Constructor
class ResultPage extends ConsumerWidget {
  final FeatureVector featureVector; // Data input dari BiometricPage

  const ResultPage({
    super.key,
    required this.featureVector,
  });

  // Fungsi utilitas untuk menentukan rekomendasi berdasarkan level risiko
  String _getRecommendation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'tinggi':
        return 'Pertimbangkan berbicara dengan konselor/psikolog. Kurangi beban, istirahat cukup, dan hubungi layanan dukungan profesional secepatnya.';
      case 'sedang':
        return 'Lakukan aktivitas relaksasi (napas dalam, olahraga ringan), atur waktu, dan evaluasi beban kuliah/kerja. Perhatikan perubahan suasana hati.';
      case 'rendah':
        return 'Pertahankan kebiasaan baik. Jaga tidur, makan, dan olahraga yang teratur. Rutin melakukan mindfulness.';
      default:
        return 'Hasil skrining tidak terdefinisi. Harap hubungi dukungan teknis.';
    }
  }

  // Fungsi utilitas untuk mendapatkan warna berdasarkan level risiko
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'tinggi':
        return Colors.red.shade700;
      case 'sedang':
        return Colors.orange.shade700;
      case 'rendah':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  // Konten utama yang akan dibangun setelah data berhasil dimuat
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
          
          // --- Tingkat Risiko ---
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

          // --- Detail Scoring ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'Final Score (0.0 - 1.0):', result.score.toStringAsFixed(3)),
                  _buildDetailRow(context, 'Confidence Score:', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Rekomendasi ---
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

          const SizedBox(height: 48),
          const Text(
            '*Disclaimer: InsightMind bersifat edukatif, bukan alat diagnosis medis. Hasil ini dihasilkan oleh model AI berdasarkan kuesioner dan data sensor. Harap berkonsultasi dengan profesional kesehatan mental untuk diagnosis dan penanganan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
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
    // [PERBAIKAN KRITIS]: Memicu resultProvider menggunakan FeatureVector yang diterima
    // Asumsi: resultProvider di define menggunakan FutureProvider.family
    final resultAsync = ref.watch(resultProvider(featureVector)); 
    // 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: Colors.red.shade700, 
        foregroundColor: Colors.white,
      ),
      // Menggunakan .when() untuk menangani status asinkron dari FutureProvider
      body: resultAsync.when(
        // === 1. DATA BERHASIL DIMUAT ===
        data: (result) => _buildContent(context, result),
        
        // === 2. SEDANG LOADING / PREDIKSI AI BERJALAN ===
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo), // Tambahkan warna untuk konsistensi
              SizedBox(height: 16),
              Text('Menghitung risiko dengan model AI...', style: TextStyle(color: Colors.indigo)),
              // 
            ],
          ),
        ),
        
        // === 3. ERROR ===
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Terjadi kesalahan saat menghitung hasil:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(err.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
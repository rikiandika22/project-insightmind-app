// lib/features/insightmind/presentation/pages/processing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; 

// --- IMPORT PROVIDER & ENTITY ---
import '../providers/questionnaire_provider.dart';
import '../providers/history_provider.dart'; 
import '../../domain/entities/mental_result.dart'; 
import 'result_page.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  const ProcessingPage({super.key});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends ConsumerState<ProcessingPage> {
  
  @override
  void initState() {
    super.initState();
    // Jalankan proses analisa setelah widget selesai dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processData();
    });
  }

  Future<void> _processData() async {
    // 1. Simulasi Loading "AI Berpikir" (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Ambil Data Jawaban dari Provider
    final qState = ref.read(questionnaireProvider);
    final questions = ref.read(questionsProvider);

    // Hitung Total Skor
    int totalScore = 0;
    for (var q in questions) {
      if (qState.answers.containsKey(q.id)) {
        totalScore += qState.answers[q.id]!;
      }
    }

    // 3. Logika Penentuan Risiko & Rekomendasi
    String riskLevel;
    String riskMessage;
    List<String> recommendations; // Variabel untuk rekomendasi

    // Logika Skor (Sesuaikan dengan aturan medis/psikologis yang Anda gunakan)
    if (totalScore >= 40) {
      riskLevel = "Risiko Tinggi";
      riskMessage = "Terdeteksi indikasi stres berat atau depresi. Sangat disarankan berkonsultasi dengan profesional.";
      recommendations = [
        "Segera hubungi psikolog atau konselor terdekat.",
        "Ambil cuti atau jeda istirahat dari rutinitas padat.",
        "Ceritakan apa yang Anda rasakan pada orang kepercayaan.",
        "Hindari isolasi diri terlalu lama."
      ];
    } else if (totalScore >= 20) {
      riskLevel = "Risiko Sedang";
      riskMessage = "Ada tanda-tanda tekanan mental. Coba teknik relaksasi dan perbaiki pola tidur.";
      recommendations = [
        "Lakukan detoks media sosial selama 24 jam.",
        "Latihan pernapasan (Breathing Exercise) rutin.",
        "Pastikan tidur cukup 7-8 jam sehari.",
        "Lakukan olahraga ringan seperti jalan kaki."
      ];
    } else {
      riskLevel = "Risiko Rendah";
      riskMessage = "Kondisi mental Anda tampak stabil. Pertahankan gaya hidup sehat.";
      recommendations = [
        "Pertahankan hobi yang menyenangkan hati.",
        "Tetap terhubung dengan teman dan keluarga.",
        "Lakukan meditasi ringan untuk menjaga fokus.",
        "Syukuri hal-hal kecil setiap hari."
      ];
    }

    // Hitung Confidence (Kecerdasan Buatan Dummy)
    double confidence = 0.0;
    if (questions.isNotEmpty) {
      confidence = (qState.answers.length / questions.length) * 100;
    }

    // 4. BUNGKUS OBJECT HASIL
    // [PERBAIKAN] Kita sesuaikan dengan Entity MentalResult Anda
    final result = MentalResult(
      // id: ..., (HAPUS INI - ID dibuat di Repository)
      // date: ..., (HAPUS INI - Tanggal dibuat di Repository)
      
      score: totalScore.toDouble(),
      riskLevel: riskLevel,
      riskMessage: riskMessage,
      confidence: confidence,
      recommendations: recommendations, // [WAJIB] Tambahkan ini agar error hilang
    );

    // 5. SIMPAN KE RIWAYAT (Hive Database)
    // Repository akan otomatis membuat ID unik dan Tanggal saat menyimpan
    await ref.read(historyRepositoryProvider).saveToHistory(result);
    
    // Refresh agar halaman History update otomatis
    ref.invalidate(historyListProvider);

    // 6. Navigasi ke Halaman Hasil
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(result: result), // Kirim data hasil
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema Gelap
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Background adaptif
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Loading
            CircularProgressIndicator(
              color: Colors.red[800],
              strokeWidth: 6,
            ),
            const SizedBox(height: 30),
            
            // Teks Status
            Text(
              "AI sedang menganalisa jawaban...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Mohon tunggu sebentar",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


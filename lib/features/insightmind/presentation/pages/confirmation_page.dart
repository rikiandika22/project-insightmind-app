// lib/features/insightmind/presentation/pages/confirmation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Imports Entitas & Provider ---
import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart'; // Digunakan untuk menyimpan raw answers
import 'biometric_page.dart'; // Import BiometricPage sebagai tujuan baru
// result_page.dart, history_provider.dart, dan mental_result.dart 
// dihapus karena tidak lagi dipanggil dari halaman ini.

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  // Fungsi untuk menyimpan jawaban kuesioner MENTAH dan menavigasi ke Biometrik
  void _saveAnswersAndNavigateToBiometrics(BuildContext context, WidgetRef ref) {
    // 1. Ambil data mentah jawaban kuesioner
    final questions = ref.read(questionsProvider);
    final qState = ref.read(questionnaireProvider);

    final answersOrdered = <int>[];
    for (final q in questions) {
      // Pastikan semua jawaban ada
      if (qState.answers.containsKey(q.id)) {
        answersOrdered.add(qState.answers[q.id]!);
      }
    }
    
    // 2. Simpan jawaban ke answersProvider. 
    // Langkah ini AKAN Memicu rawQuestionnaireScoreProvider, 
    // tetapi resultProvider tidak akan memicu perhitungan penuh AI (karena data biometrik belum ada).
    ref.read(answersProvider.notifier).state = answersOrdered;
    
    // 3. NAVIGASI KE BIOMETRIC PAGE
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BiometricPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data untuk menampilkan ringkasan jawaban
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);
    final answers = qState.answers;
    
    final Color primaryRed = Theme.of(context).primaryColor;
    final Color backgroundColor = const Color(0xFFF7F8FA); 
    
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        title: const Text('Ringkasan Jawaban'),
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 0,
        // Tombol kembali (Back) harus berfungsi untuk mengulang jawaban
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selectedScore = answers[question.id];
          
          late AnswerOption selectedOption;
          
          try {
             // Dapatkan opsi yang dipilih berdasarkan skor
             selectedOption = question.options.firstWhere(
               (opt) => opt.score == selectedScore,
             );
          } catch (e) {
             // Kasus darurat jika ada pertanyaan yang terlewat
             selectedOption = const AnswerOption(label: 'Jawaban Tidak Ditemukan', score: -1);
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), 
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertanyaan ${index + 1}',
                    style: TextStyle(
                      color: primaryRed, 
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
                  Text(
                    'Jawaban Anda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedOption.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Tombol Navigasi Bawah yang Diperbaiki
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ]
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // PANGGIL FUNGSI NAVIGASI BARU
          onPressed: () => _saveAnswersAndNavigateToBiometrics(context, ref), 
          child: const Text(
            'Lanjut ke Pengukuran Biometrik', // Teks Diperbarui
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
// Widget _HasilScreeningDialog DIHAPUS karena perhitungan AI dipindahkan
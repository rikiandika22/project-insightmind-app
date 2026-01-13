// lib/features/insightmind/presentation/pages/confirmation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Imports Entitas & Provider ---
import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';

// Gunakan Package Import untuk menghindari error "Not Found"
import 'package:insightmind_app/features/insightmind/presentation/providers/score_provider.dart'; 

// Navigasi
import 'result_page.dart'; 

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  /// Fungsi untuk menyimpan jawaban kuesioner dan langsung menghitung hasil AI
  Future<void> _processAndNavigateToResult(BuildContext context, WidgetRef ref) async {
    // 1. Ambil data pertanyaan dan jawaban yang sudah diisi user
    final questions = ref.read(questionsProvider);
    final qState = ref.read(questionnaireProvider);

    // 2. Ekstrak skor jawaban sesuai urutan pertanyaan
    final answersOrdered = <int>[];
    for (final q in questions) {
      if (qState.answers.containsKey(q.id)) {
        answersOrdered.add(qState.answers[q.id]!);
      } else {
        // Jika ada pertanyaan terlewat, beri skor default 0 agar tidak error
        answersOrdered.add(0);
      }
    }
    
    // 3. Simpan jawaban ke answersProvider agar skor AI terhitung otomatis
    ref.read(answersProvider.notifier).state = answersOrdered;

    // 4. Aktifkan mode Full Screening (Kuesioner + Sensor)
    ref.read(isFullScreeningProvider.notifier).state = true;

    // 5. Jalankan kalkulasi AI
    ref.read(scoreProvider.notifier).calculateFinalRisk();
    
    // 6. Pindah ke Halaman Hasil
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ResultPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch data untuk menampilkan daftar ringkasan
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);
    final answers = qState.answers;
    
    // Tema warna merah profesional
    final Color primaryColor = Colors.red[800]!; 
    const Color backgroundColor = Color(0xFFFFF5F5); 
    
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        title: const Text(
          'Ringkasan Jawaban',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, 
        foregroundColor: primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.red.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selectedScore = answers[question.id];
          
          // Cari label jawaban berdasarkan skor (misal: "Sangat Sering")
          AnswerOption selectedOption;
          try {
             selectedOption = question.options.firstWhere(
               (opt) => opt.score == selectedScore,
             );
          } catch (e) {
             selectedOption = const AnswerOption(label: 'Belum Dijawab', score: 0);
          }

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16.0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.withOpacity(0.1)), 
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Nomor Pertanyaan
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pertanyaan ${index + 1}', 
                          style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Teks Pertanyaan
                  Text(
                    question.text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  // Bagian Jawaban User
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 20, color: primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jawaban Anda:',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedOption.label,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Bagian Tombol Konfirmasi (Sticky di bawah)
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1), 
              blurRadius: 20, 
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
          onPressed: () => _processAndNavigateToResult(context, ref), 
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome),
              SizedBox(width: 12),
              Text(
                'PROSES ANALISA AI', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
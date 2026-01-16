// lib/features/insightmind/presentation/pages/confirmation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/processing_page.dart';
import '../providers/questionnaire_provider.dart';



class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. [LOGIKA TEMA] Deteksi Mode Gelap
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Adaptif
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    // 3. Ambil Data dari Provider
    final questions = ref.watch(questionsProvider);
    final state = ref.watch(questionnaireProvider);

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Ringkasan Jawaban',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: cardColor, // AppBar mengikuti warna Card/Surface
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // LIST JAWABAN
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final question = questions[index];
                final score = state.answers[question.id];

                // Cari label jawaban berdasarkan skor yang dipilih
                String answerLabel = "Belum dijawab";
                try {
                  final selectedOption = question.options.firstWhere((opt) => opt.score == score);
                  answerLabel = selectedOption.label;
                } catch (e) {
                  // Handle jika error/null
                }

                return Card(
                  color: cardColor, // Warna Kartu Berubah Otomatis
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Nomor Pertanyaan
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Pertanyaan ${index + 1}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Teks Pertanyaan
                        Text(
                          question.text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textColor, // Warna Teks Adaptif
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 12),

                        // Jawaban User
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Jawaban Anda:",
                                    style: TextStyle(fontSize: 12, color: subTextColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    answerLabel,
                                    style: const TextStyle(
                                      color: Colors.red, // Jawaban tetap merah agar kontras
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
          ),

          // TOMBOL PROSES (Sticky di Bawah)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke Halaman Processing/Loading
                // Pastikan Anda punya 'ProcessingPage' atau langsung ke ResultPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProcessingPage()),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text("PROSES ANALISA AI", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
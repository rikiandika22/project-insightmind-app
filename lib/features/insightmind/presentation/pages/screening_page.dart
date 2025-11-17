import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart'; 
import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import 'confirmation_page.dart'; 

class ScreeningPage extends ConsumerStatefulWidget {
  const ScreeningPage({super.key});

  @override
  ConsumerState<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends ConsumerState<ScreeningPage> {
  // State untuk melacak pertanyaan saat ini
  int _currentIndex = 0;

  // Warna dari UI baru Anda
  static const Color primaryRed = Color(0xFFD32F2F); 
  static const Color lightGray = Color(0xFFF7F8FA);

  // Fungsi untuk menampilkan pesan (masih dipakai)
  void _showIncompleteSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda harus memilih satu jawaban.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari provider (Logika Lama)
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tentukan state dinamis (Logika Lama)
    final int totalQuestions = questions.length;
    final Question currentQuestion = questions[_currentIndex];
    final int? selectedScore = qState.answers[currentQuestion.id];
    final bool isAnswerSelected = selectedScore != null;

    // Kalkulasi progress (Logika Baru)
    double progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: lightGray,
      // AppBar dari UI Baru
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Screening",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // Body dari UI Baru, diisi data dari Logika Lama
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Progress bar melingkar (UI Baru)
            CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 8.0,
              percent: progress,
              center: Text(
                '${_currentIndex + 1}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryRed),
              ),
              progressColor: primaryRed,
              backgroundColor: primaryRed.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 20),
            Text(
              'Pertanyaan ${_currentIndex + 1}/$totalQuestions',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Kartu pertanyaan (UI Baru)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              // Pertanyaan dari provider (Logika Lama)
              child: Text(
                currentQuestion.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan jawaban
            // Kita gunakan data `AnswerOption` dari file `question.dart`
            ...currentQuestion.options.map((option) {
              final bool isSelected = selectedScore == option.score;

              return GestureDetector(
                onTap: () {
                  // Memanggil provider (Logika Lama)
                  ref.read(questionnaireProvider.notifier).selectAnswer(
                      questionId: currentQuestion.id, score: option.score);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? primaryRed : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? primaryRed.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? primaryRed : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option.label, // Data dari class AnswerOption
                          style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? primaryRed : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(), // Mendorong tombol ke bawah

            // Tombol navigasi bawah 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentIndex == 0
                        ? null
                        : () {
                            setState(() {
                              _currentIndex--; 
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey.shade300,
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // [FIX] Pindahkan padding ke style
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Center(
                      child: Text(
                        "Kembali",
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Tombol Selanjutnya / Lihat Hasil
                Expanded(
                  child: InkWell(
                    onTap: !isAnswerSelected
                        ? () => _showIncompleteSnackbar() // Tampilkan pesan jika belum
                        : () {
                            // Cek apakah ini pertanyaan terakhir
                            if (_currentIndex == totalQuestions - 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ConfirmationPage(),
                                ),
                              );
                            } else {
                              setState(() {
                                _currentIndex++; // Lanjut
                              });
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: !isAnswerSelected
                            ? LinearGradient(
                                // Tombol nonaktif
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                              )
                            : const LinearGradient(
                                // Tombol aktif
                                colors: [Color(0xFFD81B60), Color(0xFFB71C1C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            _currentIndex == totalQuestions - 1
                                ? "Lihat Hasil"
                                : "Selanjutnya",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart'; 

import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import 'confirmation_page.dart'; // Import halaman konfirmasi
// import 'biometric_page.dart';     // Pastikan BiometricPage juga diimpor

class ScreeningPage extends ConsumerStatefulWidget {
  const ScreeningPage({super.key});

  @override
  ConsumerState<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends ConsumerState<ScreeningPage> {
  // State untuk melacak pertanyaan saat ini
  int _currentIndex = 0;

  // Warna yang konsisten
  static const Color primaryRed = Color(0xFFD32F2F); 
  static const Color lightGray = Color(0xFFF7F8FA);

  // Fungsi untuk menampilkan pesan 
  void _showIncompleteSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda harus memilih satu jawaban.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // Fungsi untuk kembali (Kembali di Appbar)
  void _goBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--; 
      });
    } else {
      // Jika di pertanyaan pertama, kembali ke halaman sebelumnya (misal Home)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari provider
    final questions = ref.watch(questionsProvider); // Asumsi: questionsProvider memberikan List<Question>
    final qState = ref.watch(questionnaireProvider); // Asumsi: questionnaireProvider memberikan state jawaban

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tentukan state dinamis
    final int totalQuestions = questions.length;
    final Question currentQuestion = questions[_currentIndex];
    final int? selectedScore = qState.answers[currentQuestion.id];
    final bool isAnswerSelected = selectedScore != null;

    // Kalkulasi progress
    double progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: lightGray,
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _goBack, // Menggunakan fungsi _goBack
        ),
        centerTitle: true,
        title: const Text(
          "Screening",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Progress bar
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
            // Kartu pertanyaan
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
              child: Text(
                currentQuestion.text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan jawaban (Diperluas agar bisa di-scroll)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: currentQuestion.options.map((option) {
                    final bool isSelected = selectedScore == option.score;

                    return GestureDetector(
                      onTap: () {
                        // Memanggil provider untuk menyimpan jawaban
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
                                option.label, 
                                style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? primaryRed : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

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
                        ? () => _showIncompleteSnackbar() 
                        : () {
                            // Cek apakah ini pertanyaan terakhir
                            if (_currentIndex == totalQuestions - 1) {
                              // NAVIGASI KE CONFIRMATION PAGE (Langkah yang benar)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConfirmationPage(),
                                ),
                              );
                            } else {
                              setState(() {
                                _currentIndex++; // Lanjut ke pertanyaan berikutnya
                              });
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: !isAnswerSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                              )
                            : const LinearGradient(
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
                                ? "Lihat Hasil" // Ini akan menjadi "Lanjut ke Konfirmasi"
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
            const SizedBox(height: 16), // Padding bawah
          ],
        ),
      ),
    );
  }
}
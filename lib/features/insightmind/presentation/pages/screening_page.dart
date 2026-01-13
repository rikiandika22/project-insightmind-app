// lib/features/insightmind/presentation/pages/screening_page.dart

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

  // Warna Utama (Tetap Merah)
  static const Color primaryRed = Color(0xFFD32F2F); 

  // Fungsi untuk menampilkan pesan 
  void _showIncompleteSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda harus memilih satu jawaban.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // Fungsi untuk kembali
  void _goBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--; 
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // [LOGIKA TEMA] Cek apakah sedang mode gelap
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Warna-warna adaptif
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    final optionBorderColor = isDarkMode ? Colors.grey[800]! : Colors.grey.shade300;
    
    // Ambil data dari provider
    final questions = ref.watch(questionsProvider); 
    final qState = ref.watch(questionnaireProvider); 

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: scaffoldColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final int totalQuestions = questions.length;
    final Question currentQuestion = questions[_currentIndex];
    final int? selectedScore = qState.answers[currentQuestion.id];
    final bool isAnswerSelected = selectedScore != null;

    // Kalkulasi progress
    double progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: scaffoldColor, // Background mengikuti tema
      
      // AppBar
      appBar: AppBar(
        backgroundColor: cardColor, // AppBar mengikuti warna kartu/tema
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // Icon adaptif
          onPressed: _goBack, 
        ),
        centerTitle: true,
        title: Text(
          "Screening",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: subTextColor, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            // Kartu pertanyaan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor, // Warna kartu adaptif
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Shadow lebih halus
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Text(
                currentQuestion.text,
                style: TextStyle(fontSize: 16, color: textColor), // Teks pertanyaan adaptif
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan jawaban
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: currentQuestion.options.map((option) {
                    final bool isSelected = selectedScore == option.score;

                    return GestureDetector(
                      onTap: () {
                        ref.read(questionnaireProvider.notifier).selectAnswer(
                            questionId: currentQuestion.id, score: option.score);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? primaryRed : optionBorderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          // Warna isi pilihan jawaban
                          color: isSelected
                              ? primaryRed.withOpacity(0.1)
                              : cardColor, 
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected ? primaryRed : subTextColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option.label, 
                                style: TextStyle(
                                    fontSize: 16,
                                    // Warna teks opsi: Merah jika dipilih, Putih/Hitam jika tidak
                                    color: isSelected ? primaryRed : textColor),
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
                      // Warna tombol kembali adaptif
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade300,
                      disabledBackgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Center(
                      child: Text(
                        "Kembali",
                        style: TextStyle(
                            // Warna teks tombol kembali
                            color: isDarkMode ? Colors.white70 : Colors.black54,
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
                            if (_currentIndex == totalQuestions - 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConfirmationPage(),
                                ),
                              );
                            } else {
                              setState(() {
                                _currentIndex++; 
                              });
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: !isAnswerSelected
                            ? LinearGradient(
                                colors: isDarkMode 
                                  ? [Colors.grey[800]!, Colors.grey[900]!] // Gradient disable dark
                                  : [Colors.grey.shade300, Colors.grey.shade400], // Gradient disable light
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFD81B60), Color(0xFFB71C1C)], // Gradient aktif tetap merah
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
                            style: TextStyle(
                              // Teks tombol disable jadi agak gelap
                              color: !isAnswerSelected && !isDarkMode ? Colors.grey[600] : Colors.white,
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
            const SizedBox(height: 16), 
          ],
        ),
      ),
    );
  }
}
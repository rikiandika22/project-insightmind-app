// lib/features/insightmind/presentation/pages/confirmation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Impor semua provider dan entitas yang relevan
import '../../domain/entities/question.dart';
import '../../domain/entities/mental_result.dart'; 
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
// [BARU] Import provider riwayat
import '../providers/history_provider.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  void _submitAnswers(BuildContext context, WidgetRef ref) {
    final questions = ref.read(questionsProvider);
    final qState = ref.read(questionnaireProvider);

    final answersOrdered = <int>[];
    for (final q in questions) {
      answersOrdered.add(qState.answers[q.id]!);
    }
    ref.read(answersProvider.notifier).state = answersOrdered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
      body: ListView.builder(
        // ... (ListView.builder tidak berubah) ...
        padding: const EdgeInsets.all(16.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selectedScore = answers[question.id];
          
          final selectedOption = question.options.firstWhere(
            (opt) => opt.score == selectedScore,
            orElse: () => const AnswerOption(label: 'Tidak dijawab', score: -1),
          );

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

      bottomNavigationBar: Container(
        // ... (BottomNavigationBar tidak berubah) ...
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
          onPressed: () {
            _submitAnswers(context, ref);
            
            showDialog(
              context: context,
              barrierDismissible: false, 
              builder: (BuildContext dialogContext) {
                // [DIUBAH] Panggil dialog stateful yang baru
                return const _HasilScreeningDialog();
              },
            );
          },
          child: const Text(
            'Konfirmasi & Lihat Hasil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


// --- [WIDGET DIALOG DIUBAH] ---
// Diubah menjadi ConsumerStatefulWidget untuk menangani save satu kali

class _HasilScreeningDialog extends ConsumerStatefulWidget {
  const _HasilScreeningDialog();

  @override
  ConsumerState<_HasilScreeningDialog> createState() => _HasilScreeningDialogState();
}

class _HasilScreeningDialogState extends ConsumerState<_HasilScreeningDialog> {
  
  // Flag untuk mencegah penyimpanan ganda jika dialog rebuild
  bool _isSaved = false;

  // [BARU] Fungsi untuk menyimpan hasil
  void _saveResultOnce(MentalResult hasil) {
    // Cek jika belum disimpan
    if (!_isSaved) {
      // Panggil repository untuk menyimpan
      // Kita gunakan ref.read() karena ini adalah aksi sekali jalan
      ref.read(historyRepositoryProvider).addRecord(hasil);
      
      // Refresh daftar riwayat di background (opsional, tapi bagus)
      ref.refresh(historyListProvider);
      
      // Tandai sebagai sudah disimpan
      setState(() {
        _isSaved = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    
    // Ambil hasil seperti biasa
    final MentalResult hasil = ref.watch(resultProvider);
    final int totalScore = hasil.score;
    final String riskLevel = hasil.riskLevel;
    final String riskMessage = hasil.riskMessage; 

    // [BARU] Panggil fungsi save
    // Ini aman dipanggil di dalam build() karena ada flag _isSaved
    _saveResultOnce(hasil);

    final Color primaryRed = Theme.of(context).primaryColor;

    // ... (Sisa kode UI Dialog tidak berubah) ...
    Color riskColor;
    if (riskLevel.toLowerCase() == 'rendah') {
      riskColor = Colors.green.shade700;
    } else if (riskLevel.toLowerCase() == 'sedang') {
      riskColor = Colors.orange.shade700;
    } else {
      riskColor = primaryRed;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.local_hospital_rounded, 
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 8),
                Text(
                  'Hasil Screening',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const Text(
                  'Skor Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalScore',
                  style: TextStyle(
                    color: primaryRed,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Dengan Tingkat Risiko '),
                      TextSpan(
                        text: riskLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  riskMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    // Kembali ke halaman paling awal (HomePage)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Beranda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Definisi model untuk Opsi Jawaban
class AnswerOption {
  final String label; 
  final int score; // 0..3

  const AnswerOption({required this.label, required this.score});
}

// Definisi model untuk Pertanyaan
class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;

  const Question({required this.id, required this.text, required this.options});
}

// --- Daftar 9 Pertanyaan ---

// Kita buat daftar opsinya sekali saja untuk dipakai ulang
const List<AnswerOption> defaultOptions = <AnswerOption>[
  AnswerOption(label: 'Tidak Pernah', score: 0),
  AnswerOption(label: 'Beberapa Hari', score: 1),
  AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
  AnswerOption(label: 'Hampir Setiap Hari', score: 3),
];

// Ini adalah daftar pertanyaan yang akan dibaca oleh provider Anda
const List<Question> defaultQuestions = <Question>[
  Question(
    id: 'q1',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa kurang minat atau menikmati hal-hal yang biasanya Anda lakukan?',
    options: defaultOptions,
  ),
  Question(
    id: 'q2',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa sedih, murung, atau putus asa?',
    options: defaultOptions,
  ),
  Question(
    id: 'q3',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda kesulitan untuk tidur, tidak bisa tidur nyenyak, atau tidur terlalu banyak?',
    options: defaultOptions,
  ),
  Question(
    id: 'q4',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa lelah atau kekurangan energi?',
    options: defaultOptions,
  ),
  Question(
    id: 'q5',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa kurang nafsu makan atau justru makan berlebihan?',
    options: defaultOptions,
  ),
  Question(
    id: 'q6',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa buruk tentang diri sendiri, merasa gagal, atau mengecewakan diri/keluarga?',
    options: defaultOptions,
  ),
  Question(
    id: 'q7',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda sulit berkonsentrasi pada sesuatu, misalnya membaca atau menonton TV?',
    options: defaultOptions,
  ),
  Question(
    id: 'q8',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda bergerak atau berbicara sangat lambat (disadari orang lain) ATAU sebaliknya, sangat gelisah/tidak bisa diam?',
    options: defaultOptions,
  ),
  Question(
    id: 'q9',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda berpikir untuk mengakhiri hidup atau melukai diri sendiri?',
    options: defaultOptions,
  ),
];
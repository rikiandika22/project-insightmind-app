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

// --- Daftar 20 Pertanyaan ---

// Kita buat daftar opsinya sekali saja untuk dipakai ulang
const List<AnswerOption> defaultOptions = <AnswerOption>[
  AnswerOption(label: 'Tidak Pernah', score: 0),
  AnswerOption(label: 'Beberapa Hari', score: 1),
  AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
  AnswerOption(label: 'Hampir Setiap Hari', score: 3),
];

// Ini adalah daftar 20 pertanyaan yang akan dibaca oleh provider Anda
const List<Question> defaultQuestions = <Question>[
  // KELOMPOK 1: PHQ-9 (Depresi) - Q1 sampai Q9
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

  // KELOMPOK 2: GAD-7 & Gejala Kecemasan/Stres Tambahan - Q10 sampai Q20
  Question(
    id: 'q10',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa cemas, khawatir, atau tegang?',
    options: defaultOptions,
  ),
  Question(
    id: 'q11',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda tidak mampu menghentikan atau mengendalikan rasa khawatir?',
    options: defaultOptions,
  ),
  Question(
    id: 'q12',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda terlalu mengkhawatirkan berbagai hal yang berbeda?',
    options: defaultOptions,
  ),
  Question(
    id: 'q13',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda mengalami kesulitan untuk rileks (santai)?',
    options: defaultOptions,
  ),
  Question(
    id: 'q14',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa sangat gelisah sehingga sulit untuk duduk diam?',
    options: defaultOptions,
  ),
  Question(
    id: 'q15',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa mudah terganggu atau menjadi marah?',
    options: defaultOptions,
  ),
  Question(
    id: 'q16',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa takut seolah sesuatu yang buruk akan terjadi?',
    options: defaultOptions,
  ),
  Question(
    id: 'q17',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda memiliki gejala fisik seperti sakit kepala, sakit perut, atau detak jantung cepat yang tidak dapat dijelaskan?',
    options: defaultOptions,
  ),
  Question(
    id: 'q18',
    text:
        'Dalam 2 minggu terakhir, seberapa sering masalah-masalah ini menyebabkan kesulitan dalam pekerjaan, sekolah, atau tugas rumah tangga Anda?',
    options: defaultOptions,
  ),
  Question(
    id: 'q19',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa kehilangan kendali atas emosi Anda (misalnya, menangis tiba-tiba atau marah tak terkendali)?',
    options: defaultOptions,
  ),
  Question(
    id: 'q20',
    text:
        'Dalam 2 minggu terakhir, seberapa sering Anda merasa terputus atau jauh dari teman, keluarga, atau lingkungan sosial?',
    options: defaultOptions,
  ),
];
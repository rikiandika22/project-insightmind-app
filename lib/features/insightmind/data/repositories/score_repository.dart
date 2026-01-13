class ScoreRepository {
  /// Menjumlahkan seluruh jawaban kuesioner (tiap jawaban berupa integer).
  int calculateScore(List<int> answers) {
    if (answers.isEmpty) return 0;
    return answers.reduce((a, b) => a + b);
  }
}

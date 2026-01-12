class ScreeningHistory {
  final String id;
  final DateTime dateTime;
  final String riskLevel;
  final double score;

  ScreeningHistory({
    required this.id,
    required this.dateTime,
    required this.riskLevel,
    required this.score,
  });
}
// lib/features/insightmind/domain/entities/mental_result.dart

class MentalResult {
  final int score;
  final String riskLevel;
  final String riskMessage; 

  const MentalResult({
    required this.score, 
    required this.riskLevel,
    required this.riskMessage, 
  });
}
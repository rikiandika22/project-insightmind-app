// lib/features/insightmind/domain/entities/mental_result.dart
import 'package:equatable/equatable.dart';

class MentalResult extends Equatable {
  final double score; 
  final String riskLevel;
  final String riskMessage;
  final double confidence;
  final List<String> recommendations;

  const MentalResult({
    required this.score, 
    required this.riskLevel,
    required this.riskMessage, 
    required this.confidence,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        score, 
        riskLevel, 
        riskMessage, 
        confidence,
        recommendations,
      ];
}
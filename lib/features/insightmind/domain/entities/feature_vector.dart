// lib/features/insightmind/domain/entities/feature_vector.dart

import 'package:equatable/equatable.dart';

// Represents the aggregated data input for the AI model (kuesioner + sensor)
class FeatureVector extends Equatable {
  // Data dari kuesioner (misalnya, total skor mentah)
  final double questionnaireScore;

  // Data dari sensor PPG (Detak Jantung)
  final double heartRateBPM;
  final double ppgMean; // <--- DITAMBAHKAN (Mean mentah PPG)
  
  // Data dari sensor Akselerometer (Aktivitas/Tidur)
  final double sleepQualityIndex;
  final double accelFeatVariance; // <--- DITAMBAHKAN (Variance Akselerometer)

  // Data tambahan
  final int ageGroup;

  const FeatureVector({
    required this.questionnaireScore,
    required this.heartRateBPM,
    required this.sleepQualityIndex,
    required this.ppgMean, // <--- DITAMBAHKAN DI CONSTRUCTOR
    required this.accelFeatVariance, // <--- DITAMBAHKAN DI CONSTRUCTOR
    required this.ageGroup,
  });

  @override
  List<Object> get props => [
        questionnaireScore,
        heartRateBPM,
        sleepQualityIndex,
        ppgMean, // <--- DITAMBAHKAN DI PROPS
        accelFeatVariance, // <--- DITAMBAHKAN DI PROPS
        ageGroup,
      ];
}
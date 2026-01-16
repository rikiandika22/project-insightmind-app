import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';


// ===============================================
// 1. ENTITAS STATE
// ===============================================

class AccelFeature {
  final List<double> samples;
  final double variance;

  const AccelFeature({required this.samples, required this.variance});
  const AccelFeature.initial() : samples = const [], variance = 0.0;
}

class PPGFeature {
  final List<double> samples; 
  final double mean;          // Ini akan menjadi BPM rata-rata
  final bool capturing;       
  final bool isFlashOn;       // Status Flash Kamera

  const PPGFeature({
    required this.samples, 
    required this.mean, 
    required this.capturing,
    this.isFlashOn = false,
  });

  // PERBAIKAN: Menambahkan isFlashOn agar tidak error "Final field not initialized"
  const PPGFeature.initial() 
      : samples = const [], 
        mean = 0.0, 
        capturing = false, 
        isFlashOn = false; 
  
  PPGFeature copyWith({
    List<double>? samples,
    double? mean,
    bool? capturing,
    bool? isFlashOn,
  }) {
    return PPGFeature(
      samples: samples ?? this.samples,
      mean: mean ?? this.mean,
      capturing: capturing ?? this.capturing,
      isFlashOn: isFlashOn ?? this.isFlashOn,
    );
  }
}

// ===============================================
// 2. NOTIFIER PPG (Menerima Data dari Kamera)
// ===============================================

class PPGNotifier extends StateNotifier<PPGFeature> {
  PPGNotifier() : super(const PPGFeature.initial());

  /// Memulai sesi pengukuran
  void startCapture() {
    // Reset data lama saat memulai pengukuran baru
    state = state.copyWith(
      capturing: true, 
      samples: [], 
      mean: 0.0, 
      isFlashOn: true
    );
  }

  /// Fungsi ini akan dipanggil oleh UI (Camera Stream) setiap kali ada data BPM baru
  void updateBPM(double bpmValue) {
    if (!state.capturing) return;

    // Filter sederhana: Abaikan jika angka BPM tidak logis (noise)
    if (bpmValue < 40 || bpmValue > 180) return;

    final updatedSamples = [...state.samples, bpmValue];
    
    // Hitung rata-rata bergerak (moving average)
    final newMean = updatedSamples.isEmpty 
        ? 0.0 
        : updatedSamples.reduce((a, b) => a + b) / updatedSamples.length;

    state = state.copyWith(
      samples: updatedSamples,
      mean: newMean,
    );
  }

  /// Menghentikan sesi pengukuran dan mematikan flash
  void stopCapture() {
    state = state.copyWith(capturing: false, isFlashOn: false);
  }
}

// ===============================================
// 3. NOTIFIER ACCELEROMETER
// ===============================================

class AccelNotifier extends StateNotifier<AccelFeature> {
  AccelNotifier() : super(const AccelFeature.initial());
  
  void updateFromSensor(List<double> rawData) {
    if (rawData.isEmpty) return;
    
    final mean = rawData.reduce((a, b) => a + b) / rawData.length;
    final variance = rawData.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / rawData.length;

    state = AccelFeature(
      samples: rawData,
      variance: variance.toDouble(),
    );
  }

  void startListening() {
    // Simulasi data awal aktivitas (Varians rendah = tenang, Varians tinggi = aktif)
    final mockSamples = List.generate(20, (_) => 0.1 + Random().nextDouble() * 0.2);
    updateFromSensor(mockSamples);
  }
}

// ===============================================
// 4. PROVIDER GLOBAL
// ===============================================

final ppgProvider = StateNotifierProvider<PPGNotifier, PPGFeature>((ref) {
  return PPGNotifier();
});

final accelFeatureProvider = StateNotifierProvider<AccelNotifier, AccelFeature>((ref) {
  return AccelNotifier()..startListening();
});
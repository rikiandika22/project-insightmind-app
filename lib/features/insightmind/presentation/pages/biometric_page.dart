import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'dart:async';

import '../../domain/entities/feature_vector.dart'; 
import '../providers/sensors_provider.dart'; 
import '../providers/score_provider.dart'; 
import 'result_page.dart'; 

class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  Timer? _mockTimer;
  
  // ProviderSubscription digunakan untuk mendengarkan perubahan state secara manual
  ProviderSubscription? _ppgSubscription;

  Color get _primaryColor => Theme.of(context).primaryColor;

  @override
  void initState() {
    super.initState();
    _initResources();
    
    // Logic Otomatis: Mendengarkan perubahan jumlah sampel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ppgSubscription = ref.listenManual(ppgProvider, (previous, next) {
        // Jika sampel mencapai tepat 30, picu proses otomatis
        if (next.samples.length >= 30 && (previous?.samples.length ?? 0) < 30) {
          _handleAutoProcess();
        }
      });
    });
  }

  Future<void> _initResources() async {
    Future.microtask(() {
      ref.read(accelFeatureProvider.notifier).startListening();
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.low,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint("Kamera error: $e");
    }
  }

  @override
  void dispose() {
    _ppgSubscription?.close(); // Tutup listener saat halaman dihancurkan
    _controller?.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  // Fungsi yang dipicu otomatis saat progress 100%
  void _handleAutoProcess() async {
    // 1. Hentikan sensor dan matikan lampu flash
    await _controller?.setFlashMode(FlashMode.off);
    ref.read(ppgProvider.notifier).stopCapture();
    _mockTimer?.cancel();

    if (!mounted) return;

    // 2. Beri feedback visual kepada pengguna
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data Lengkap! Menganalisa hasil AI..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 3. Navigasi otomatis setelah jeda singkat agar UX terasa mulus
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _processAndGo(context, ref);
    });
  }

  void _toggleMeasurement() async {
    final ppgNotifier = ref.read(ppgProvider.notifier);
    final isCapturing = ref.read(ppgProvider).capturing;

    if (isCapturing) {
      await _controller?.setFlashMode(FlashMode.off);
      ppgNotifier.stopCapture();
      _mockTimer?.cancel();
    } else {
      ppgNotifier.startCapture();
      await _controller?.setFlashMode(FlashMode.torch);

      _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (ref.read(ppgProvider).capturing) {
          // Simulasi input data (BPM acak di rentang normal)
          final double mockBpm = 68 + (DateTime.now().millisecond % 12).toDouble();
          ppgNotifier.updateBPM(mockBpm);
        }
      });
    }
  }

  void _processAndGo(BuildContext context, WidgetRef ref) {
    final ppgFeat = ref.read(ppgProvider);
    final accelFeat = ref.read(accelFeatureProvider);
    final rawScore = ref.read(rawQuestionnaireScoreProvider);
    
    final fv = FeatureVector(
      questionnaireScore: rawScore,
      heartRateBPM: ppgFeat.mean,
      sleepQualityIndex: accelFeat.variance,
      ppgMean: ppgFeat.mean,
      accelFeatVariance: accelFeat.variance,
      ageGroup: 1,
    );

    Navigator.pushReplacement( // Gunakan pushReplacement agar user tidak kembali ke layar scan
      context, 
      MaterialPageRoute(builder: (context) => ResultPage(featureVector: fv))
    );
  }

  @override
  Widget build(BuildContext context) {
    final ppgFeat = ref.watch(ppgProvider);
    final isSufficient = ppgFeat.samples.length >= 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Biometrik Jantung"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.fingerprint_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Pengukuran PPG Optik",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Letakkan ujung telunjuk Anda menutupi lensa kamera belakang dan lampu flash hingga lingkaran menjadi merah.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),
            _buildCameraPreview(ppgFeat),
            const SizedBox(height: 30),
            _buildDataCard(ppgFeat),
            const SizedBox(height: 40),
            _buildControlButtons(ppgFeat, isSufficient),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(PPGFeature ppgFeat) {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: ppgFeat.capturing ? Colors.red : Colors.grey.shade300, 
          width: 6
        ),
        boxShadow: [
          if (ppgFeat.capturing) 
            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 25, spreadRadius: 8)
        ],
      ),
      child: ClipOval(
        child: _isCameraInitialized
            ? AspectRatio(
                aspectRatio: 1,
                child: CameraPreview(_controller!),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.red)),
      ),
    );
  }

  Widget _buildDataCard(PPGFeature ppgFeat) {
    double progress = (ppgFeat.samples.length / 30).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status Sensor:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              Text(
                ppgFeat.capturing ? "MENGANALISA..." : "SIAP",
                style: TextStyle(color: ppgFeat.capturing ? Colors.red : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "${ppgFeat.mean.toStringAsFixed(0)} BPM",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text("Progress Pengumpulan: ${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildControlButtons(PPGFeature ppgFeat, bool isSufficient) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            icon: Icon(ppgFeat.capturing ? Icons.stop_circle : Icons.play_circle_fill),
            label: Text(ppgFeat.capturing ? "HENTIKAN PENGUKURAN" : "MULAI SCAN SEKARANG"),
            style: ElevatedButton.styleFrom(
              backgroundColor: ppgFeat.capturing ? Colors.blueGrey.shade900 : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: _toggleMeasurement,
          ),
        ),
        const SizedBox(height: 16),
        // Tombol Lihat Hasil tetap ada sebagai fallback manual
        if (isSufficient) 
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _primaryColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () => _processAndGo(context, ref),
              child: const Text("LIHAT HASIL MANUAL", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart'; // Import Izin
import 'dart:async';

// Import sesuai struktur folder Anda
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
  bool _isPermissionDenied = false;
  Timer? _mockTimer;
  ProviderSubscription? _ppgSubscription;

  final Color _brandRed = const Color(0xFFC62828);
  final int _targetSamples = 30; // Target sampel untuk 100%

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // RESET Score Provider agar bersih dari data lama
      ref.read(scoreProvider.notifier).reset();

      _ppgSubscription = ref.listenManual(ppgProvider, (previous, next) {
        // Jika sampel mencapai target, proses otomatis
        if (next.samples.length >= _targetSamples && (previous?.samples.length ?? 0) < _targetSamples) {
          _handleAutoProcess();
        }
      });
    });
  }

  // --- LOGIKA IZIN KAMERA ---
  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      _initResources();
    } else {
      setState(() {
        _isPermissionDenied = true;
      });
    }
  }

  Future<void> _initResources() async {
    // Mulai sensor akselerometer secara otomatis di background
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
    _ppgSubscription?.close(); 
    _controller?.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  void _handleAutoProcess() async {
    if (!mounted) return;

    // Matikan lampu flash dan hentikan sensor
    await _controller?.setFlashMode(FlashMode.off);
    ref.read(ppgProvider.notifier).stopCapture();
    _mockTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data Lengkap 100%! Menganalisa hasil..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _processAndGo();
    });
  }

  void _toggleMeasurement() async {
    if (_isPermissionDenied) {
      openAppSettings();
      return;
    }

    final ppgNotifier = ref.read(ppgProvider.notifier);
    final isCapturing = ref.read(ppgProvider).capturing;

    if (isCapturing) {
      await _controller?.setFlashMode(FlashMode.off);
      ppgNotifier.stopCapture();
      _mockTimer?.cancel();
    } else {
      ppgNotifier.startCapture();
      try {
        await _controller?.setFlashMode(FlashMode.torch);
      } catch (e) {
        debugPrint("Flash tidak tersedia: $e");
      }

      _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (ref.read(ppgProvider).capturing) {
          final double mockBpm = 68 + (DateTime.now().second % 15).toDouble();
          ppgNotifier.updateBPM(mockBpm);
        }
      });
    }
  }

  Future<void> _processAndGo() async {
    ref.read(isFullScreeningProvider.notifier).state = false;
    ref.read(scoreProvider.notifier).calculateFinalRisk();

    if (!mounted) return;

    Navigator.pushReplacement( 
      context, 
      MaterialPageRoute(builder: (context) => const ResultPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    final ppgFeat = ref.watch(ppgProvider);
    final scoreState = ref.watch(scoreProvider);
    final isSufficient = ppgFeat.samples.length >= _targetSamples;

    if (_isPermissionDenied) return _buildPermissionError();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Biometrik Jantung"),
        backgroundColor: _brandRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: scoreState.isLoading 
        ? _buildLoadingOverlay()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.favorite_rounded, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Pengukuran Jantung AI",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Letakkan ujung telunjuk Anda pada kamera belakang hingga lingkaran menjadi merah penuh.",
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

  // --- UI COMPONENTS ---

  Widget _buildPermissionError() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_enhance_outlined, size: 100, color: Colors.grey),
              const SizedBox(height: 24),
              const Text("Izin Kamera Diperlukan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Aplikasi membutuhkan akses kamera untuk mendeteksi BPM melalui aliran darah di jari Anda.", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text("Buka Pengaturan"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(color: _brandRed, strokeWidth: 6),
          ),
          const SizedBox(height: 24),
          const Text("Menganalisis Biometrik...", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 8),
          const Text("Model AI sedang memproses data sensor Anda", 
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(PPGFeature ppgFeat) {
    return Container(
      height: 180, width: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: ppgFeat.capturing ? Colors.red : Colors.grey.shade300, 
          width: 6
        ),
      ),
      child: ClipOval(
        child: _isCameraInitialized && _controller != null
            ? CameraPreview(_controller!)
            : const Center(child: CircularProgressIndicator(color: Colors.red)),
      ),
    );
  }

  Widget _buildDataCard(PPGFeature ppgFeat) {
    // HITUNG PERSENTASE
    double progress = (ppgFeat.samples.length / _targetSamples).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();

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
              const Text("Progres Scan:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              Text(
                "$percentage%", 
                style: TextStyle(
                  color: percentage == 100 ? Colors.green : Colors.indigo, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            ppgFeat.capturing ? "${ppgFeat.mean.toStringAsFixed(0)} BPM" : "-- BPM",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 16,
                  backgroundColor: Colors.grey.shade200,
                  color: percentage == 100 ? Colors.green : Colors.redAccent,
                ),
              ),
              if (percentage > 10)
                Text(
                  "$percentage%",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
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
            label: Text(ppgFeat.capturing ? "HENTIKAN" : "MULAI SCAN SEKARANG"),
            style: ElevatedButton.styleFrom(
              backgroundColor: ppgFeat.capturing ? Colors.blueGrey.shade900 : _brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: _toggleMeasurement,
          ),
        ),
        if (isSufficient && !ppgFeat.capturing) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _brandRed, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _processAndGo,
              child: const Text("ANALISA HASIL SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]
      ],
    );
  }
}
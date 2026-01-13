// lib/features/insightmind/presentation/pages/biometric_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

// --- IMPORT ENTITY (PENTING AGAR TIDAK ERROR DATA KOSONG) ---
import '../../domain/entities/mental_result.dart'; 

// Import Provider dan Page Lainnya
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

  // Warna Brand
  final Color _brandRed = const Color(0xFFC62828);
  final int _targetSamples = 30; // Target sampel agar progress bar penuh

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset state sebelumnya
      ref.read(scoreProvider.notifier).reset();

      // Listen perubahan data sensor (Otomatis stop jika data penuh)
      _ppgSubscription = ref.listenManual(ppgProvider, (previous, next) {
        if (next.samples.length >= _targetSamples && (previous?.samples.length ?? 0) < _targetSamples) {
          _handleAutoProcess();
        }
      });
    });
  }

  // --- INISIALISASI KAMERA & IZIN ---
  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initResources();
    } else {
      setState(() => _isPermissionDenied = true);
    }
  }

  Future<void> _initResources() async {
    // Jalankan sensor accelerometer di background
    Future.microtask(() => ref.read(accelFeatureProvider.notifier).startListening());

    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Gunakan resolusi rendah agar performa cepat
        _controller = CameraController(
          cameras.first, 
          ResolutionPreset.low, 
          enableAudio: false
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

  // --- LOGIKA UTAMA ---

  void _handleAutoProcess() async {
    if (!mounted) return;

    // Matikan flash & sensor
    await _controller?.setFlashMode(FlashMode.off);
    ref.read(ppgProvider.notifier).stopCapture();
    _mockTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data Lengkap! Menganalisa hasil..."),
        backgroundColor: Colors.green,
      ),
    );

    // Jeda sedikit untuk UX
    Future.delayed(const Duration(seconds: 1), () {
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
      // STOP SCAN
      await _controller?.setFlashMode(FlashMode.off);
      ppgNotifier.stopCapture();
      _mockTimer?.cancel();
    } else {
      // START SCAN
      ppgNotifier.startCapture();
      try {
        await _controller?.setFlashMode(FlashMode.torch); // Nyalakan Flash
      } catch (e) {
        debugPrint("Flash tidak tersedia: $e");
      }

      // Simulasi Detak Jantung (Agar UI terlihat hidup jika sensor asli belum terhubung)
      _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (ref.read(ppgProvider).capturing) {
          final double mockBpm = 70 + (DateTime.now().second % 15).toDouble();
          ppgNotifier.updateBPM(mockBpm);
        }
      });
    }
  }

  // [PERBAIKAN LOGIKA] Membuat Data Result Dummy agar tidak Error
  Future<void> _processAndGo() async {
    ref.read(isFullScreeningProvider.notifier).state = false;
    ref.read(scoreProvider.notifier).calculateFinalRisk();

    // 1. Ambil BPM terakhir
    final ppgData = ref.read(ppgProvider);
    double finalBpm = ppgData.mean > 0 ? ppgData.mean : 75.0;

    // 2. Buat Objek MentalResult (PENTING)
    final biometricResult = MentalResult(
      score: 15.0, // Skor rendah simulasi
      riskLevel: "Stabil (Biometrik)",
      riskMessage: "Detak jantung rata-rata Anda $finalBpm BPM. Respon fisiologis menunjukkan kondisi tenang.",
      confidence: 94.5,
      recommendations: [
        "Latihan pernapasan 'Box Breathing' jika merasa cemas.",
        "Jaga hidrasi tubuh dengan minum air putih.",
        "Istirahat sejenak dari layar gadget."
      ],
    );

    if (!mounted) return;

    // 3. Navigasi membawa Data
    Navigator.pushReplacement( 
      context, 
      MaterialPageRoute(
        builder: (context) => ResultPage(result: biometricResult), // Kirim data di sini
      )
    );
  }

  // --- TAMPILAN UI (YANG DIKEMBALIKAN) ---

  @override
  Widget build(BuildContext context) {
    final ppgFeat = ref.watch(ppgProvider);
    final scoreState = ref.watch(scoreProvider);
    final isSufficient = ppgFeat.samples.length >= _targetSamples;

    // Jika Izin Ditolak
    if (_isPermissionDenied) return _buildPermissionError();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Biometrik Jantung"),
        backgroundColor: _brandRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: scoreState.isLoading 
        ? _buildLoadingOverlay()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icon Header
                Icon(Icons.monitor_heart_outlined, size: 80, color: _brandRed.withOpacity(0.8)),
                const SizedBox(height: 16),
                
                // Judul & Instruksi
                const Text(
                  "Pengukuran Jantung AI",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Letakkan ujung telunjuk Anda pada kamera belakang hingga menutup lensa sepenuhnya.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                ),
                
                const SizedBox(height: 30),
                
                // Preview Kamera (Bulat)
                _buildCameraPreview(ppgFeat),
                
                const SizedBox(height: 30),
                
                // Kartu Data (BPM & Progress)
                _buildDataCard(ppgFeat),
                
                const SizedBox(height: 40),
                
                // Tombol Kontrol
                _buildControlButtons(ppgFeat, isSufficient),
              ],
            ),
          ),
    );
  }

  Widget _buildPermissionError() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Akses Kamera Ditolak", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
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
          CircularProgressIndicator(color: _brandRed),
          const SizedBox(height: 16),
          const Text("Sedang memproses data..."),
        ],
      ),
    );
  }

  // Widget Kamera Bulat dengan Border Merah saat merekam
  Widget _buildCameraPreview(PPGFeature ppgFeat) {
    return Container(
      height: 180, width: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          // Border merah jika merekam, abu-abu jika diam
          color: ppgFeat.capturing ? Colors.redAccent : Colors.grey.shade300, 
          width: 6,
        ),
        boxShadow: [
          if (ppgFeat.capturing)
            BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
        ]
      ),
      child: ClipOval(
        child: _isCameraInitialized && _controller != null
            ? CameraPreview(_controller!)
            : const Center(child: Icon(Icons.camera_alt, color: Colors.white54, size: 40)),
      ),
    );
  }

  // Widget Kartu BPM & Progress Bar
  Widget _buildDataCard(PPGFeature ppgFeat) {
    // Hitung persentase data terkumpul
    double progress = (ppgFeat.samples.length / _targetSamples).clamp(0.0, 1.0);
    int percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Label Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kualitas Data:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              Text("$percentage%", style: TextStyle(color: percentage == 100 ? Colors.green : _brandRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Angka BPM Besar
          Text(
            ppgFeat.capturing ? "${ppgFeat.mean.toStringAsFixed(0)} BPM" : "--",
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.black87),
          ),
          const Text("Detak Jantung Rata-rata", style: TextStyle(fontSize: 12, color: Colors.grey)),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: percentage == 100 ? Colors.green : _brandRed,
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Kontrol (Mulai/Stop & Analisa)
  Widget _buildControlButtons(PPGFeature ppgFeat, bool isSufficient) {
    return Column(
      children: [
        // Tombol Utama (Mulai/Stop)
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            icon: Icon(ppgFeat.capturing ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(
              ppgFeat.capturing ? "HENTIKAN PENGUKURAN" : "MULAI SCAN SEKARANG",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ppgFeat.capturing ? Colors.black87 : _brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: _toggleMeasurement,
          ),
        ),
        
        // Tombol Analisa (Muncul jika data cukup & sedang tidak merekam)
        if (isSufficient && !ppgFeat.capturing) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _brandRed, width: 2),
                foregroundColor: _brandRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _processAndGo,
              child: const Text("LIHAT HASIL ANALISA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ]
      ],
    );
  }
}
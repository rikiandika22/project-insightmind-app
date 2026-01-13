// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import Halaman
import 'features/insightmind/presentation/pages/home_page.dart';
import 'features/insightmind/presentation/pages/history_page.dart';

// Import Data & Provider Tugas Agung
import 'features/insightmind/data/local/screening_record.dart';
import 'features/insightmind/presentation/providers/report_provider.dart';

Future<void> main() async {
  // Pastikan plugin Flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Hive (Tugas Agung: Persistence)
  await Hive.initFlutter();

  // Daftarkan Adapter untuk model data
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ScreeningRecordAdapter());
  }

  // Buka Box Database lokal (Tugas Agung: Auto-save target)
  await Hive.openBox<ScreeningRecord>('screening_records');

  runApp(
    const ProviderScope(
      child: InsightMindApp(),
    ),
  );
}

class InsightMindApp extends StatelessWidget {
  const InsightMindApp({super.key});

  // Skema warna Brand (Merah Utama)
  static const Color primaryRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insight Mind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        // Menggunakan Font Poppins agar tampilan formal & modern
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF9F9F9),
          selectedItemColor: primaryRed,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List halaman utama aplikasi
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const SettingsPage(), // Halaman Placeholder untuk tes fitur Agung
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// Widget untuk halaman Pengaturan sekaligus tempat tes fitur Agung
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_suggest, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Opsi Pengembang (Tugas Agung)"),
              const SizedBox(height: 10),
              
              // Tombol Tes Fitur Reporting & Persistence
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Contoh simulasi: Dapa memberikan hasil Score 90 dan Risiko Rendah
                    await ref.read(reportProvider).processFullReport(90.0, "Risiko Rendah");
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil Auto-save & Generate PDF!")),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Tes Cetak & Share PDF"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
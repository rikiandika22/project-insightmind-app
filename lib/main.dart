// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORT HALAMAN ---
import 'features/insightmind/presentation/pages/home_page.dart';
import 'features/insightmind/presentation/pages/history_page.dart';
import 'features/insightmind/presentation/pages/settings_page.dart'; // Halaman Settings Baru

// --- IMPORT LAINNYA ---
import 'features/insightmind/data/local/screening_record.dart';
import 'features/insightmind/presentation/providers/theme_provider.dart'; // Provider Tema

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Format Tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Database Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScreeningRecordAdapter());
  await Hive.openBox<ScreeningRecord>('screening_records');

  runApp(const ProviderScope(child: InsightMindApp()));
}

// [PENTING] Ubah jadi ConsumerWidget agar bisa baca ThemeProvider
class InsightMindApp extends ConsumerWidget {
  const InsightMindApp({super.key});

  static const Color primaryRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Pantau status tema dari Provider
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Insight Mind',
      debugShowCheckedModeBanner: false,
      
      // 2. Pasang Variable Mode Tema
      themeMode: themeMode,

      // 3. TEMA TERANG (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        useMaterial3: true,
      ),

      // 4. TEMA GELAP (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam Pekat
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F), // Abu Gelap
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Daftar Halaman
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const SettingsPage(), // [SUKSES] Halaman Settings dipasang di sini
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
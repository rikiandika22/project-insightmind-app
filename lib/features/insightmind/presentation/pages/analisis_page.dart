// lib/features/insightmind/presentation/pages/analisis_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Pastikan path import ini benar sesuai struktur foldermu
import '../../data/local/screening_record.dart';

class AnalisisPage extends StatefulWidget {
  const AnalisisPage({super.key});

  @override
  State<AnalisisPage> createState() => _AnalisisPageState();
}

class _AnalisisPageState extends State<AnalisisPage> {
  late Box<ScreeningRecord> screeningBox;

  final Color primaryColor = Colors.indigo;
  final Color softPurple = const Color(0xFFD1C4E9);
  final Color softGreen = const Color(0xFFA5D6A7);

  @override
  void initState() {
    super.initState();
    screeningBox = Hive.box<ScreeningRecord>('screening_records');
  }

  @override
  Widget build(BuildContext context) {
    // [LOGIKA TEMA]
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Warna-warna adaptif
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final chartBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Analytics Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: cardColor, // AppBar adaptif
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: screeningBox.listenable(),
        builder: (context, Box<ScreeningRecord> box, _) {
          if (box.isEmpty) {
            return _buildEmptyState(subTextColor!);
          }

          List<ScreeningRecord> records = box.values.toList();
          records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          List<ScreeningRecord> reversedRecords = List.from(records.reversed);

          double rawAvg = records.map((e) => e.score).reduce((a, b) => a + b) / records.length;
          double avgScore = rawAvg > 1 ? rawAvg : rawAvg * 100;
          
          String latestRisk = records.last.riskLevel;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SUMMARY CARDS
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Rata-rata Skor",
                        avgScore.toStringAsFixed(1),
                        Icons.insights_rounded,
                        isDarkMode ? Colors.deepPurple.shade900 : softPurple, // Warna card gelap di dark mode
                        isDarkMode ? Colors.purpleAccent : Colors.deepPurple, // Warna teks kontras
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "Status Terkini",
                        latestRisk,
                        Icons.health_and_safety_rounded,
                        isDarkMode ? Colors.green.shade900 : softGreen,
                        isDarkMode ? Colors.lightGreenAccent : Colors.green[800]!,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. TREND CHART
                Text(
                  "Trend Kesehatan Mental",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
                  decoration: BoxDecoration(
                    color: chartBgColor, // Background chart adaptif
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.3) : primaryColor.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LineChart(_buildChartData(records, isDarkMode)), // Kirim isDarkMode
                ),

                const SizedBox(height: 24),

                // 3. AI INSIGHT BOX (Tetap Gradient, jadi aman)
                _buildAIInsightBox(records.last),

                const SizedBox(height: 24),

                // 4. RIWAYAT LIST
                Text(
                  "Riwayat Screening",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reversedRecords.length,
                  itemBuilder: (context, index) {
                    final item = reversedRecords[index];
                    final displayScore = item.score > 1 ? item.score : item.score * 100;

                    return Card(
                      elevation: 0,
                      color: cardColor, // Card list adaptif
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDarkMode ? Colors.grey[800]! : Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColor(displayScore).withOpacity(0.2),
                          child: Text(
                            "${displayScore.toInt()}",
                            style: TextStyle(
                              color: _getColor(displayScore),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item.riskLevel,
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(item.timestamp),
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  LineChartData _buildChartData(List<ScreeningRecord> records, bool isDarkMode) {
    // Warna grid dan teks chart adaptif
    final gridColor = isDarkMode ? Colors.grey[800]! : Colors.grey.shade200;
    final labelColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return LineChartData(
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: gridColor, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < records.length) {
                final date = records[index].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d MMM', 'id_ID').format(date),
                    style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(color: labelColor, fontSize: 12),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (records.length - 1).toDouble(),
      minY: 0,
      maxY: 105, 
      lineBarsData: [
        LineChartBarData(
          spots: records.asMap().entries.map((e) {
            double val = e.value.score > 1 ? e.value.score : e.value.score * 100;
            return FlSpot(e.key.toDouble(), val.clamp(0, 100));
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          color: primaryColor, // Garis tetap warna utama (Indigo)
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.3),
                primaryColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightBox(ScreeningRecord lastRecord) {
    final score = lastRecord.score > 1 ? lastRecord.score : lastRecord.score * 100; 
    
    String insightText;
    if (score > 80) {
      insightText = "Pola menunjukkan tingkat stres tinggi. AI menyarankan jeda istirahat dan konsultasi.";
    } else if (score > 50) {
      insightText = "Kondisi stabil, namun ada indikasi kelelahan ringan. Pertahankan pola tidur.";
    } else {
      insightText = "Kondisi mental sangat baik! Produktivitas Anda sedang dalam fase optimal.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 20),
              SizedBox(width: 8),
              Text("AI Insight", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(insightText, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Dashboard Kosong", style: TextStyle(color: textColor, fontSize: 16)),
        ],
      ),
    );
  }

  Color _getColor(double score) {
    if (score <= 50) return Colors.green;
    if (score <= 80) return Colors.orange;
    return Colors.red;
  }
}
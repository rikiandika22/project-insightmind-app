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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Analytics Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: screeningBox.listenable(),
        builder: (context, Box<ScreeningRecord> box, _) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }

          List<ScreeningRecord> records = box.values.toList();
          records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          List<ScreeningRecord> reversedRecords = List.from(records.reversed);

          // [PERBAIKAN 1] Rata-rata dikali 100
          double avgScore = (records.map((e) => e.score).reduce((a, b) => a + b) /
              records.length) * 100;
          
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
                        avgScore.toStringAsFixed(1), // Akan tampil misal "40.0"
                        Icons.insights_rounded,
                        softPurple,
                        Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "Status Terkini",
                        latestRisk,
                        Icons.health_and_safety_rounded,
                        softGreen,
                        Colors.green[800]!,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. TREND CHART
                const Text(
                  "Trend Kesehatan Mental",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  padding: const EdgeInsets.only(
                    right: 24,
                    left: 10,
                    top: 24,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LineChart(_buildChartData(records)),
                ),

                const SizedBox(height: 24),

                // 3. AI INSIGHT BOX
                _buildAIInsightBox(records.last),

                const SizedBox(height: 24),

                // 4. RIWAYAT LIST
                const Text(
                  "Riwayat Screening",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reversedRecords.length,
                  itemBuilder: (context, index) {
                    final item = reversedRecords[index];
                    // [PERBAIKAN 2] Konversi ke skala 100
                    final scoreScaled = item.score * 100; 

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColor(scoreScaled).withValues(alpha: 0.2),
                          child: Text(
                            "${scoreScaled.toInt()}", // Tampil "40" bukan "0"
                            style: TextStyle(
                              color: _getColor(scoreScaled),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item.riskLevel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(item.timestamp),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  LineChartData _buildChartData(List<ScreeningRecord> records) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
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
                // Gunakan format HH:mm jika tanggalnya sama semua agar terlihat bedanya
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d MMM', 'id_ID').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const Text('');
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
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (records.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: records.asMap().entries.map((e) {
            // [PERBAIKAN 3] Skor dikali 100 agar muncul di grafik
            return FlSpot(e.key.toDouble(), e.value.score.toDouble() * 100);
          }).toList(),
          isCurved: true,
          color: primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.2),
                primaryColor.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
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
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildAIInsightBox(ScreeningRecord lastRecord) {
    // [PERBAIKAN 4] Logika insight menyesuaikan skala data asli (0-1) atau dikali 100
    // Karena kita memakai lastRecord.score (masih 0-1), kita kali 100 di kondisi if
    final score = lastRecord.score * 100; 
    
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
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 20),
              const SizedBox(width: 8),
              Text("AI Insight", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(insightText, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Dashboard Kosong", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
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
// lib/features/insightmind/presentation/pages/article_detail_page.dart

import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // [LOGIKA TEMA]
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Warna teks adaptif
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    final metaColor = isDarkMode ? Colors.grey[400] : Colors.grey;

    // [LOGIKA PINTAR] Cek apakah gambar dari Internet (URL) atau Aset Lokal
    final bool isOnline = article.imageUrl.startsWith('http');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // BAGIAN HEADER GAMBAR
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.red,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Baca Artikel",
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              // [PERBAIKAN] Logika memilih Image.network atau Image.asset
              background: isOnline
                  ? Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(isDarkMode),
                    )
                  : Image.asset(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(isDarkMode),
                    ),
            ),
          ),
          
          // BAGIAN ISI ARTIKEL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Info Penulis
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: metaColor),
                      const SizedBox(width: 5),
                      Text(article.author, style: TextStyle(color: metaColor)),
                      const SizedBox(width: 20),
                      Icon(Icons.calendar_today_outlined, size: 16, color: metaColor),
                      const SizedBox(width: 5),
                      Text(article.date, style: TextStyle(color: metaColor)),
                    ],
                  ),
                  
                  Divider(
                    height: 40, 
                    thickness: 1, 
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300]
                  ),
                  
                  // Konten Bacaan
                  Text(
                    article.content,
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.8, 
                      color: contentColor,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tampilan jika gambar gagal dimuat
  Widget _buildErrorWidget(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.white54, size: 50),
            SizedBox(height: 8),
            Text("Gambar tidak ditemukan", style: TextStyle(color: Colors.white54, fontSize: 12))
          ],
        ),
      ),
    );
  }
}
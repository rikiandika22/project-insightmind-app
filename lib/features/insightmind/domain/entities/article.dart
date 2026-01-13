// lib/features/insightmind/domain/entities/article.dart

class Article {
  final String title;
  final String author;
  final String date;
  final String imageUrl; // URL untuk foto dari internet (Unsplash)
  final String summary;  // Ringkasan pendek untuk di Card Home
  final String content;  // Isi bacaan lengkap

  Article({
    required this.title,
    required this.author,
    required this.date,
    required this.imageUrl,
    required this.summary,
    required this.content,
  });
}
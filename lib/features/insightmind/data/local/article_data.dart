// lib/features/insightmind/data/local/article_data.dart

import '../../domain/entities/article.dart';

final List<Article> mentalHealthArticles = [
  Article(
    title: "Teknik Grounding 5-4-3-2-1",
    author: "Dr. Sarah",
    date: "14 Jan 2026",
    // Gambar: Alam tenang
    imageUrl:
        "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&q=80",
    summary: "Cara cepat meredakan serangan panik dalam 5 menit.",
    content: """
Kecemasan bisa menyerang kapan saja. Salah satu cara tercepat untuk kembali tenang adalah teknik Grounding 5-4-3-2-1.

Caranya adalah dengan mengidentifikasi:
1. 5 hal yang bisa Anda LIHAT.
2. 4 hal yang bisa Anda SENTUH.
3. 3 hal yang bisa Anda DENGAR.
4. 2 hal yang bisa Anda CIUM aromanya.
5. 1 hal yang bisa Anda RASA.

Lakukan ini secara perlahan sambil mengatur napas.
    """,
  ),
  Article(
    title: "Detox Digital & Mental",
    author: "Tim InsightMind",
    date: "12 Jan 2026",
    // Gambar: Orang membaca buku (Tanpa HP)
    imageUrl:
        "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80",
    summary: "Mengapa rehat dari media sosial membuat Anda lebih bahagia.",
    content: """
Sering merasa lelah atau insecure setelah scrolling media sosial? Paparan terus-menerus terhadap "kehidupan sempurna" orang lain dapat memicu perasaan tidak cukup baik.

Cobalah melakukan Digital Detox sederhana:
- Matikan notifikasi setelah jam 8 malam.
- Jangan buka HP 1 jam setelah bangun tidur.
- Hapus aplikasi yang membuat Anda merasa buruk.
    """,
  ),
  Article(
    title: "Tidur Nyenyak = Emosi Stabil",
    author: "Prof. Sleep",
    date: "10 Jan 2026",
    // [LINK BARU] Gambar: Suasana kamar tidur yang estetik dan nyaman
    imageUrl:
        "https://images.unsplash.com/photo-1519682337058-a94d519337bc?q=80&w=800",
    summary: "Hubungan erat antara kualitas tidur dan manajemen stres.",
    content: """
Kurang tidur bukan hanya membuat fisik lelah, tapi juga membuat "sumbu pendek" pada emosi kita. Saat kurang tidur, bagian otak yang memproses emosi (amigdala) menjadi 60% lebih reaktif.

Tips tidur nyenyak:
1. Hindari kafein setelah jam 2 siang.
2. Gunakan lampu tidur yang redup dan hangat.
3. Jaga suhu kamar tetap sejuk.
4. Lakukan rutinitas yang sama setiap malam agar otak mengenali sinyal tidur.
    """,
  ),
];

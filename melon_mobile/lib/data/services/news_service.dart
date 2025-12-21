import 'package:dio/dio.dart';

class Code {
  final String title;
  final String source;
  final String summary;
  final String imageUrl;
  final DateTime publishedAt;
  final String url;

  Code({
    required this.title,
    required this.source,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });
}

class NewsArticle {
  final String title;
  final String source;
  final String summary;
  final String imageUrl;
  final DateTime publishedAt;
  final String url;

  NewsArticle({
    required this.title,
    required this.source,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['headline'] ?? "No Title",
      source: json['source'] ?? "Melon News",
      summary: json['summary'] ?? "",
      imageUrl: json['image'] ?? "",
      publishedAt: DateTime.fromMicrosecondsSinceEpoch((json['datetime'] ?? 0) * 1000),
      url: json['url'] ?? "",
    );
  }
}

class NewsService {
  final Dio _dio = Dio();

  // Mock Data generator
  Future<List<NewsArticle>> getMarketNews() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      NewsArticle(
        title: "Bitcoin Surges Past \$45k as ETF Approval Looms",
        source: "CryptoDaily",
        summary: "The crypto market is rallying ahead of the expected SEC decision on Bitcoin Spot ETFs.",
        imageUrl: "https://via.placeholder.com/150",
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        url: "",
      ),
      NewsArticle(
        title: "Apple Unveils New AI Features for iPhone",
        source: "TechCrunch",
        summary: "Apple's latest iOS update integrates advanced generative AI capabilities directly into the OS.",
        imageUrl: "https://via.placeholder.com/150",
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        url: "",
      ),
      NewsArticle(
        title: "Fed Signals Potential Rate Cuts in 2024",
        source: "Bloomberg",
        summary: "Jerome Powell hints that inflation is cooling faster than expected, opening the door for cuts.",
        imageUrl: "https://via.placeholder.com/150",
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        url: "",
      ),
      NewsArticle(
        title: "Tesla Earnings Miss Estimates, Stock Dips 5%",
        source: "Reuters",
        summary: "EV maker faces margin pressure amidst price war in China and Europe.",
        imageUrl: "https://via.placeholder.com/150",
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        url: "",
      ),
    ];
  }
}

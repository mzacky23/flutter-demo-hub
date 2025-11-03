class News {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String author;
  final String source;

  const News({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.author,
    required this.source,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      author: json['author'] ?? 'Unknown',
      source: json['source']['name'] ?? 'Unknown Source',
    );
  }
  // Generete ID untuk Bookmark
  String get id => '${title}_${publishedAt}'.hashCode.toString();
}

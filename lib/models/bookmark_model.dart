import 'package:belajar_flutter/models/news_model.dart';
import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 0)
class Bookmark {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String urlToImage;

  @HiveField(5)
  final String source;

  @HiveField(6)
  final String publishedAt;

  @HiveField(7)
  final DateTime savedAt;

  Bookmark({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.source,
    required this.publishedAt,
    required this.savedAt,
  });

  // convert dari news ke bookmark
  factory Bookmark.formNews(News news) {
    return Bookmark(
      id: news.id,
      title: news.title,
      description: news.description,
      url: news.url,
      urlToImage: news.urlToImage,
      source: news.source,
      publishedAt: news.publishedAt,
      savedAt: DateTime.now(),
    );
  }
}

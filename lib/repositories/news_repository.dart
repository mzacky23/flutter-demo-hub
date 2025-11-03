import 'package:dio/dio.dart';
import '../models/news_model.dart';

class NewsRepository {
  final Dio _dio = Dio();
  final String _apiKey = '6bf7d564f1e142f3a4b28c1881ff3a0f';
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<News>> fetchNews() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'country': 'us',
          'apiKey': _apiKey,
          'pageSize': 20
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  Future<List<News>> searchNews(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/everything',
        queryParameters: {
          'q': query,
          'apiKey': _apiKey,
          'pageSize': 20,
          'sortBy': 'publishedAt',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }
}
import '../../models/news_model.dart';

class NewsState {
  final List<News> news;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const NewsState({
    required this.news,
    required this.isLoading,
    this.error,
    required this.searchQuery,
  });

  // initial state
  factory NewsState.initial() {
    return const NewsState(
      news: [],
      isLoading: false,
      error: null,
      searchQuery: '',
    );
  }

  // copy with method
  NewsState copyWith({
    List<News>? news,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return NewsState(
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

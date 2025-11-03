import 'package:belajar_flutter/repositories/news_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepository;

  NewsCubit({required this.newsRepository}) : super(NewsState.initial()) {
    loadNews();
  }

  // Load berita
  Future<void> loadNews() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final news = await newsRepository.fetchNews();
      emit(state.copyWith(news: news, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load news: $e'));
    }
  }

  // search berita
  void searchNews(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  //  Clear search
  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }

  // Refresh berita
  Future<void> refreshNews() async {
    await loadNews();
  }
}

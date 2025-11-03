import 'package:belajar_flutter/blocs/weather/weather_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../models/bookmark_city.dart';
import '../../models/weather_model.dart';

class BookmarkCityCubit extends Cubit<BookmarkCityState> {
  final Box<BookmarkCity> bookmarkBox;

  BookmarkCityCubit({required this.bookmarkBox}) : super(BookmarkCityInitial());

  List<BookmarkCity> get bookmarks => bookmarkBox.values.toList();

  Future<void> loadBookmarks() async {
    try {
      emit(BookmarkCityLoading());
      final bookmarksList = bookmarks;
      emit(BookmarkCityLoaded(bookmarksList));
    } catch (e) {
      emit(BookmarkCityError('Failed to load bookmarks'));
    }
  }

  Future<void> addBookmarkCity(BookmarkCity bookmark) async {
    try {
      // Check if bookmark already exists
      final existingBookmark = bookmarks.firstWhere(
        (b) => b.city == bookmark.city && b.country == bookmark.country,
        orElse: () => BookmarkCity(
          city: '',
          country: '',
          lat: 0,
          lon: 0,
          savedAt: DateTime.now(),
        ),
      );

      if (existingBookmark.city.isNotEmpty) {
        emit(BookmarkCityError('${bookmark.displayName} is already bookmarked'));
        return;
      }

      await bookmarkBox.add(bookmark);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarkCityError('Failed to add bookmark'));
    }
  }

  Future<void> addBookmarkFromWeather(Weather weather) async {
    final bookmark = BookmarkCity.fromWeather(weather);
    await addBookmarkCity(bookmark);
  }

  Future<void> addBookmarkFromCitySuggestion(CitySuggestion city) async {
    final bookmark = BookmarkCity.fromCitySuggestion(city);
    await addBookmarkCity(bookmark);
  }

  Future<void> removeBookmarkCity(BookmarkCity bookmark) async {
    try {
      final key = _findBookmarkKey(bookmark);
      if (key != null) {
        await bookmarkBox.delete(key);
        await loadBookmarks();
      }
    } catch (e) {
      emit(BookmarkCityError('Failed to remove bookmark'));
    }
  }

  Future<void> removeBookmarkByIndex(int index) async {
    try {
      final key = bookmarkBox.keyAt(index);
      await bookmarkBox.delete(key);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarkCityError('Failed to remove bookmark'));
    }
  }

  Future<void> updateBookmarkWeather(BookmarkCity bookmark, Weather weather) async {
    try {
      final key = _findBookmarkKey(bookmark);
      if (key != null) {
        final updatedBookmark = bookmark.copyWith(
          lastTemperature: weather.formattedTemperature,
          lastDescription: weather.description,
        );
        await bookmarkBox.put(key, updatedBookmark);
        await loadBookmarks();
      }
    } catch (e) {
      // Silent fail for weather updates
    }
  }

  int? _findBookmarkKey(BookmarkCity bookmark) {
    for (var i = 0; i < bookmarkBox.length; i++) {
      final key = bookmarkBox.keyAt(i);
      final currentBookmark = bookmarkBox.get(key);
      if (currentBookmark?.city == bookmark.city && 
          currentBookmark?.country == bookmark.country) {
        return key;
      }
    }
    return null;
  }

  bool isCityBookmarked(String city, String country) {
    return bookmarks.any((b) => b.city == city && b.country == country);
  }

  // Get bookmark by city and country
  BookmarkCity? getBookmarkByCity(String city, String country) {
    try {
      return bookmarks.firstWhere(
        (b) => b.city == city && b.country == country,
      );
    } catch (e) {
      return null;
    }
  }
}

abstract class BookmarkCityState {}

class BookmarkCityInitial extends BookmarkCityState {}

class BookmarkCityLoading extends BookmarkCityState {}

class BookmarkCityLoaded extends BookmarkCityState {
  final List<BookmarkCity> bookmarks;
  BookmarkCityLoaded(this.bookmarks);
}

class BookmarkCityError extends BookmarkCityState {
  final String message;
  BookmarkCityError(this.message);
}
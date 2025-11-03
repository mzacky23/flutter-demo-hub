import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../models/bookmark_model.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final Box<Bookmark> bookmarkBox;

  BookmarkCubit({required this.bookmarkBox}) : super(BookmarkInitial());

  // Load semua bookmark
  void loadBookmarks() {
    try {
      final bookmarks = bookmarkBox.values.toList();
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkError(message: 'Failed to load bookmarks: $e'));
    }
  }

  // Tambah bookmark
  void addBookmark(Bookmark bookmark) {
    try {
      bookmarkBox.put(bookmark.id, bookmark);
      final bookmarks = bookmarkBox.values.toList();
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkError(message: 'Failed to add bookmark: $e'));
    }
  }

  // Hapus bookmark
  void removeBookmark(String id) {
    try {
      bookmarkBox.delete(id);
      final bookmarks = bookmarkBox.values.toList();
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkError(message: 'Failed to remove bookmark: $e'));
    }
  }

  // Cek apakah article sudah di-bookmark
  bool isBookmarked(String id) {
    return bookmarkBox.containsKey(id);
  }
}

// States
abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;

  BookmarkLoaded({required this.bookmarks});
}

class BookmarkError extends BookmarkState {
  final String message;

  BookmarkError({required this.message});
}
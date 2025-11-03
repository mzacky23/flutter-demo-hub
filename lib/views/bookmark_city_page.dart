import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/bookmark/bookmark_city_cubit.dart';
import '../../blocs/weather/weather_cubit.dart';
import '../../models/bookmark_city.dart';

class BookmarkCityPage extends StatelessWidget {
  const BookmarkCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Cities'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookmarkCityCubit>().loadBookmarks();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<BookmarkCityCubit, BookmarkCityState>(
        listener: (context, state) {
          if (state is BookmarkCityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookmarkCityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookmarkCityError) {
            return _buildErrorState(
              context,
              state.message,
            ); // Pass context here
          }

          if (state is BookmarkCityLoaded) {
            final bookmarks = state.bookmarks;

            if (bookmarks.isEmpty) {
              return _buildEmptyState();
            }

            return _buildBookmarksList(bookmarks, context);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Bookmarked Cities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add cities from weather page to see them here',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tambahkan parameter BuildContext di method _buildErrorState
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error Loading Bookmarks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<BookmarkCityCubit>().loadBookmarks();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(
    List<BookmarkCity> bookmarks,
    BuildContext context,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${bookmarks.length} Bookmarked Cit${bookmarks.length == 1 ? 'y' : 'ies'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _buildBookmarkCard(bookmark, context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(
    BookmarkCity bookmark,
    BuildContext context,
    int index,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.location_city,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          bookmark.displayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookmark.lastTemperature != null &&
                bookmark.lastDescription != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bookmark.lastTemperature} • ${bookmark.lastDescription?.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            Text(
              'Coordinates: ${bookmark.lat.toStringAsFixed(2)}, ${bookmark.lon.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            Text(
              'Saved: ${_formatDate(bookmark.savedAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.cloud, color: Colors.blue.shade700),
                onPressed: () {
                  _viewWeather(context, bookmark);
                },
                tooltip: 'View Weather',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                onPressed: () {
                  _showDeleteDialog(context, bookmark, index);
                },
                tooltip: 'Remove Bookmark',
              ),
            ],
          ),
        ),
        onTap: () => _viewWeather(context, bookmark),
      ),
    );
  }

  void _viewWeather(BuildContext context, BookmarkCity bookmark) {
    final weatherCubit = context.read<WeatherCubit>();
    context.read<BookmarkCityCubit>();

    // Get weather for bookmarked city
    weatherCubit.getWeatherByCoordinates(bookmark.lat, bookmark.lon);

    // Navigate back to weather page
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loading weather for ${bookmark.displayName}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BookmarkCity bookmark,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Bookmark'),
          content: Text(
            'Are you sure you want to remove ${bookmark.displayName} from your bookmarks?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<BookmarkCityCubit>().removeBookmarkByIndex(index);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Removed ${bookmark.displayName} from bookmarks',
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

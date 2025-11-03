import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_model.dart';
import '../../models/bookmark_model.dart';
import '../../blocs/news/news_cubit.dart';
import '../../blocs/news/news_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../views/bookmark_view.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // AUTO LOAD: Load news ketika pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().loadNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'News'),
            Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          // Refresh button untuk kedua tab
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (_tabController.index == 0) {
                // Refresh news
                context.read<NewsCubit>().loadNews();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing news...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                // Refresh bookmarks
                context.read<BookmarkCubit>().loadBookmarks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing bookmarks...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: News dengan API integration
          _buildNewsTab(),
          // Tab 2: Bookmarks
          const BookmarkView(),
        ],
      ),
    );
  }

  // METHOD UNTUK NEWS TAB DENGAN API INTEGRATION
  Widget _buildNewsTab() {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        // Loading state - PESAN LEBIH INFORMATIF
        if (state.isLoading && state.news.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading latest news...'),
              ],
            ),
          );
        }

        // Error state
        if (state.error != null && state.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load news',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<NewsCubit>().loadNews(),
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (state.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No news available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.read<NewsCubit>().loadNews(),
                  icon: Icon(Icons.refresh),
                  label: Text('Load News'),
                ),
              ],
            ),
          );
        }

        // Filter news based on search query
        final filteredNews = state.news.where((news) {
          final query = state.searchQuery.toLowerCase();
          return news.title.toLowerCase().contains(query) ||
              news.description.toLowerCase().contains(query);
        }).toList();

        if (filteredNews.isEmpty) {
          return Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No news found for "${state.searchQuery}"',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.read<NewsCubit>().clearSearch(),
                        child: Text('Clear search'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            // Search Bar
            _buildSearchBar(context),
            // LOADING INDICATOR KETIKA REFRESH TAPI SUDAH ADA DATA
            if (state.isLoading && state.news.isNotEmpty)
              LinearProgressIndicator(),
            // News List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<NewsCubit>().refreshNews(),
                child: ListView.builder(
                  itemCount: filteredNews.length,
                  itemBuilder: (context, index) {
                    final news = filteredNews[index];
                    return _NewsItemWidget(news: news);
                  },
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search news...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => context.read<NewsCubit>().clearSearch(),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (query) => context.read<NewsCubit>().searchNews(query),
          ),
        );
      },
    );
  }
}

// OPTIMIZED SEPARATE WIDGET CLASS
class _NewsItemWidget extends StatelessWidget {
  final News news;
  
  const _NewsItemWidget({required this.news});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      buildWhen: (previous, current) {
        // Hanya rebuild jika bookmark status untuk news ini berubah
        final wasBookmarked = previous is BookmarkLoaded && 
            previous.bookmarks.any((b) => b.id == news.id);
        final isBookmarked = current is BookmarkLoaded && 
            current.bookmarks.any((b) => b.id == news.id);
        return wasBookmarked != isBookmarked;
      },
      builder: (context, state) {
        final isBookmarked = state is BookmarkLoaded && 
            state.bookmarks.any((bookmark) => bookmark.id == news.id);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildNewsImage(news.urlToImage),
            title: Text(
              news.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  news.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        news.source,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(news.publishedAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? Colors.blue : Colors.grey,
                size: 28,
              ),
              onPressed: () => _toggleBookmark(context, isBookmarked),
            ),
            onTap: () => _launchNewsUrl(context, news.url),
          ),
        );
      },
    );
  }

  Widget _buildNewsImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.article, size: 40, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.error, color: Colors.red),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _launchNewsUrl(BuildContext context, String url) async {
    // GUARD dengan mounted check untuk async operations
    if (!context.mounted) return;
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open article: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
          ),
        ),
      );
    }
  }

  void _toggleBookmark(BuildContext context, bool isBookmarked) {
    if (isBookmarked) {
      context.read<BookmarkCubit>().removeBookmark(news.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark removed'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final bookmark = Bookmark(
        id: news.id,
        title: news.title,
        description: news.description,
        url: news.url,
        urlToImage: news.urlToImage,
        source: news.source,
        publishedAt: news.publishedAt,
        savedAt: DateTime.now(),
      );
      context.read<BookmarkCubit>().addBookmark(bookmark);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article bookmarked!'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
import 'package:belajar_flutter/blocs/theme/theme_cubit.dart';
import 'package:belajar_flutter/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:belajar_flutter/routes/app_pages.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // CONSTANTS - Prevent rebuild
  static const List<Map<String, dynamic>> _apps = [
    {
      'title': 'Counter',
      'subtitle': 'State Management with BLoC',
      'icon': Icons.trending_up,
      'color': Colors.blue,
      'route': AppPages.counter,
      'badge': 'BLoC',
    },
    {
      'title': 'Todo List',
      'subtitle': 'CRUD Operations + Hive DB',
      'icon': Icons.task_alt,
      'color': Colors.green,
      'route': AppPages.todo,
      'badge': 'Hive',
    },
    {
      'title': 'News Reader',
      'subtitle': 'REST API + Bookmark System',
      'icon': Icons.article,
      'color': Colors.orange,
      'route': AppPages.news,
      'badge': 'API',
    },
    {
      'title': 'Weather',
      'subtitle': 'Real-time Data + Geolocation',
      'icon': Icons.sunny,
      'color': Colors.blue,
      'route': AppPages.weather,
      'badge': 'GPS',
    },
    {
      'title': 'About',
      'subtitle': 'App Information & Tech Stack',
      'icon': Icons.info,
      'color': Colors.purple,
      'route': AppPages.about,
      'badge': 'Info',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'DevHub - Flutter Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: const [
          _ThemeToggleButton(), // EXTRACTED FOR OPTIMIZATION
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(), // EXTRACTED FOR OPTIMIZATION
            SizedBox(height: 30),
            Expanded(child: _AppsGrid()), // EXTRACTED FOR OPTIMIZATION
          ],
        ),
      ),
    );
  }
}

// EXTRACTED WIDGETS FOR BETTER PERFORMANCE

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      buildWhen: (previous, current) => previous.isDark != current.isDark, // ONLY REBUILD WHEN THEME CHANGES
      builder: (context, themeState) {
        return IconButton(
          icon: Icon(
            themeState.isDark ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          tooltip: themeState.isDark ? 'Light Mode' : 'Dark Mode',
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      buildWhen: (previous, current) => previous.isDark != current.isDark, // OPTIMIZED REBUILD
      builder: (context, themeState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter Demo Collection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeState.isDark ? Colors.white : Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kumpulan aplikasi demo untuk showcase Flutter development',
              style: TextStyle(
                fontSize: 14,
                color: themeState.isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const _StatsRow(), // EXTRACTED
          ],
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        return Row(
          children: [
            _StatItem(count: '4', label: 'Apps', isDarkMode: themeState.isDark),
            const SizedBox(width: 16),
            _StatItem(count: '5+', label: 'Features', isDarkMode: themeState.isDark),
            const SizedBox(width: 16),
            _StatItem(count: '100%', label: 'Flutter', isDarkMode: themeState.isDark),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final bool isDarkMode;

  const _StatItem({
    required this.count,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple, // CONSTANT COLOR - NO REBUILD NEEDED
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _AppsGrid extends StatelessWidget {
  const _AppsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: HomeView._apps.length,
      itemBuilder: (context, index) {
        final app = HomeView._apps[index];
        return _AppCard(app: app); // EXTRACTED
      },
    );
  }
}

class _AppCard extends StatelessWidget {
  final Map<String, dynamic> app;

  const _AppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      buildWhen: (previous, current) => previous.isDark != current.isDark, // OPTIMIZED
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDark;
        final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
        final Color borderColor = isDarkMode ? Colors.grey[700]! : Colors.transparent;
        final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
        final Color subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

        return Card(
          elevation: isDarkMode ? 2 : 6,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(context, app['route'] as String);
            },
            onLongPress: () {
              _showAppDetails(context, app, isDarkMode);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  if (app['badge'] != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: _AppBadge(app: app), // EXTRACTED
                    ),
                  
                  // Icon
                  _AppIcon(app: app, isDarkMode: isDarkMode), // EXTRACTED
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    app['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    app['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAppDetails(BuildContext context, Map<String, dynamic> app, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Row(
          children: [
            Icon(app['icon'] as IconData, color: app['color'] as Color),
            const SizedBox(width: 8),
            Text(
              app['title'] as String,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          app['subtitle'] as String,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, app['route'] as String);
            },
            child: const Text('Open App'),
          ),
        ],
      ),
    );
  }
}

class _AppBadge extends StatelessWidget {
  final Map<String, dynamic> app;

  const _AppBadge({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (app['color'] as Color).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        app['badge'] as String,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: app['color'] as Color,
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final Map<String, dynamic> app;
  final bool isDarkMode;

  const _AppIcon({required this.app, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (app['color'] as Color).withOpacity(isDarkMode ? 0.2 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        app['icon'] as IconData,
        size: 28,
        color: app['color'] as Color,
      ),
    );
  }
}
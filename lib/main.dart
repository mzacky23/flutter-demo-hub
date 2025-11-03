import 'package:belajar_flutter/blocs/weather/weather_cubit.dart';
import 'package:belajar_flutter/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

// Models
import 'models/bookmark_model.dart';
import 'models/bookmark_city.dart';
import 'models/todo_model.dart';

// Cubits - TAMBAH THEME CUBIT
import 'blocs/theme/theme_cubit.dart';
import 'blocs/counter/counter_cubit.dart';
import 'blocs/todo/todo_cubit.dart';
import 'blocs/news/news_cubit.dart';
import 'blocs/bookmark/bookmark_cubit.dart';
import 'blocs/bookmark/bookmark_city_cubit.dart';

// Repository
import 'repositories/news_repository.dart';

// Routes
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initializeHive();

  runApp(MyApp());
}

Future<void> _initializeHive() async {
  if (!kIsWeb) {
    final appDocumentDirectory = await path_provider
        .getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } else {
    await Hive.initFlutter();
  }

  // Register semua Hive adapters
  Hive.registerAdapter(BookmarkAdapter());
  Hive.registerAdapter(BookmarkCityAdapter());
  Hive.registerAdapter(TodoAdapter());

  // Open semua boxes - TAMBAH THEME BOX
  await Hive.openBox<Bookmark>('bookmarks');
  await Hive.openBox<BookmarkCity>('bookmark_cities');
  await Hive.openBox<Todo>('todos');
  await Hive.openBox('theme_preferences');
}

bool get kIsWeb => identical(0, 0.0);

class MyApp extends StatelessWidget {
  final NewsRepository newsRepository = NewsRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TAMBAH THEME CUBIT DI SINI ↓
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<WeatherCubit>(
          // ← TAMBAH INI
          create: (context) => WeatherCubit(),
        ),
        BlocProvider<CounterCubit>(create: (context) => CounterCubit()),
        BlocProvider<TodoCubit>(
          create: (context) => TodoCubit(todoBox: Hive.box<Todo>('todos')),
        ),
        BlocProvider<NewsCubit>(
          create: (context) => NewsCubit(newsRepository: newsRepository),
        ),
        BlocProvider<BookmarkCubit>(
          create: (context) =>
              BookmarkCubit(bookmarkBox: Hive.box<Bookmark>('bookmarks'))
                ..loadBookmarks(),
        ),
        BlocProvider<BookmarkCityCubit>(
          create: (context) => BookmarkCityCubit(
            bookmarkBox: Hive.box<BookmarkCity>('bookmark_cities'),
          )..loadBookmarks(),
        ),
      ],
      // TAMBAH BLOCBUILDER UNTUK THEME ↓
      child: BlocBuilder<ThemeCubit, ThemeModel>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Learning Hub',
            theme: themeState.themeData, // ← PAKAI THEME DARI CUBIT
            initialRoute: '/',
            routes: AppPages.routes,
          );
        },
      ),
    );
  }
}

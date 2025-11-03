import 'package:belajar_flutter/modules/weather/weather_view.dart';
import 'package:belajar_flutter/views/bookmark_city_page.dart';
import 'package:flutter/material.dart';

import '../modules/home/home_view.dart';
import '../modules/about/about_view.dart';
import '../modules/counter/counter_view.dart';
import '../modules/todo/todo_view.dart';
import '../modules/news/news_view.dart'; 

class AppPages {
  static const String home = '/';
  static const String about = '/about';
  static const String counter = '/counter';
  static const String todo = '/todo';
  static const String news = '/news';
  static const String weather = '/weather';
  static const String bookmarkCity = '/bookmark_city';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeView(),
        about: (context) => const AboutView(),
        counter: (context) => const CounterView(),
        todo: (context) => const TodoView(),
        news: (context) => const NewsView(),
        weather: (context) => const WeatherView(),
        bookmarkCity: (context) => const BookmarkCityPage(),
      };
}
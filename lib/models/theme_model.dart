import 'package:flutter/material.dart';

enum AppTheme { light, dark }

class ThemeModel {
  final AppTheme theme;
  final ThemeData themeData;

  ThemeModel({required this.theme, required this.themeData});

  bool get isDark => theme == AppTheme.dark;
}
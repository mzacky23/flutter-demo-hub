import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../../models/theme_model.dart';

class ThemeCubit extends Cubit<ThemeModel> {
  static const String _boxName = 'theme_preferences';
  static const String _themeKey = 'current_theme';
  final Logger _logger = Logger();

  ThemeCubit() : super(ThemeModel(
    theme: AppTheme.light,
    themeData: _buildLightTheme(),
  )) {
    _loadTheme();
  }

  // Load theme dari Hive
  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_boxName);
      final themeIndex = box.get(_themeKey, defaultValue: 0);
      final savedTheme = AppTheme.values[themeIndex];
      
      emit(ThemeModel(
        theme: savedTheme,
        themeData: savedTheme == AppTheme.light 
            ? _buildLightTheme() 
            : _buildDarkTheme(),
      ));
    } catch (e) {
      _logger.e('Error loading theme: $e');
    }
  }

  // Toggle theme dan save ke Hive
  Future<void> toggleTheme() async {
    try {
      final newTheme = state.theme == AppTheme.light 
          ? AppTheme.dark 
          : AppTheme.light;
      
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, newTheme.index);
      
      emit(ThemeModel(
        theme: newTheme,
        themeData: newTheme == AppTheme.light 
            ? _buildLightTheme() 
            : _buildDarkTheme(),
      ));
    } catch (e) {
      _logger.e('Error saving theme: $e');
    }
  }

  // Light Theme - SIMPLE & CLEAN
  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // HAPUS cardTheme untuk sementara - kita handle di widget langsung
    );
  }

  // Dark Theme - SIMPLE & CLEAN
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      dialogBackgroundColor: Colors.grey[800],
      // HAPUS cardTheme untuk sementara - kita handle di widget langsung
    );
  }
}
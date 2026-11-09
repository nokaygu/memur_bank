import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Aydınlık (Light) ve Koyu (Dark) tema durumunu yöneten Cubit.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  bool get isDark => state == ThemeMode.dark;

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_application/core/theme/app_theme.dart';

class ThemeState {
  final bool isDark;
  final Color secondaryColor;

  ThemeState({
    required this.isDark,
    required this.secondaryColor,
  });

  ThemeState copyWith({
    bool? isDark,
    Color? secondaryColor,
  }) {
    return ThemeState(
      isDark: isDark ?? this.isDark,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          isDark: true,
          secondaryColor: Colors.orange,
        ));

  void toggleTheme() {
    state = state.copyWith(isDark: !state.isDark);
  }

  void updateSector(String sector) {
    final color = AppTheme.getSecondaryColorForSector(sector);
    state = state.copyWith(secondaryColor: color);
  }

  void resetColor() {
    state = state.copyWith(secondaryColor: Colors.orange);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

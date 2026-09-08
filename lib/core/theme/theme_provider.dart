import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeOption {
  linenDay('Linen Day'),
  midnightOled('Midnight OLED'),
  system('System');

  final String label;
  const AppThemeOption(this.label);
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeOption>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<AppThemeOption> {
  ThemeModeNotifier() : super(AppThemeOption.linenDay);

  void setTheme(AppThemeOption option) {
    state = option;
  }

  void setThemeFromLabel(String label) {
    if (label.contains('Midnight')) {
      state = AppThemeOption.midnightOled;
    } else if (label.contains('System')) {
      state = AppThemeOption.system;
    } else {
      state = AppThemeOption.linenDay;
    }
  }
}

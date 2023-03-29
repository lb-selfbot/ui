import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lightningui/utils/color.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';

class ThemeService extends ChangeNotifier {
  ThemeData _defaultDark = ThemeData.dark(useMaterial3: true);
  ThemeData _defaultLight = ThemeData.light(useMaterial3: true);

  late ThemeData _themeData;
  String themeString = '';

  static final builtins = {
    "Dark": const Color(0xFF1B2D48),
    "Light": const Color(0xFFE5E5E5),
  };

  ThemeService() {
    _defaultDark = _defaultDark.copyWith(
      splashFactory: InkRipple.splashFactory,
      cardTheme: const CardTheme(
        elevation: 16,
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: GoogleFonts.montserrat(),
        unselectedLabelStyle: GoogleFonts.montserrat(),
      ),
    );

    _defaultLight = _defaultLight.copyWith(
      splashFactory: InkRipple.splashFactory,
      cardTheme: const CardTheme(
        elevation: 16,
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: GoogleFonts.montserrat(),
        unselectedLabelStyle: GoogleFonts.montserrat(),
      ),
    );

    getIt<ConfigService>().addListener(onConfigChange);

    onConfigChange();
  }

  void onConfigChange() {
    final theme = getIt<ConfigService>().config["UI"]["Theme"] as String?;

    if (theme != themeString) {
      setThemeString(theme ?? "Dark");
    }
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData, {String? themeString}) {
    _themeData = themeData;

    if (themeString != null) {
      this.themeString = themeString;
    }

    notifyListeners();
  }

  void setThemeColor(Color color, {String? themeString}) {
    Brightness brightness = Brightness.dark;

    final double relativeLuminance = color.computeLuminance();
    const double kThreshold = 0.0525;
    if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
      brightness = Brightness.light;
    }

    final dark = brightness == Brightness.dark;

    final defaultTheme = dark ? _defaultDark : _defaultLight;

    final colorScheme = SeedColorScheme.fromSeeds(
      brightness: brightness,
      primaryKey: color,
      tones: FlexTones.jolly(brightness),
    );

    final themeData = defaultTheme.copyWith(
      primaryColor: color,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.montserratTextTheme(
        dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      cardTheme: CardTheme(
        color: colorScheme.primaryContainer,
        elevation: dark ? 16 : 8,
      ),
      brightness: brightness,
    );

    themeString ??= color.toHex();

    setTheme(themeData, themeString: themeString);
  }

  void setThemeString(String themeString) {
    Color? color = builtins[themeString];

    if (color != null) {
      setThemeColor(color, themeString: themeString);
      return;
    }

    color = Colors.transparent.fromString(themeString);

    if (color != Colors.transparent) {
      setThemeColor(color, themeString: themeString);
      return;
    }

    // Fallback to dark theme
    setThemeString("Dark");
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_back_gesture/back_gesture_config.dart';
import 'package:universal_back_gesture/back_gesture_page_transitions_builder.dart';

final pageConfig =  BackGesturePageTransitionsBuilder(
    parentTransitionBuilder: ZoomPageTransitionsBuilder(),
    // config: BackGestureConfig(animationProgressCompleteThreshold: 0.4),
  );

final ThemeData lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A73E8), // Deep blue, similar to Gmail
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A73E8),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[800],
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
  pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: pageConfig,
      },
    ),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A73E8), // Deep blue, similar to Gmail
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[700],
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
  pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: pageConfig,
      },
    ),
);
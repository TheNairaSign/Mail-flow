import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_back_gesture/back_gesture_page_transitions_builder.dart';

final pageConfig =  BackGesturePageTransitionsBuilder(
    parentTransitionBuilder: ZoomPageTransitionsBuilder(),
    // config: BackGestureConfig(animationProgressCompleteThreshold: 0.4),
  );

final ThemeData lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  colorScheme: ColorScheme.light(
    primary: Color(0xff5269FF),
    secondary: Color(0xff5269FF),
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A73E8),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  dividerColor: Colors.grey[300],
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
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  scaffoldBackgroundColor: Color(0xff09090B),
  colorScheme: ColorScheme.dark(
    primary: Color(0xff5269FF),
    secondary: Color(0xff5269FF),
    brightness: Brightness.dark,
    surface: Color(0xff151515)
  ),
  dividerColor: Colors.grey[700],
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff101010),
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
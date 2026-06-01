import '../../models/module.dart';

/// App-wide configuration: colors, text styles, constants, strings, global
/// state, environment switching, and local-storage keys.
final Module configModule = Module(
  key: 'config',
  title: 'App config (colors, text styles, env, globals)',
  description:
      'AppColors with a dynamic primary, GoogleFonts text styles, constants, strings, Globals + .env loading, dev/prod environment switch, and LocalDataKey enum.',
  packages: ['sizer', 'google_fonts', 'flutter_dotenv'],
  folders: ['lib/app/config'],
  files: {
    'lib/app/config/app_colors.dart': '''
import 'package:flutter/material.dart';

/// Central color palette. [primary] is swappable at runtime via
/// [updatePrimaryColor] / [resetPrimaryColor] so branding can be themed.
class AppColors {
  AppColors._();

  static const Color white = Colors.white;
  static const Color black = Color(0xFF020202);
  static const Color transparent = Colors.transparent;

  static const Color _defaultPrimary = Color(0xFF0A95CF);
  static Color _dynamicPrimary = _defaultPrimary;

  static Color get primary => _dynamicPrimary;

  static void updatePrimaryColor(Color? newColor) {
    if (newColor != null) {
      _dynamicPrimary = newColor;
    }
  }

  static void resetPrimaryColor() {
    _dynamicPrimary = _defaultPrimary;
  }

  static const Color secondary = Color(0xFF5B5A57);
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightTextColor = Color(0xFF717E8F);
  static const Color hint = Color(0xFF9CA3AF);

  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGrey = Color(0xFFEBECF0);
  static const Color cardColor = Color(0xFFF3F3F3);
  static const Color border = Color(0xFFD3D6DA);
  static const Color inputBorder = Color(0xFFE1E3EA);
  static const Color iconColor = Color(0xFFD0D0D0);

  static const Color success = Color(0xFF00A933);
  static const Color error = Color(0xFFEF2E33);
  static const Color red = Color(0xFFEF2E33);
  static const Color warning = Color(0xFFFBBC05);
  static const Color info = Color(0xFF0EA5E9);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4CD1E5), Color(0xFF0C99D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
''',
    'lib/app/config/app_text_styles.dart': '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';

/// Reusable text styles built on GoogleFonts + responsive sizing (sizer).
/// Swap [GoogleFonts.inter] for your brand font in one place.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textColor,
  );

  static TextStyle heading = GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle subHeading = GoogleFonts.inter(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textColor,
  );

  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle hint = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.hint,
  );

  static TextStyle small = GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextColor,
  );
}
''',
    'lib/app/config/app_constants.dart': '''
import 'package:flutter/material.dart';

/// App-wide constant values (spacing, durations, radii, etc.).
class AppConstants {
  AppConstants._();

  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);

  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(defaultPadding);
}
''',
    'lib/app/config/app_strings.dart': '''
/// Centralized user-facing strings. Move copy here so it is easy to localize.
class AppStrings {
  AppStrings._();

  static const String appName = 'App';
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
  static const String tryAgain = 'Try again';
}
''',
    'lib/app/config/global_vars.dart': '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mutable, app-lifetime global state. Prefer Riverpod providers for feature
/// state; keep this for cross-cutting values (auth token, device info, config).
class Globals {
  Globals._();

  static String authToken = '';
  static String fcmToken = '';
  static String userId = '';
  static String? email;
  static String fullName = '';
  static String? deviceId;
  static String? deviceName;
  static String? language;
  static String? appVersion;
  static String? buildNumber;

  static String baseUrl = '';
  static String dummyImage = '';

  /// Populate config values from the loaded `.env` file. Call after
  /// `dotenv.load(...)` in `main()`.
  static void initializeFromEnv() {
    baseUrl = dotenv.env['BASE_URL'] ?? '';
  }
}
''',
    'lib/app/config/app_environment.dart': '''
enum AppEnvironment { dev, prod }

/// Selects which `.env` file is loaded and exposes environment helpers.
class AppEnvironmentConfig {
  AppEnvironmentConfig._();

  static AppEnvironment _current = AppEnvironment.dev;

  static AppEnvironment get current => _current;

  static void setEnvironment(AppEnvironment env) {
    _current = env;
  }

  static String get envFileName =>
      _current == AppEnvironment.prod ? '.env.prod' : '.env.dev';

  static bool get isProduction => _current == AppEnvironment.prod;

  static bool get isDevelopment => _current == AppEnvironment.dev;

  static String get name =>
      _current == AppEnvironment.prod ? 'production' : 'development';
}
''',
    'lib/app/config/local_keys.dart': '''
/// Keys used for local (SharedPreferences / secure storage) persistence.
enum LocalDataKey {
  authToken,
  userId,
  fcmToken,
  email,
  fullName,
  firstTime,
  language,
  userData,
}
''',
  },
);

import '../../models/module.dart';

/// Cross-cutting helpers: asset paths, date/time formatting, toasts &
/// snackbars, URL launching, input validation, and keyboard handling.
final Module utilsModule = Module(
  key: 'utils',
  title: 'Utils (formatting, toasts, validators, keyboard)',
  description:
      'Utils (asset paths, formatDate, getTimeAgo, toast/snackbar, openUrl), Validators, date helpers, and keyboard helpers.',
  packages: ['intl', 'fluttertoast', 'url_launcher'],
  dependsOn: ['config'],
  folders: ['lib/app/utils'],
  files: {
    'lib/app/utils/utils.dart': r'''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_colors.dart';

class Utils {
  Utils._();

  // ----- Asset paths -----
  static String getImagePath(String name, {String format = 'png'}) =>
      'assets/images/$name.$format';

  static String getIconPath(String name, {String format = 'png'}) =>
      'assets/icons/$name.$format';

  static String getSvgPath(String name, {String format = 'svg'}) =>
      'assets/svg/$name.$format';

  // ----- Date / time -----
  static String formatDate(DateTime date, {String? format}) =>
      DateFormat(format ?? 'd MMM, yyyy').format(date);

  static String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';

    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final h = difference.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final d = difference.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final w = (difference.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final mo = (difference.inDays / 30).floor();
      return '$mo ${mo == 1 ? 'month' : 'months'} ago';
    } else {
      final y = (difference.inDays / 365).floor();
      return '$y ${y == 1 ? 'year' : 'years'} ago';
    }
  }

  // ----- Toasts -----
  static void showToast({required String message, int time = 2}) {
    Fluttertoast.showToast(
      msg: message,
      timeInSecForIosWeb: time,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void dismissToasts() {
    try {
      Fluttertoast.cancel();
    } catch (_) {}
  }

  // ----- Snackbars -----
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppColors.error;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = AppColors.success;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = AppColors.primary;
      icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
  }) =>
      showSnackBar(context: context, message: message, isError: true);

  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) =>
      showSnackBar(context: context, message: message, isSuccess: true);

  // ----- URLs -----
  static Future<void> openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      showErrorSnackBar(context: context, message: 'Link not available');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      showErrorSnackBar(context: context, message: 'Unable to open link');
      return;
    }
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      showErrorSnackBar(context: context, message: 'Unable to open link');
    }
  }

  // ----- System UI -----
  static void setStatusBarColorDark() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
}
''',
    'lib/app/utils/validators.dart': r'''
class Validators {
  Validators._();

  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email) &&
        !email.contains('..') &&
        !email.startsWith('.');
  }

  static bool hasUpperCase(String password) =>
      password.contains(RegExp(r'[A-Z]'));
  static bool hasLowerCase(String password) =>
      password.contains(RegExp(r'[a-z]'));
  static bool hasNumber(String password) =>
      password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String password) =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  static bool hasMinLength(String password) => password.length >= 8;

  /// Returns password strength in the range 0.0 - 1.0.
  static double calculatePasswordStrength(String password) {
    double strength = 0;
    if (hasMinLength(password)) strength += 0.2;
    if (hasUpperCase(password)) strength += 0.2;
    if (hasLowerCase(password)) strength += 0.2;
    if (hasNumber(password)) strength += 0.2;
    if (hasSpecialChar(password)) strength += 0.2;
    return strength;
  }

  static String getPasswordStrengthText(double strength) {
    if (strength < 0.2) return 'Very Weak';
    if (strength < 0.4) return 'Weak';
    if (strength < 0.6) return 'Medium';
    if (strength < 0.8) return 'Strong';
    return 'Very Strong';
  }

  static bool isValidPassword(String password) =>
      hasMinLength(password) &&
      hasUpperCase(password) &&
      hasLowerCase(password) &&
      hasNumber(password);
}
''',
    'lib/app/utils/date_utils.dart': r'''
// Lightweight, dependency-free date parsing/formatting helpers.

DateTime? parseDateFromString(String dateString) {
  try {
    final parts = dateString.split(' ');
    if (parts.length < 3) return null;

    final day = int.tryParse(parts[0]);
    final year = int.tryParse(parts[2]);
    if (day == null || year == null) return null;

    final monthIndex = getMonthIndexFromName(parts[1]);
    if (monthIndex == -1) return null;

    return DateTime(year, monthIndex, day);
  } catch (_) {
    return null;
  }
}

int getMonthIndexFromName(String monthName) {
  const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return monthNames.indexOf(monthName) + 1;
}

String getMonthNameFromIndex(int monthIndex) {
  const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return monthNames[monthIndex - 1];
}

String getDayNameFromWeekday(int weekday) {
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return dayNames[weekday - 1];
}

String formatDateForDisplay(DateTime date) {
  final dayName = getDayNameFromWeekday(date.weekday);
  final monthName = getMonthNameFromIndex(date.month);
  return '$dayName, ${date.day} $monthName ${date.year}';
}
''',
    'lib/app/utils/keyboard_utils.dart': '''
import 'package:flutter/material.dart';

/// Helpers for dismissing the keyboard and keeping focused fields visible.
class KeyboardUtils {
  KeyboardUtils._();

  /// Dismisses the keyboard by unfocusing the active node.
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Scrolls so the currently focused widget stays visible above the keyboard.
  static void ensureFocusedItemVisible(
    BuildContext context, {
    double alignment = 0.5,
  }) {
    Scrollable.ensureVisible(
      context,
      alignment: alignment,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
''',
  },
);

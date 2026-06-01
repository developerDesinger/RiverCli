import '../../models/module.dart';

/// Handy extension methods that keep widget code concise.
final Module extensionsModule = Module(
  key: 'extensions',
  title: 'Extensions (SizedBox, Color, DateTime helpers)',
  description:
      'num.height/.width SizedBox shorthands, Color.withOpacityValue, and DateTime.weekOfYear.',
  folders: ['lib/app/extensions'],
  files: {
    'lib/app/extensions/extensions.dart': '''
import 'package:flutter/material.dart';

/// `12.height` / `8.width` shorthands for spacing.
extension SizeBox on num {
  SizedBox get height => SizedBox(height: toDouble());
  SizedBox get width => SizedBox(width: toDouble());
}

/// Opacity helper that avoids the deprecated `withOpacity`.
extension ColorOpacityHelper on Color {
  Color withOpacityValue(double opacity) =>
      withAlpha((opacity * 255).round());
}

/// ISO-ish week-of-year for a [DateTime].
extension WeekOfYear on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay =
        difference(firstDayOfYear).inDays + firstDayOfYear.weekday;
    return (daysSinceFirstDay / 7).ceil();
  }
}
''',
  },
);

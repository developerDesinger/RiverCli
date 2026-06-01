import '../../models/module.dart';

/// A small kit of reusable, unopinionated UI building blocks.
final Module widgetsModule = Module(
  key: 'widgets',
  title: 'Shared widgets (text, button, fields, states)',
  description:
      'MyText, CustomButton, MyContainer, InputTextField, asset image, refresh indicator, error banner, empty state, and a loading spinner.',
  packages: ['google_fonts', 'sizer'],
  dependsOn: ['config', 'utils', 'extensions'],
  folders: ['lib/app/shared_widgets'],
  files: {
    'lib/app/shared_widgets/my_text.dart': r'''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A thin wrapper around [Text] using a single GoogleFonts family so typography
/// stays consistent. Swap [GoogleFonts.inter] for your brand font here.
class MyText extends StatelessWidget {
  final String? title;
  final double? size;
  final FontWeight? weight;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final FontStyle? fontStyle;

  const MyText({
    super.key,
    this.title,
    this.size,
    this.weight,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.letterSpacing,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? '',
      maxLines: maxLines,
      softWrap: true,
      overflow: overflow,
      textAlign: align,
      style: GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        decoration: decoration ?? TextDecoration.none,
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/my_container.dart': r'''
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// A tappable [Container] with sensible decoration defaults.
class MyContainer extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;

  const MyContainer({
    super.key,
    this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.alignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        alignment: alignment,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? AppColors.white) : null,
          border: border,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          boxShadow: boxShadow,
          gradient: gradient,
        ),
        child: child,
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/my_button.dart': r'''
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// A flexible, gradient-capable button with a built-in loading state.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final double? height;
  final double? width;
  final Color textColor;
  final Color? boxColor;
  final double? fontSize;
  final double? radius;
  final FontWeight? weight;
  final BoxBorder? boxBorder;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Widget? leadingIcon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPress,
    this.textColor = Colors.white,
    this.boxColor,
    this.height,
    this.width,
    this.fontSize,
    this.radius,
    this.weight,
    this.boxBorder,
    this.gradient,
    this.boxShadow,
    this.leadingIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPress == null || isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPress,
        borderRadius: BorderRadius.circular(radius ?? 16),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Container(
            width: width,
            height: height ?? 50,
            decoration: BoxDecoration(
              color: gradient == null ? (boxColor ?? AppColors.primary) : null,
              gradient: gradient,
              boxShadow: boxShadow,
              border: boxBorder,
              borderRadius: BorderRadius.circular(radius ?? 16),
            ),
            child: Center(
              child: isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: weight ?? FontWeight.w600,
                            fontSize: fontSize ?? 16,
                            color: textColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/input_text_field.dart': r'''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../config/app_colors.dart';
import '../extensions/extensions.dart';
import '../utils/utils.dart';

/// A styled [TextFormField] with optional asset prefix/suffix icons.
class InputTextField extends StatelessWidget {
  final String? initial;
  final String? hint;
  final FocusNode? focusNode;
  final String? prefixIcon;
  final String? suffixIcon;
  final Color? suffixColor;
  final Color? prefixColor;
  final VoidCallback? suffixOnTap;
  final bool isObscure;
  final bool readOnly;
  final int maxLines;
  final Color? fillColor;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final double? textSize;

  const InputTextField({
    super.key,
    this.initial,
    this.hint,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixColor,
    this.prefixColor,
    this.suffixOnTap,
    this.isObscure = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.fillColor,
    this.textInputType,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.inputFormatters,
    this.textSize,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(width: 1, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      initialValue: initial,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: readOnly,
      keyboardType: textInputType ?? TextInputType.text,
      validator: validator,
      onSaved: onSaved,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap: onTap,
      obscureText: isObscure,
      controller: controller,
      cursorColor: AppColors.textColor,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        color: AppColors.textColor,
        fontSize: textSize ?? 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: textSize ?? 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textColor.withOpacityValue(0.6),
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        border: _border(AppColors.inputBorder),
        enabledBorder: _border(AppColors.inputBorder),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Image.asset(
                  Utils.getIconPath(prefixIcon!),
                  width: 20,
                  height: 20,
                  color: prefixColor,
                ),
              ),
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: suffixOnTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    Utils.getIconPath(suffixIcon!),
                    width: 20,
                    height: 20,
                    color: suffixColor,
                  ),
                ),
              ),
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/custom_asset_image.dart': r'''
import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Loads an image from `assets/images/` by name.
class CustomAssetImage extends StatelessWidget {
  final String path;
  final double? scale;
  final double? width;
  final double? height;

  const CustomAssetImage({
    super.key,
    required this.path,
    this.scale,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Utils.getImagePath(path),
      scale: scale ?? 1,
      width: width,
      height: height,
    );
  }
}

/// Loads an icon from `assets/icons/` by name, with optional tint.
class CustomAssetIcon extends StatelessWidget {
  final String path;
  final double scale;
  final Color? color;

  const CustomAssetIcon({
    super.key,
    required this.path,
    this.scale = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Utils.getIconPath(path),
      scale: scale,
      color: color,
    );
  }
}
''',
    'lib/app/shared_widgets/app_refresh_indicator.dart': r'''
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// A [RefreshIndicator] pre-styled with the app primary color.
class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: backgroundColor ?? AppColors.white,
      strokeWidth: 2.0,
      child: child,
    );
  }
}
''',
    'lib/app/shared_widgets/app_error_banner.dart': r'''
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../config/app_colors.dart';
import '../extensions/extensions.dart';
import 'my_container.dart';
import 'my_text.dart';

/// An inline error banner. Named [AppErrorBanner] to avoid clashing with
/// Flutter built-in [ErrorWidget].
class AppErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const AppErrorBanner({super.key, required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      margin: EdgeInsets.only(bottom: 2.h),
      color: AppColors.error.withOpacityValue(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.error.withOpacityValue(0.3)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: MyText(
              title: message,
              size: 14.sp,
              color: AppColors.error,
              weight: FontWeight.w500,
            ),
          ),
          if (onClose != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, color: AppColors.error, size: 18.sp),
            ),
          ],
        ],
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/empty_state_widget.dart': r'''
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../config/app_colors.dart';
import 'my_text.dart';

/// A centered empty-state placeholder. Pass any [icon] widget (Icon, image, etc.).
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final Widget? icon;

  const EmptyStateWidget({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ??
              Icon(Icons.inbox_outlined,
                  size: 64, color: AppColors.iconColor),
          SizedBox(height: 3.h),
          MyText(
            title: message,
            size: 16.sp,
            weight: FontWeight.w500,
            color: AppColors.hint,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
''',
    'lib/app/shared_widgets/custom_loading_spinner.dart': r'''
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// A simple rotating circular spinner tinted with the app primary color.
class CustomLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CustomLoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  });

  @override
  State<CustomLoadingSpinner> createState() => _CustomLoadingSpinnerState();
}

class _CustomLoadingSpinnerState extends State<CustomLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RotationTransition(
          turns: _controller,
          child: CircularProgressIndicator(
            strokeWidth: widget.strokeWidth,
            valueColor:
                AlwaysStoppedAnimation<Color>(widget.color ?? AppColors.primary),
          ),
        ),
      ),
    );
  }
}
''',
  },
);

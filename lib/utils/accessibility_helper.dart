import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  static void announceMessage(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(
        View.of(context), message, TextDirection.ltr);
  }

  static void announceMessageWithDirection(
      BuildContext context, String message, TextDirection direction) {
    SemanticsService.sendAnnouncement(View.of(context), message, direction);
  }

  static void provideTapFeedback() {
    HapticFeedback.lightImpact();
  }

  static void provideSelectionFeedback() {
    HapticFeedback.selectionClick();
  }

  // Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation;
  }
}

class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final String? semanticsValue;
  final bool excludeSemantics;
  final bool isButton;
  final bool isTextField;
  final bool isImage;
  final VoidCallback? onTap;
  final bool enabled;
  final bool focused;
  final bool selected;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.semanticsValue,
    this.excludeSemantics = false,
    this.isButton = false,
    this.isTextField = false,
    this.isImage = false,
    this.onTap,
    this.enabled = true,
    this.focused = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      value: semanticsValue,
      button: isButton,
      textField: isTextField,
      image: isImage,
      enabled: enabled,
      focusable: enabled,
      focused: focused,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }
}

class RTLWrapper extends StatelessWidget {
  final Widget child;
  final bool forceDirection;
  final TextDirection? textDirection;

  const RTLWrapper({
    super.key,
    required this.child,
    this.forceDirection = false,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    if (textDirection != null || forceDirection) {
      return Directionality(
        textDirection: textDirection ?? _getDirectionFromLocale(context),
        child: child,
      );
    }
    return child;
  }

  TextDirection _getDirectionFromLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // RTL languages
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String? semanticsHint;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticsLabel,
    this.semanticsHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticsLabel: semanticsLabel,
      semanticsHint: semanticsHint,
      isButton: true,
      enabled: enabled,
      onTap: enabled
          ? () {
              AccessibilityHelper.provideTapFeedback();
              onPressed?.call();
            }
          : null,
      child: child,
    );
  }
}

class AccessibleTextField extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final String? semanticsValue;

  const AccessibleTextField({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.semanticsValue,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticsLabel: semanticsLabel,
      semanticsHint: semanticsHint,
      semanticsValue: semanticsValue,
      isTextField: true,
      child: child,
    );
  }
}

class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final bool decorative;

  const AccessibleImage({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.decorative = false,
  });

  @override
  Widget build(BuildContext context) {
    if (decorative) {
      return ExcludeSemantics(child: child);
    }

    return AccessibleWidget(
      semanticsLabel: semanticsLabel ?? 'Image',
      isImage: true,
      child: child,
    );
  }
}

class ScreenReaderText extends StatelessWidget {
  final String text;

  const ScreenReaderText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: const SizedBox.shrink(),
    );
  }
}

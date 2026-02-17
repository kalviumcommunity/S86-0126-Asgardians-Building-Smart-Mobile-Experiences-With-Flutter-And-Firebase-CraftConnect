import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage first-time tooltips and tutorials
class TutorialService {
  static const String _tutorialPrefix = 'tutorial_shown_';

  /// Check if a specific tutorial has been shown
  static Future<bool> hasSeen(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_tutorialPrefix$tutorialKey') ?? false;
  }

  /// Mark a tutorial as seen
  static Future<void> markAsSeen(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_tutorialPrefix$tutorialKey', true);
  }

  /// Reset all tutorials (for testing)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tutorialPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Show tooltip with automatic dismissal after first view
  static Future<void> showTooltip({
    required BuildContext context,
    required String tutorialKey,
    required String message,
    required GlobalKey targetKey,
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) async {
    final hasSeen = await TutorialService.hasSeen(tutorialKey);
    if (hasSeen) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => TutorialTooltipOverlay(
          title: title,
          message: message,
          targetPosition: position,
          targetSize: size,
          onDismiss: () {
            TutorialService.markAsSeen(tutorialKey);
          },
        ),
      );

      // Auto dismiss after duration
      Future.delayed(duration, () {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    });
  }
}

/// Tutorial Tooltip Overlay Widget
class TutorialTooltipOverlay extends StatelessWidget {
  final String? title;
  final String message;
  final Offset targetPosition;
  final Size targetSize;
  final VoidCallback onDismiss;

  const TutorialTooltipOverlay({
    super.key,
    this.title,
    required this.message,
    required this.targetPosition,
    required this.targetSize,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final showAbove = targetPosition.dy > screenSize.height / 2;

    return Stack(
      children: [
        // Dismissible barrier
        GestureDetector(
          onTap: () {
            onDismiss();
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),

        // Highlight circle around target
        Positioned(
          left: targetPosition.dx - 8,
          top: targetPosition.dy - 8,
          child: IgnorePointer(
            child: Container(
              width: targetSize.width + 16,
              height: targetSize.height + 16,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Tooltip card
        Positioned(
          left: 16,
          right: 16,
          top: showAbove ? null : targetPosition.dy + targetSize.height + 16,
          bottom: showAbove ? screenSize.height - targetPosition.dy + 16 : null,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            onDismiss();
                            Navigator.of(context).pop();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        onDismiss();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Got it!'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Arrow pointing to target
        Positioned(
          left: targetPosition.dx + targetSize.width / 2 - 10,
          top: showAbove ? null : targetPosition.dy + targetSize.height + 8,
          bottom: showAbove ? screenSize.height - targetPosition.dy + 8 : null,
          child: IgnorePointer(
            child: CustomPaint(
              size: const Size(20, 8),
              painter: ArrowPainter(pointingUp: showAbove),
            ),
          ),
        ),
      ],
    );
  }
}

/// Arrow painter for tooltip
class ArrowPainter extends CustomPainter {
  final bool pointingUp;

  ArrowPainter({required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

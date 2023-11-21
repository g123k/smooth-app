import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

/// A Widget to display on top of the screen that shows:
/// - A progression
/// - A title
/// - A (shifted) icon
class SmoothHeader extends StatelessWidget {
  const SmoothHeader({
    required this.currentStep,
    required this.maxSteps,
    required this.title,
    required this.icon,
    FractionalOffset? iconOffset,
    super.key,
  })  : assert(currentStep >= 0),
        assert(maxSteps >= 1),
        assert(currentStep <= maxSteps),
        iconOffset = iconOffset ?? FractionalOffset.center;

  final int currentStep;
  final int maxSteps;
  final String title;
  final PreferredSizeWidget icon;
  final FractionalOffset iconOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _computeHeight(MediaQuery.of(context)),
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.vertical(
          bottom: Radius.circular(30.0),
        ),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.secondary,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                _icon(),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: LARGE_SPACE,
                      end: LARGE_SPACE,
                      top: MEDIUM_SPACE,
                    ),
                    child: Column(
                      children: <Widget>[
                        _AnimatedHeaderProgress(
                          currentStep: currentStep,
                          maxSteps: maxSteps,
                        ),
                        const SizedBox(height: VERY_LARGE_SPACE),
                        AutoSizeText(
                          title,
                          maxLines: 2,
                          maxFontSize: 24.0,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The icon is a bit outside the bounds (will be cropped by the [ClipRRect])
  PositionedDirectional _icon() {
    final double iconSize = icon.preferredSize.longestSide;

    return PositionedDirectional(
      end: -(iconSize * iconOffset.dx),
      bottom: -(iconSize * iconOffset.dy),
      child: icon,
    );
  }

  /// Status bar + progress bar + text on 2 lines + paddings
  double _computeHeight(MediaQueryData mediaQuery) {
    return mediaQuery.viewPadding.top +
        MEDIUM_SPACE +
        _AnimatedHeaderProgress.HEIGHT +
        VERY_LARGE_SPACE +
        (mediaQuery.textScaleFactor * 24.0) * 2 +
        LARGE_SPACE;
  }
}

class _AnimatedHeaderProgress extends StatefulWidget {
  const _AnimatedHeaderProgress({
    required this.currentStep,
    required this.maxSteps,
  })  : assert(currentStep >= 0),
        assert(maxSteps >= 1),
        assert(currentStep <= maxSteps);

  static const double HEIGHT = 10.0;

  final int currentStep;
  final int maxSteps;

  @override
  State<_AnimatedHeaderProgress> createState() =>
      _AnimatedHeaderProgressState();
}

class _AnimatedHeaderProgressState extends State<_AnimatedHeaderProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimation();
    });
  }

  @override
  void didUpdateWidget(_AnimatedHeaderProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _updateAnimation({double? to}) {
    final double start = _animation?.value ?? 0.0;
    final double end = to ?? widget.currentStep.toDouble();

    _controller.reset();
    _animation = Tween<double>(begin: start, end: end)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ProgressPainter(
        backgroundColor: const Color(0xFFF6F3F0),
        progressColor: const Color(0xFF52443D),
        progress: _animation?.value ?? 0.0,
        steps: widget.maxSteps,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.steps,
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  })  : assert(steps >= 1),
        assert(progress >= 0.0 && progress <= steps);

  final int steps;
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final Paint _paint = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final double stepWidth = size.width / steps;

    // Background
    _paint.color = canvas.drawRRect(
        RRect.fromLTRBR(
          0,
          0,
          size.width,
          size.height,
          const Radius.circular(8.0),
        ),
        _paint);
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
    return progress != oldDelegate.progress || steps != oldDelegate.steps;
  }

  @override
  bool shouldRebuildSemantics(_ProgressPainter oldDelegate) => false;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class SmoothFloatingMessage {
  SmoothFloatingMessage({
    required this.message,
  });

  final String message;

  OverlayEntry? _entry;

  /// Show the message during [duration].
  /// You can call [hide] if you want to dismiss it before
  void show(
    BuildContext context, {
    AlignmentGeometry? alignment,
    Duration? duration,
  }) {
    _entry?.remove();

    final double appBarHeight = Scaffold.maybeOf(context)?.hasAppBar == true
        ? (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight)
        : MediaQuery.paddingOf(context).top;

    _entry = OverlayEntry(builder: (BuildContext context) {
      return _SmoothFloatingMessageView(
        message: message,
        alignment: alignment,
        duration: duration ?? SnackBarDuration.long,
        onViewGone: () {
          _entry?.remove();
        },
        margin: EdgeInsetsDirectional.only(
          top: appBarHeight,
          start: BALANCED_SPACE,
          end: BALANCED_SPACE,
          bottom: SMALL_SPACE,
        ),
      );
    });

    Overlay.of(context).insert(_entry!);
  }
}

class _SmoothFloatingMessageView extends StatefulWidget {
  const _SmoothFloatingMessageView({
    required this.message,
    required this.onViewGone,
    required this.duration,
    this.alignment,
    this.margin,
  });

  final String message;
  final VoidCallback onViewGone;
  final Duration duration;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  @override
  State<_SmoothFloatingMessageView> createState() =>
      _SmoothFloatingMessageViewState();
}

class _SmoothFloatingMessageViewState extends State<_SmoothFloatingMessageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: SmoothAnimationsDuration.brief,
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            if (_animationController.value == 1.0) {
              /// Start the timer
              _timer = Timer(widget.duration, () {
                _animationController.reverse();
                _timer = null;
              });
            } else if (_animationController.value == 0.0) {
              widget.onViewGone();
            }
          }
        },
      );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final SnackBarThemeData snackBarTheme = Theme.of(context).snackBarTheme;

    return AnimatedOpacity(
      opacity: _fadeAnimation.value,
      duration: SmoothAnimationsDuration.short,
      child: SafeArea(
        top: false,
        child: Container(
          margin: widget.margin,
          alignment: widget.alignment ?? AlignmentDirectional.topCenter,
          child: Card(
            elevation: 4.0,
            color: snackBarTheme.backgroundColor,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: snackBarTheme.contentTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _timer?.cancel();
  }
}

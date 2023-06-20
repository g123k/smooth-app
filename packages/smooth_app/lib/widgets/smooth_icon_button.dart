import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// A variant of an [IconButton] allowing to easily inject a [semanticLabel]
class SmoothIconButton extends StatelessWidget {
  const SmoothIconButton({
    required this.icon,
    this.semanticLabel,
    this.customBorder,
    this.onPressed,
  });

  final Icon icon;
  final String? semanticLabel;
  final ShapeBorder? customBorder;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        customBorder: customBorder ?? const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(
            width: kMinInteractiveDimension,
            height: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: icon,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsumerWithCondition<S> extends StatelessWidget {
  const ConsumerWithCondition({
    required this.builder,
    required this.condition,
    super.key,
  });

  final ValueWidgetBuilder<S> builder;
  final ShouldRebuild<S> condition;

  @override
  Widget build(BuildContext context) {
    return Selector<S, S>(
      selector: (_, S value) => value,
      shouldRebuild: condition,
      builder: builder,
    );
  }
}

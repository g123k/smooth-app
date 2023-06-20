import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_questions_utils.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_icon_button.dart';

class SimpleInputSuggestions extends StatefulWidget {
  const SimpleInputSuggestions({
    required this.helper,
  });

  final AbstractSimpleInputPageHelper helper;

  @override
  State<SimpleInputSuggestions> createState() => _SimpleInputSuggestionsState();
}

class _SimpleInputSuggestionsState extends State<SimpleInputSuggestions>
    with AutomaticKeepAliveClientMixin {
  late StreamSubscription<ProductQuestionsState> _loadingSubscription;
  ProductQuestionsState _questionsState = const ProductQuestionsLoadingState();

  @override
  void initState() {
    super.initState();
    _loadingSubscription = ProductQuestionsHelper.loadQuestionsFor(
      context.read<LocalDatabase>(),
      widget.helper.product.barcode!,
      count: 5,
      type: widget.helper.getInsightType()!,
    ).listen(
      (ProductQuestionsState state) => setState(() => _questionsState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mandatory with a [AutomaticKeepAliveClientMixin]
    super.build(context);

    return switch (_questionsState) {
      ProductQuestionsLoadingState _ => const _ProductQuestionsLoading(),
      ProductQuestionsWithQuestionsState(
        questions: final List<RobotoffQuestion> list
      ) =>
        _ProductsQuestionsList(questions: list),
      _ => EMPTY_WIDGET
    };
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _loadingSubscription.cancel();
    super.dispose();
  }
}

class _ProductQuestionsTitle extends StatelessWidget {
  const _ProductQuestionsTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Suggestions:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProductQuestionsLoading extends StatelessWidget {
  const _ProductQuestionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        _ProductQuestionsTitle(),
        ListTile(
          leading: _ProductQuestionSuggestedIndicator(),
          title: Text('Chargement des suggestions'),
        ),
      ],
    );
  }
}

class _ProductsQuestionsList extends StatelessWidget {
  const _ProductsQuestionsList({required this.questions});

  final List<RobotoffQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: questions
          .map(
            (RobotoffQuestion item) => _ProductQuestionsItem(question: item),
          )
          .toList(growable: false),
    );
  }
}

class _ProductQuestionsItem extends StatelessWidget {
  const _ProductQuestionsItem({
    required this.question,
  });

  final RobotoffQuestion question;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    return ListTile(
      title: Text(question.value!),
      leading: SvgPicture.asset(
        'assets/icons/robotoff_suggestion.svg',
        width: iconTheme.size,
        height: iconTheme.size,
        colorFilter: iconTheme.color != null
            ? ColorFilter.mode(
                iconTheme.color!,
                ui.BlendMode.srcIn,
              )
            : null,
      ),
      trailing: Row(
        children: <Widget>[
          SmoothIconButton(
            icon: const Icon(Icons.check),
            semanticLabel: 'Accepter la suggestion',
            onPressed: () {},
          ),
          SmoothIconButton(
            icon: const Icon(Icons.close),
            semanticLabel: 'Refuser la suggestion',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ProductQuestionSuggestedIndicator extends StatelessWidget {
  const _ProductQuestionSuggestedIndicator();

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    return SvgPicture.asset(
      'assets/icons/robotoff_suggestion.svg',
      width: iconTheme.size,
      height: iconTheme.size,
      colorFilter: iconTheme.color != null
          ? ColorFilter.mode(
              iconTheme.color!,
              ui.BlendMode.srcIn,
            )
          : null,
    );
  }
}

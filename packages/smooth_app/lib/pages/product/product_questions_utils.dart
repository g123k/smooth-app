// Widget State
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/query/product_questions_query.dart';

class ProductQuestionsHelper {
  const ProductQuestionsHelper._();

  static Stream<ProductQuestionsState> loadQuestionsFor(
    LocalDatabase localDatabase,
    String barcode, {
    int count = 3,
    InsightType? type,
  }) async* {
    assert(barcode.isNotEmpty);
    yield const ProductQuestionsLoadingState();

    final (List<RobotoffQuestion>? list, bool annotationVoted) =
        await _loadProductQuestions(
      localDatabase,
      barcode,
      count: count,
      type: type,
    );

    if (list?.isNotEmpty == true && !annotationVoted) {
      yield ProductQuestionsWithQuestionsState(list!);
    } else {
      yield const ProductQuestionsWithoutQuestionsState();
    }
  }

  static Future<(List<RobotoffQuestion>?, bool)> _loadProductQuestions(
    LocalDatabase localDatabase,
    String barcode, {
    int count = 3,
    InsightType? type,
  }) async {
    final List<RobotoffQuestion> questions =
        await ProductQuestionsQuery(barcode).getQuestions(localDatabase, count);

    if (type != null) {
      questions.retainWhere(
        (RobotoffQuestion element) => element.insightType == type,
      );
    }

    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(localDatabase);
    final bool annotationVoted =
        await robotoffInsightHelper.areQuestionsAlreadyVoted(questions);

    return (questions, annotationVoted);
  }

  static Future<bool> updateProductUponAnswers(
    LocalDatabase localDatabase,
    String barcode,
  ) async {
    // Reload the product questions, they might have been answered.
    // Or the backend may have new ones.
    final List<RobotoffQuestion> questions = (await _loadProductQuestions(
          localDatabase,
          barcode,
        ))
            .$1 ??
        <RobotoffQuestion>[];

    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(localDatabase);

    if (questions.isEmpty) {
      await robotoffInsightHelper
          .removeInsightAnnotationsSavedForProduct(barcode);
    }

    return robotoffInsightHelper.areQuestionsAlreadyVoted(questions);
  }
}

sealed class ProductQuestionsState {
  const ProductQuestionsState();
}

class ProductQuestionsLoadingState extends ProductQuestionsState {
  const ProductQuestionsLoadingState();
}

class ProductQuestionsWithQuestionsState extends ProductQuestionsState {
  const ProductQuestionsWithQuestionsState(this.questions);

  final List<RobotoffQuestion> questions;
}

class ProductQuestionsWithoutQuestionsState extends ProductQuestionsState {
  const ProductQuestionsWithoutQuestionsState();
}

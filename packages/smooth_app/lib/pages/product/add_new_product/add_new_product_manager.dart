import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

class AddNewProductManager {

  final ProductFieldEditor _packagingEditor = ProductFieldPackagingEditor();
  final ProductFieldEditor _ingredientsEditor =
  ProductFieldOcrIngredientEditor();
  final ProductFieldEditor _originEditor =
  ProductFieldSimpleEditor(SimpleInputPageOriginHelper());
  final ProductFieldEditor _categoryEditor =
  ProductFieldSimpleEditor(SimpleInputPageCategoryHelper());
  final ProductFieldEditor _labelEditor =
  ProductFieldSimpleEditor(SimpleInputPageLabelHelper());
  final ProductFieldEditor _detailsEditor = ProductFieldDetailsEditor();
  final ProductFieldEditor _nutritionEditor = ProductFieldNutritionEditor();

  void trackEvent() {

  }
}
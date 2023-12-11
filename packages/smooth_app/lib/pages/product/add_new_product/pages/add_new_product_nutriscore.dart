import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_ui_shared.dart';

class AddNewProductNutriScorePage extends StatelessWidget {
  const AddNewProductNutriScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NUTRISCORE);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_nutriscore),
      const SizedBox(height: 15.0),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nutriscore),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      AddNewProductButton(
        AppLocalizations
            .of(context)
            .nutritional_facts_input_button_label,
        Icons.filter_2,
        // deactivated when the categories were not set beforehand
        !_categoryEditor.isPopulated(upToDateProduct)
            ? null
            : () async =>
            NutritionPageLoaded.showNutritionPage(
              product: upToDateProduct,
              isLoggedInMandatory: widget.isLoggedInMandatory,
              context: context,
            ),
        done: _nutritionEditor.isPopulated(upToDateProduct),
      ),
      _buildIngredientsButton(
        context,
        forceIconData: Icons.filter_3,
        disabled: (!_categoryEditor.isPopulated(upToDateProduct)) ||
            (!_nutritionEditor.isPopulated(upToDateProduct)),
      ),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgNutriscore,
        ),
      ),
    ];
  }
}


class AddNewProductNutriScoreManager extends AddNewProductPageManager {
  AddNewProductNutriScoreManager();

}
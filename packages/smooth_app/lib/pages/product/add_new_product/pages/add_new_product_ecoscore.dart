import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_ui_shared.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';

class AddNewProductEcoScorePage extends StatelessWidget {
  const AddNewProductEcoScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_ECOSCORE);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_ecoscore),
      const SizedBox(height: 15.0),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_ecoscore),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgEcoscore,
        ),
      ),
      const SizedBox(height: 15.0),
      GestureDetector(
        onTap: () {
          setState(() => _ecoscoreExpanded = !_ecoscoreExpanded);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
            color: _colorScheme.surface,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.filter_2,
                color: _colorScheme.onPrimary,
              ),
              const SizedBox(width: 15.0),
              Flexible(
                child: Text(
                  appLocalizations.new_product_additional_ecoscore,
                  style: TextStyle(
                    color: _colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 5.0),
              Icon(
                _ecoscoreExpanded ? Icons.expand_less : Icons.expand_more,
                color: _colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _originEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _labelEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _packagingEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded) _buildIngredientsButton(context),
    ];
  }
}


class AddNewProductEcoScoreManager extends AddNewProductPageManager {
  AddNewProductEcoScoreManager();

}
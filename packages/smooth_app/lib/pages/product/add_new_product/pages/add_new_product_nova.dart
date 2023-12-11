import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';

class AddNewProductNovaPage extends StatelessWidget {
  const AddNewProductNovaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NOVA);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_nova),
      const SizedBox(height: 15.0),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nova),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      _buildIngredientsButton(
        context,
        forceIconData: Icons.filter_2,
        disabled: !_categoryEditor.isPopulated(upToDateProduct),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AddNewProductScoreIcon(
            iconUrl: attribute?.iconUrl,
            defaultIconUrl: ProductDialogHelper.unknownSvgNova,
          ),
          Expanded(
            child: AddNewProductTitle(
              attribute?.descriptionShort ??
                  appLocalizations.new_product_desc_nova_unknown,
              maxLines: 5,
            ),
          )
        ],
      ),
    ];
  }
}


class AddNewProductNovaManager extends AddNewProductPageManager {
  AddNewProductNovaManager();

}
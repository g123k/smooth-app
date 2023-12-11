import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_ui_shared.dart';

class AddNewProductMiscDataPage extends StatelessWidget {
  const AddNewProductMiscDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AddNewProductTitle(
        AppLocalizations
            .of(context)
            .new_product_title_misc,
      ),
      AddNewProductEditorButton(
        _detailsEditor,
      ),
    ],);
  }
}


class AddNewProductMiscDataManager extends AddNewProductPageManager {
  AddNewProductMiscDataManager();

}
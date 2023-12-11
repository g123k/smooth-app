import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_ui_shared.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/query/product_query.dart';

class AddNewProductPhotos extends StatelessWidget {
  const AddNewProductPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<Product>(builder: (
      final BuildContext context,
      final Product upToDateProduct,
      _,
    ) {
      final List<ProductImageData> productImagesData = getProductMainImagesData(
        upToDateProduct,
        ProductQuery.getLanguage(),
      );

      return Column(children: <Widget>[
        AddNewProductTitle(appLocalizations.new_product_title_pictures),
        const SizedBox(height: 15.0),
        AddNewProductSubTitle(
            appLocalizations.new_product_title_pictures_details),

        // Main 4 images first.
        for (final ProductImageData data in productImagesData)
          _buildMainImageButton(context, data),
        _buildOtherImageButton(context, done: false),
        for (int i = 0; i < _otherCount; i++)
          _buildOtherImageButton(context, done: true)
      ]);
    });
  }

  /// Button specific to OTHER images.
  Widget _buildOtherImageButton(
    final BuildContext context, {
    required final bool done,
  }) =>
      AddNewProductButton(
        ImageField.OTHER.getAddPhotoButtonText(AppLocalizations.of(context)),
        done
            ? AddNewProductButton.doneIconData
            : AddNewProductButton.cameraIconData,
        () async {
          final File? finalPhoto = await confirmAndUploadNewPicture(
            context,
            barcode: barcode,
            imageField: ImageField.OTHER,
            language: ProductQuery.getLanguage(),
            isLoggedInMandatory: widget.isLoggedInMandatory,
          );
          if (finalPhoto != null) {
            setState(() => ++_otherCount);
          }
        },
        done: done,
        showTrailing: false,
      );

  /// Button specific to one of the main 4 images.
  Widget _buildMainImageButton(
    final BuildContext context,
    final ProductImageData productImageData,
  ) {
    final bool done = _helper.isMainImagePopulated(productImageData, barcode);
    return AddNewProductButton(
      productImageData.imageField
          .getAddPhotoButtonText(AppLocalizations.of(context)),
      done
          ? AddNewProductButton.doneIconData
          : AddNewProductButton.cameraIconData,
      () async => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView.imageField(
            imageField: productImageData.imageField,
            product: upToDateProduct,
            isLoggedInMandatory: widget.isLoggedInMandatory,
          ),
        ),
      ),
      done: done,
      showTrailing: false,
    );
  }

}

class _IngredientsButton extends StatelessWidget {
  const _IngredientsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AddNewProductEditorButton(
      _ingredientsEditor,
      forceIconData: forceIconData,
      disabled: disabled,
    );
  }
}


class AddNewProductPhotosManager extends AddNewProductPageManager {
  AddNewProductPhotosManager();
}

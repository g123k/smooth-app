import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/query/product_query.dart';

/// Tracks (only the first time) when a [check] is true.
class AnalyticsProductTracker {
  AnalyticsProductTracker({
    required this.analyticsEvent,
    required this.barcode,
    required this.check,
  });

  final AnalyticsEvent analyticsEvent;
  final String barcode;
  final bool Function() check;

  bool _already = false;

  void track() {
    if (_already) {
      return;
    }
    if (!check()) {
      return;
    }
    _already = true;
    AnalyticsHelper.trackEvent(analyticsEvent, barcode: barcode);
  }
}



/// Helper for the "Add new product" page.
class AddNewProductHelper {
  bool isMainImagePopulated(
    final ProductImageData productImageData,
    final String barcode,
  ) =>
      TransientFile.fromProductImageData(
        productImageData,
        barcode,
        ProductQuery.getLanguage(),
      ).getImageProvider() !=
      null;

  bool isOneMainImagePopulated(final Product product) {
    final List<ProductImageData> productImagesData = getProductMainImagesData(
      product,
      // TODO(monsieurtanuki): check somehow with all languages
      ProductQuery.getLanguage(),
    );
    for (final ProductImageData productImageData in productImagesData) {
      if (isMainImagePopulated(productImageData, product.barcode!)) {
        return true;
      }
    }
    return false;
  }
}

/// Possible actions on that page.
enum EditProductAction {
  openPage,
  leaveEmpty,
  ingredients,
  category,
  nutritionFacts;
}

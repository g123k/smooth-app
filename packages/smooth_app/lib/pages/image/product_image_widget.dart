import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Displays a product image thumbnail with the upload date on top.
class ProductImageWidget extends StatelessWidget {
  const ProductImageWidget({
    required this.productImage,
    required this.barcode,
    required this.squareSize,
  });

  final ProductImage productImage;
  final String barcode;
  final double squareSize;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLanguage().offTag);

    final Widget image = SmoothImage(
      width: squareSize,
      height: squareSize,
      imageProvider: NetworkImage(
        productImage.getUrl(
          barcode,
          uriHelper: ProductQuery.uriProductHelper,
        ),
      ),
      rounded: false,
    );
    final DateTime? uploaded = productImage.uploaded;
    if (uploaded == null) {
      return image;
    }
    final bool expired = DateTime.now().difference(uploaded).inDays > 365;
    final String date = dateFormat.format(uploaded);

    return Semantics(
      label: expired
          ? appLocalizations.product_image_outdated_accessibility_label(date)
          : appLocalizations.product_image_accessibility_label(date),
      excludeSemantics: true,
      button: true,
      child: Column(
        children: <Widget>[
          Expanded(
            child: image,
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
                vertical: VERY_SMALL_SPACE,
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: AutoSizeText(
                      date,
                      maxLines: 1,
                    ),
                  ),
                  if (expired)
                    Positioned.directional(
                      end: 0.0,
                      height: 20.0,
                      textDirection: Directionality.of(context),
                      child: Outdated(
                        size: 18.0,
                        color: Theme.of(context)
                            .extension<SmoothColorsThemeExtension>()!
                            .red,
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

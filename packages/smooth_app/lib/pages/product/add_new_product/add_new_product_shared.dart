import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';

enum AddNewProductContent {
  PHOTOS,
  NUTRITION,
  NOVA,
  NUTRISCORE,
  ECOSCORE,
  MISC,
}

abstract class AddNewProductPageManager extends ChangeNotifier {
  /*AddNewProductPageManager(this.analyticsEvent);

  final AnalyticsEvent analyticsEvent;

  bool _trackEventSent = false;

  @protected
  void trackEvent() {
    if (!_trackEventSent) {
      return;
    } else if (shouldSendTrackEvent()) {
      AnalyticsHelper.trackEvent(
        analyticsEvent,
        barcode: barcode,
      );
      _trackEventSent = true;
    }
  }

  bool shouldSendTrackEvent();*/
}

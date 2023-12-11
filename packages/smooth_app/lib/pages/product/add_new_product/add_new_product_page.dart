import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_page_args.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_pages.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/pages/add_new_product_ui_shared.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_helper.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_manager.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_header.dart';
import 'package:smooth_app/widgets/smooth_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// A page dedicated to create a product when it doesn't exist in the database.
/// Also called "Fast track".
class AddNewProductPage extends StatefulWidget {
  AddNewProductPage.fromBarcode(final String barcode)
      : assert(barcode.isNotEmpty),
        product = Product(barcode: barcode),
        events = const <EditProductAction, AnalyticsEvent>{
          EditProductAction.openPage: AnalyticsEvent.openNewProductPage,
          EditProductAction.leaveEmpty: AnalyticsEvent.closeEmptyNewProductPage,
          EditProductAction.ingredients:
              AnalyticsEvent.ingredientsNewProductPage,
          EditProductAction.category: AnalyticsEvent.categoriesNewProductPage,
          EditProductAction.nutritionFacts:
              AnalyticsEvent.nutritionNewProductPage,
        },
        displayPictures = true,
        displayMisc = true,
        isLoggedInMandatory = false;

  const AddNewProductPage.fromProduct(
    this.product, {
    required this.isLoggedInMandatory,
  })  : events = const <EditProductAction, AnalyticsEvent>{
          EditProductAction.openPage:
              AnalyticsEvent.openFastTrackProductEditPage,
          EditProductAction.leaveEmpty:
              AnalyticsEvent.closeEmptyFastTrackProductPage,
          EditProductAction.ingredients:
              AnalyticsEvent.ingredientsFastTrackProductPage,
          EditProductAction.category:
              AnalyticsEvent.categoriesFastTrackProductPage,
          EditProductAction.nutritionFacts:
              AnalyticsEvent.nutritionFastTrackProductPage,
        },
        displayPictures = false,
        displayMisc = false;

  final Product product;
  final bool displayPictures;
  final bool displayMisc;
  final bool isLoggedInMandatory;
  final Map<EditProductAction, AnalyticsEvent> events;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage>
    with TraceableClientMixin, UpToDateMixin {
  List<AddNewProductContent> _pages = <AddNewProductContent>[];

  /// Count of "other" pictures uploaded.
  int _otherCount = 0;

  final AddNewProductManager _addNewProductManager = AddNewProductManager();

  late DaoProductList _daoProductList;

  final ProductList _history = ProductList.history();


  late final List<ProductFieldEditor> _editors;
  late final List<AnalyticsProductTracker> _trackers;
  final AddNewProductHelper _helper = AddNewProductHelper();
  final PageController _pageController = PageController();

  bool _alreadyPushedToHistory = false;

  bool _ecoscoreExpanded = false;

  @override
  String get actionName => 'Opened add_new_product_page';

  @override
  void initState() {
    super.initState();
    _recomputePages();

    // Init the product here, to pass it to all sub-Wigets.
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    initUpToDate(widget.product, localDatabase);


    _trackers = <AnalyticsProductTracker>[
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.category]!,
        barcode: barcode,
        check: () => _categoryEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.ingredients]!,
        barcode: barcode,
        check: () => _ingredientsEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.nutritionFacts]!,
        barcode: barcode,
        check: () => _nutritionEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: AnalyticsEvent.imagesNewProductPage,
        barcode: barcode,
        check: () =>
            _otherCount > 0 || _helper.isOneMainImagePopulated(upToDateProduct),
      ),
    ];
    _daoProductList = DaoProductList(localDatabase);
    AnalyticsHelper.trackEvent(
      widget.events[EditProductAction.openPage]!,
      barcode: barcode,
    );
  }

  @override
  void didUpdateWidget(AddNewProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.displayPictures != widget.displayPictures ||
        oldWidget.displayMisc != widget.displayMisc) {
      _recomputePages();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    refreshUpToDate();

    _addToHistory();
    for (final AnalyticsProductTracker tracker in _trackers) {
      tracker.track();
    }

    return Provider<Product>.value(
      value: upToDateProduct,
      child: AddNewProductPageArgs(
        displayPictures: widget.displayPictures,
        displayMisc: widget.displayMisc,
        isLoggedInMandatory: widget.isLoggedInMandatory,
        child: MultiProvider(
          providers: <ChangeNotifierProvider<AddNewProductPageManager>>[
            ChangeNotifierProvider<AddNewProductPhotosManager>(
              create: (_) => AddNewProductPhotosManager(),
            ),
            ChangeNotifierProvider<AddNewProductNutriScoreManager>(
              create: (_) => AddNewProductNutriScoreManager(),
            ),
            ChangeNotifierProvider<AddNewProductEcoScoreManager>(
              create: (_) => AddNewProductEcoScoreManager(),
            ),
            ChangeNotifierProvider<AddNewProductNovaManager>(
              create: (_) => AddNewProductNovaManager(),
            ),
            ChangeNotifierProvider<AddNewProductMiscDataManager>(
              create: (_) => AddNewProductMiscDataManager(),
            ),
          ],
          child: Provider<List<AddNewProductContent>>.value(
            value: _pages,
            child: WillPopScope(
              onWillPop: _onWillPop,
              child: SmoothScaffold(
                // SafeArea is managed by [SmoothHeader]
                body: SafeArea(
                  top: false,
                  child: MultiProvider(
                    providers: <ChangeNotifierProvider<dynamic>>[
                      ChangeNotifierProvider<PageController>(
                        create: (_) => _pageController,
                      )
                    ],
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _AddNewProductHeader(),
                        _AddNewProductBody(),
                        _AddNewProductFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (_isPopulated) {
      return true;
    }
    final bool? leaveThePage = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.new_product,
        actionsAxis: Axis.vertical,
        body: Padding(
          padding: const EdgeInsets.all(MEDIUM_SPACE),
          child: Text(appLocalizations.new_product_leave_message),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.yes,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
    );
    if (leaveThePage == true) {
      AnalyticsHelper.trackEvent(
        widget.events[EditProductAction.leaveEmpty]!,
        barcode: barcode,
      );
    }
    return leaveThePage ?? false;
  }

  void _recomputePages() {
    _pages = <AddNewProductContent>[
      if (widget.displayPictures) AddNewProductContent.PHOTOS,
      AddNewProductContent.NUTRISCORE,
      AddNewProductContent.ECOSCORE,
      AddNewProductContent.NOVA,
      if (widget.displayMisc) AddNewProductContent.MISC,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Adds the product to history if at least one of the fields is set.
  Future<void> _addToHistory() async {
    if (_alreadyPushedToHistory) {
      return;
    }
    if (_isPopulated) {
      // TODO(g123k): That part is so dangerous. Please move to an immutable implementation
      upToDateProduct.productName = upToDateProduct.productName?.trim();
      upToDateProduct.brands = upToDateProduct.brands?.trim();
      await _daoProductList.push(_history, barcode);
      _alreadyPushedToHistory = true;
    }
  }

  /// Returns true if at least one field is populated.
  bool get _isPopulated {
    for (final ProductFieldEditor editor in _editors) {
      if (editor.isPopulated(upToDateProduct)) {
        return true;
      }
    }
    if (widget.displayPictures) {
      return _helper.isOneMainImagePopulated(upToDateProduct) ||
          _otherCount > 0;
    }
    return false;
  }

  Widget _buildCard(
    final List<Widget> children,
  ) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(LARGE_SPACE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );

  Attribute? _getAttribute(final String tag) =>
      upToDateProduct.getAttributes(<String>[tag])[tag];
}

class _AddNewProductHeader extends StatelessWidget {
  const _AddNewProductHeader();

  @override
  Widget build(BuildContext context) {
    final List<AddNewProductContent> pages =
        context.watch<List<AddNewProductContent>>();

    return ConsumerWithCondition<PageController>(
      condition: (PageController oldPC, PageController newPC) {
        return oldPC.page!.round() != newPC.page!.round();
      },
      builder: (BuildContext context, PageController controller, _) {
        return SmoothHeader(
          title: 'Prenons quelques photos',
          currentStep: controller.page?.round() ?? 0,
          maxSteps: pages.length,
          icon: PreferredSize(
            preferredSize: const Size(92.0, 114.0),
            child: SvgPicture.asset(
              'assets/misc/dark-orange.svg',
              width: 92.0,
              height: 114.0,
            ),
          ),
          iconOffset: const FractionalOffset(0.3, 0.4),
        );
      },
    );
  }
}

class _AddNewProductBody extends StatelessWidget {
  const _AddNewProductBody();

  @override
  Widget build(BuildContext context) {
    final List<AddNewProductContent> pages =
        context.watch<List<AddNewProductContent>>();

    return Expanded(
      child: PageView.builder(
        itemCount: pages.length,
        controller: context.read<PageController>(),
        itemBuilder: (final BuildContext context, final int index) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(LARGE_SPACE),
              child: switch (pages[index]) {
                AddNewProductContent.PHOTOS => const AddNewProductPhotos(),
                AddNewProductContent.NUTRITION =>
                  const AddNewProductNutriScorePage(),
                AddNewProductContent.NOVA => const AddNewProductNovaPage(),
                AddNewProductContent.NUTRISCORE =>
                  const AddNewProductNutriScorePage(),
                AddNewProductContent.ECOSCORE =>
                  const AddNewProductEcoScorePage(),
                AddNewProductContent.MISC => const AddNewProductMiscDataPage(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddNewProductFooter extends StatelessWidget {
  const _AddNewProductFooter();

  @override
  Widget build(BuildContext context) {
    final List<AddNewProductContent> pages =
        context.watch<List<AddNewProductContent>>();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 15.0,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(MediaQuery.sizeOf(context).width * 0.35, 40.0),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: const RoundedRectangleBorder(
                  borderRadius: ROUNDED_BORDER_RADIUS,
                ),
              ),
              onPressed: () {
                // On [willPop] will be called on [AddNewProductPage].
                Navigator.maybePop(context);
              },
              child: Text(
                AppLocalizations.of(context).cancel,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(MediaQuery.sizeOf(context).width * 0.35, 40.0),
                backgroundColor: DARK_BROWN_COLOR,
                shape: const RoundedRectangleBorder(
                  borderRadius: ROUNDED_BORDER_RADIUS,
                ),
              ),
              onPressed: () {
                context.read<PageController>().nextPage(
                      duration: SmoothAnimationsDuration.short,
                      curve: Curves.easeOut,
                    );
              },
              child: ConsumerWithCondition<PageController>(
                condition: (PageController oldPC, PageController newPC) {
                  final int oldPage = oldPC.page!.round();
                  final int newPage = newPC.page!.round();

                  return oldPage != newPage && oldPage == pages.length - 1 ||
                      newPage == pages.length - 1;
                },
                builder: (BuildContext context, PageController controller, _) {
                  return Text(
                    controller.page!.round() == pages.length - 1
                        ? AppLocalizations.of(context).finish
                        : AppLocalizations.of(context).next_label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

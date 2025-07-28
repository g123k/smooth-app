import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

/// Full page display of a proof.
class PriceProofPage extends StatefulWidget {
  const PriceProofPage(this.proof);

  final Proof proof;

  @override
  State<PriceProofPage> createState() => _PriceProofPageState();
}

class _PriceProofPageState extends State<PriceProofPage> {
  List<Price>? _existingPrices;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingPrices());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat = DateFormat.yMd(
      ProductQuery.getLocaleString(),
    ).add_Hms();

    print(widget.proof.toJson());

    return SmoothScaffold2(
      topBar: SmoothTopBar2(
        title: appLocalizations.user_search_proof_title,
        leadingAction: SmoothLeadingAction.back,
        size: SmoothTopBar2Size.small,
        elevationOnScroll: false,
      ),
      /*floatingBottomBar: _existingPrices == null
          ? null
          : FloatingActionButton.extended(
              label: Text(appLocalizations.prices_add_a_price),
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (!await ProductRefresher().checkIfLoggedIn(
                  context,
                  isLoggedInMandatory: true,
                )) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ProductPriceAddPage(
                      PriceModel.proof(
                        proof: widget.proof,
                        existingPrices: _existingPrices,
                      ),
                    ),
                  ),
                );
              },
            ),*/
      floatingBottomBar: SmoothModalSheet(
        title: 'Titre',
        closeButton: false,
        bodyPadding: EdgeInsets.zero,
        body: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: <Widget>[
              _PriceProofEntry(
                label: 'Date',
                value: dateFormat.format(widget.proof.created),
              ),
              _PriceProofEntry(
                label: 'Nombre de prix',
                value: widget.proof.priceCount.toString(),
              ),
              _PriceProofEntry(
                label: 'Date',
                value: dateFormat.format(widget.proof.created),
              ),
            ],
          ),
        ),
      ),

      children: <Widget>[
        SliverFillViewport(
          delegate: SliverChildBuilderDelegate((
            BuildContext context,
            int index,
          ) {
            return InteractiveViewer(
              child: Image.network(
                _getUrl(false),
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: SizedBox(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: Image.network(
                            _getUrl(true),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
              ),
            );
          }, childCount: 1),
        ),
      ],
    );
  }

  String _getUrl(final bool isThumbnail) => widget.proof
      .getFileUrl(
        uriProductHelper: ProductQuery.uriPricesHelper,
        isThumbnail: isThumbnail,
      )
      .toString();

  Future<void> _loadExistingPrices() async {
    if (PriceModel.isProofNotGoodEnough(widget.proof)) {
      return;
    }
    final MaybeError<GetPricesResult> prices =
        await OpenPricesAPIClient.getPrices(
          GetPricesParameters()..proofId = widget.proof.id,
          uriHelper: ProductQuery.uriPricesHelper,
        );
    if (prices.isError) {
      return;
    }
    _existingPrices = prices.value.items ?? <Price>[];

    if (mounted) {
      setState(() {});
    }
  }
}

class _PriceProofEntry extends StatelessWidget {
  const _PriceProofEntry({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

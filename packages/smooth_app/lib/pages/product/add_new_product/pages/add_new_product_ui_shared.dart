import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_page_args.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';

/// Card title for "Add new product" page.
class AddNewProductTitle extends StatelessWidget {
  const AddNewProductTitle(
    this.label, {
    this.maxLines,
  });

  final String label;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
        maxLines: maxLines,
      );
}

/// Card subtitle for "Add new product" page.
class AddNewProductSubTitle extends StatelessWidget {
  const AddNewProductSubTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}

/// Standard button in the "Add new product" page.
class AddNewProductButton extends StatelessWidget {
  const AddNewProductButton(
    this.label,
    this.iconData,
    this.onPressed, {
    required this.done,
    this.showTrailing = true,
  });

  final String label;
  final IconData iconData;
  final VoidCallback? onPressed;
  final bool done;
  final bool showTrailing;

  static const IconData doneIconData = Icons.check;
  static const IconData todoIconData = Icons.add;
  static IconData cameraIconData = Icons.add_a_photo_outlined;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool dark = themeData.brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: label,
        icon: iconData,
        onPressed: onPressed,
        trailing: showTrailing ? Icons.edit : null,
        backgroundColor: onPressed == null
            ? (dark ? darkGrey : lightGrey)
            : done
                ? Colors.green[700]
                : themeData.colorScheme.secondary,
        foregroundColor: onPressed == null
            ? (dark ? lightGrey : darkGrey)
            : done
                ? Colors.white
                : themeData.colorScheme.onSecondary,
      ),
    );
  }
}

/// Standard "editor" button in the "Add new product" page.
class AddNewProductEditorButton extends StatelessWidget {
  const AddNewProductEditorButton(
    this.editor, {
    this.forceIconData,
    this.disabled = false,
  });

  final ProductFieldEditor editor;
  final IconData? forceIconData;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    final bool done = editor.isPopulated(product);
    return AddNewProductButton(
      editor.getLabel(AppLocalizations.of(context)),
      forceIconData ??
          (done
              ? AddNewProductButton.doneIconData
              : AddNewProductButton.todoIconData),
      disabled
          ? null
          : () async => editor.edit(
                context: context,
                product: product,
                isLoggedInMandatory:
                    AddNewProductPageArgs.isLoggedInMandatory(context),
              ),
      done: done,
    );
  }
}

class AddNewProductScoreIcon extends StatelessWidget {
  const AddNewProductScoreIcon({
    required this.iconUrl,
    required this.defaultIconUrl,
  });

  final String? iconUrl;
  final String defaultIconUrl;

  @override
  Widget build(BuildContext context) => SvgIconChip(
        iconUrl ?? defaultIconUrl,
        height: MediaQuery.of(context).size.height * .2,
      );
}

class AddNewCategoriesButton extends StatelessWidget {
  const AddNewCategoriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AddNewProductEditorButton(
      _categoryEditor,
      forceIconData: Icons.filter_1,
    );
  }
}

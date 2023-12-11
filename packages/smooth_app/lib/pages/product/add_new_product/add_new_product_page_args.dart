import 'package:flutter/widgets.dart';

// ignore_for_file: library_private_types_in_public_api

class AddNewProductPageArgs extends InheritedModel<_AddNewProductPageArgType> {
  const AddNewProductPageArgs({
    required bool displayPictures,
    required bool displayMisc,
    required bool isLoggedInMandatory,
    required Widget child,
    super.key,
  })  : _displayPictures = displayPictures,
        _displayMisc = displayMisc,
        _isLoggedInMandatory = isLoggedInMandatory,
        super(child: child);

  final bool _displayPictures;
  final bool _displayMisc;
  final bool _isLoggedInMandatory;

  static bool displayMisc(BuildContext context) =>
      InheritedModel.inheritFrom<AddNewProductPageArgs>(context,
              aspect: _AddNewProductPageArgType.displayMisc)!
          ._displayMisc;

  static bool displayPictures(BuildContext context) =>
      InheritedModel.inheritFrom<AddNewProductPageArgs>(context,
              aspect: _AddNewProductPageArgType.displayPictures)!
          ._displayPictures;

  static bool isLoggedInMandatory(BuildContext context) =>
      InheritedModel.inheritFrom<AddNewProductPageArgs>(context,
              aspect: _AddNewProductPageArgType.isLoggedInMandatory)!
          ._isLoggedInMandatory;

  @override
  bool updateShouldNotify(AddNewProductPageArgs oldWidget) {
    return oldWidget._displayPictures != _displayPictures ||
        oldWidget._displayMisc != _displayMisc ||
        oldWidget._isLoggedInMandatory != _isLoggedInMandatory;
  }

  @override
  bool updateShouldNotifyDependent(AddNewProductPageArgs oldWidget,
      Set<_AddNewProductPageArgType> dependencies) {
    for (final Object dependency in dependencies) {
      if (dependency is _AddNewProductPageArgType) {
        switch (dependency) {
          case _AddNewProductPageArgType.displayPictures:
            if (oldWidget._displayPictures != _displayPictures) {
              return true;
            }
            break;
          case _AddNewProductPageArgType.displayMisc:
            if (oldWidget._displayMisc != _displayMisc) {
              return true;
            }
            break;
          case _AddNewProductPageArgType.isLoggedInMandatory:
            if (oldWidget._isLoggedInMandatory != _isLoggedInMandatory) {
              return true;
            }
            break;
        }
      }
    }

    return false;
  }
}

enum _AddNewProductPageArgType {
  displayPictures,
  displayMisc,
  isLoggedInMandatory,
}

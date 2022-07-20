import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/all_user_product_list_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/goldens.dart';
import '../tests_utils/mocks.dart';

void main() {
  group('UserPreferencesPage looks as expected', () {
    testGoldenWithLightAndDarkModes(
      (WidgetTester tester, SmoothieAppTheme currentTheme) async {
        await _moveToPage(
          currentTheme,
          tester,
          const UserPreferencesPage(),
        );
        await tester.pump();
      },
      (SmoothieAppTheme theme) => 'user_preferences_page-${theme.label}.png',
      (WidgetTester tester) => find.byType(UserPreferencesPage),
    );
  });

  group('AllUserProductList looks as expected', () {
    testGoldenWithLightAndDarkModes(
      (WidgetTester tester, SmoothieAppTheme currentTheme) async {
        await _moveToPage(
          currentTheme,
          tester,
          const AllUserProductList(),
        );
        await tester.pumpAndSettle();
      },
      (SmoothieAppTheme theme) =>
          'user_lists_preferences_page-${theme.label}.png',
      (WidgetTester tester) => find.byType(AllUserProductList),
    );
  });
}

Future<void> _moveToPage(
  SmoothieAppTheme currentTheme,
  WidgetTester tester,
  Widget page,
) async {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late LocalDatabase localDatabase;

  SharedPreferences.setMockInitialValues(
    mockSharedPreferences(
      themeDark: currentTheme.isDark,
    ),
  );

  userPreferences = await UserPreferences.getUserPreferences();
  localDatabase = await LocalDatabase.getLocalDatabase(fromTests: true);
  productPreferences = ProductPreferences(ProductPreferencesSelection(
    setImportance: userPreferences.setImportance,
    getImportance: userPreferences.getImportance,
    notify: () => productPreferences.notifyListeners(),
  ));
  await productPreferences.init(PlatformAssetBundle());
  await userPreferences.init(productPreferences);
  themeProvider = ThemeProvider(userPreferences);

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      themeProvider,
      localDatabase,
      page,
    ),
  );
}

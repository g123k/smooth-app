import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/consent_analytics_page.dart';
import 'package:smooth_app/pages/onboarding/preferences_page.dart';
import 'package:smooth_app/pages/onboarding/sample_eco_card_page.dart';
import 'package:smooth_app/pages/onboarding/sample_health_card_page.dart';
import 'package:smooth_app/pages/onboarding/welcome_page.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';

part 'app_routes_onboarding.dart';

abstract class AppRoutes {
  const AppRoutes._();

  factory AppRoutes({
    required UserPreferences userPreferences,
    List<NavigatorObserver>? observers,
  }) {
    return GoRouterAppRoutes(
      userPreferences: userPreferences,
      observers: observers,
    );
  }

  static const String ROUTE_HOME = '/';
  static const String ROUTE_ONBOARDING = '/onboarding';
  static const String ROUTE_ONBOARDING_NEXT_PAGE = '$ROUTE_ONBOARDING/next';
  static const String ROUTE_PRODUCT = '/product';

  RouteInformationParser<Object> get informationParser;

  RouterDelegate<Object> get delegate;

  Future<void> openNextOnboardingPage(BuildContext context);
}

class GoRouterAppRoutes implements AppRoutes {
  GoRouterAppRoutes({
    required UserPreferences userPreferences,
    List<NavigatorObserver>? observers,
  }) : router = GoRouter(
          initialLocation: AppRoutes.ROUTE_HOME,
          routes: <GoRoute>[
            GoRoute(
              path: AppRoutes.ROUTE_HOME,
              builder: (BuildContext context, GoRouterState state) {
                return PageManager();
              },
            ),
            GoRoute(
              path: AppRoutes.ROUTE_PRODUCT,
              builder: (BuildContext context, GoRouterState state) {
                final Product? product = state.extra as Product?;
                if (product == null) {
                  throw Exception(
                    'To open the product page, please provide a Product as extra',
                  );
                }

                return ProductPage(product);
              },
            ),
            _OnboardingAppRoutes(),
          ],
          redirect: (GoRouterState state) {
            final String routeName = state.location;

            if (routeName == AppRoutes.ROUTE_HOME) {
              if (OnboardingPagesUtils.shouldShowOnboarding(userPreferences)) {
                return AppRoutes.ROUTE_ONBOARDING;
              }
            }

            return null;
          },
          observers: observers,
        );

  final GoRouter router;

  @override
  RouterDelegate<Object> get delegate => router.routerDelegate;

  @override
  RouteInformationParser<Object> get informationParser =>
      router.routeInformationParser;

  @override
  Future<void> openNextOnboardingPage(BuildContext context) {
    throw UnimplementedError();
  }
}

part of 'app_routes.dart';

class _OnboardingAppRoutes extends GoRoute {
  _OnboardingAppRoutes()
      : super(
          path: AppRoutes.ROUTE_ONBOARDING,
          builder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return const WelcomePage();
          },
          redirect: (GoRouterState state) {
            // Redirect /onboarding to /onboarding/welcome
            final String routeName = state.location;

            if (routeName == AppRoutes.ROUTE_ONBOARDING) {
              return OnboardingPagesUtils._rewriteRoute(_ROUTE_WELCOME);
            }

            return null;
          },
          routes: <GoRoute>[
            _OnboardingAppPageRoute(
              OnboardingPages.WELCOME,
              builder: (_) => const WelcomePage(),
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.SCAN_EXAMPLE,
              builder: (_) => const WelcomePage(),
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.HEALTH_CARD_EXAMPLE,
              builder: (BuildContext context) {
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                return SampleHealthCardPage(localDatabase);
              },
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.ECO_CARD_EXAMPLE,
              builder: (BuildContext context) {
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                return SampleEcoCardPage(localDatabase);
              },
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.PREFERENCES_PAGE,
              builder: (BuildContext context) {
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                return PreferencesPage(localDatabase);
              },
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.CONSENT_PAGE,
              builder: (_) => const ConsentAnalytics(),
            ),
            _OnboardingAppPageRoute(
              OnboardingPages.ONBOARDING_COMPLETE,
              builder: (_) => const SizedBox(),
              redirect: (_) => AppRoutes.ROUTE_HOME,
            ),
          ],
        );

  static const String _ROUTE_WELCOME = 'welcome';
  static const String _ROUTE_SCAN_EXAMPLE = 'scan';
  static const String _ROUTE_HEALTH_CARD_EXAMPLE = 'health_card';
  static const String _ROUTE_ECO_CARD_EXAMPLE = 'eco_card';
  static const String _ROUTE_PREFERENCES = 'preferences';
  static const String _ROUTE_CONSENT = 'consent';
  static const String _ROUTE_COMPLETED = 'completed';
}

class _OnboardingAppPageRoute extends GoRoute {
  _OnboardingAppPageRoute(
    OnboardingPages page, {
    required WidgetBuilder builder,
    GoRouterRedirect? redirect,
  }) : super(
          path: page.path,
          builder: (BuildContext context, _) => builder(context),
          redirect: redirect ??
              (GoRouterState state) {
                if (state.queryParams
                    .containsKey(_QUERY_PARAM_OPEN_NEXT_PAGE_KEY)) {
                  final OnboardingPages? nextPage = page.next;
                  if (nextPage != null) {
                    return OnboardingPagesUtils._rewriteRoute(nextPage.path);
                  }
                }

                return null;
              },
        );

  static const String _QUERY_PARAM_OPEN_NEXT_PAGE_KEY = 'next';
  static const String _QUERY_PARAM_OPEN_NEXT_PAGE_VALUE = 'true';
}

class OnboardingPagesUtils {
  const OnboardingPagesUtils._();

  static String _rewriteRoute(String page) {
    assert(page.isNotEmpty);
    return path.join(AppRoutes.ROUTE_ONBOARDING, page);
  }

  static bool shouldShowOnboarding(UserPreferences preferences) {
    return preferences.lastVisitedOnboardingPage != _onBoardingPagesOrder.last;
  }

  static Future<void> openNextPage(BuildContext context) async {
    final Uri uri = Uri.parse(ModalRoute.of(context)!.settings.name!);

    final UserPreferences preferences = context.read<UserPreferences>();
    preferences.setLastVisitedOnboardingPage(_onBoardingPages[uri.path]!);

    GoRouter.of(context).push(
      uri.replace(
        queryParameters: <String, dynamic>{
          _OnboardingAppPageRoute._QUERY_PARAM_OPEN_NEXT_PAGE_KEY:
              _OnboardingAppPageRoute._QUERY_PARAM_OPEN_NEXT_PAGE_VALUE,
        },
      ).toString(),
    );
  }
}

enum OnboardingPages {
  NOT_STARTED,
  WELCOME,
  SCAN_EXAMPLE,
  HEALTH_CARD_EXAMPLE,
  ECO_CARD_EXAMPLE,
  PREFERENCES_PAGE,
  CONSENT_PAGE,
  ONBOARDING_COMPLETE,
}

List<OnboardingPages> _onBoardingPagesOrder = <OnboardingPages>[
  OnboardingPages.WELCOME,
  OnboardingPages.SCAN_EXAMPLE,
  OnboardingPages.HEALTH_CARD_EXAMPLE,
  OnboardingPages.ECO_CARD_EXAMPLE,
  OnboardingPages.PREFERENCES_PAGE,
  OnboardingPages.CONSENT_PAGE,
  OnboardingPages.ONBOARDING_COMPLETE,
];

Map<String, OnboardingPages> _onBoardingPages = <String, OnboardingPages>{
  _OnboardingAppRoutes._ROUTE_WELCOME: OnboardingPages.WELCOME,
  _OnboardingAppRoutes._ROUTE_SCAN_EXAMPLE: OnboardingPages.SCAN_EXAMPLE,
  _OnboardingAppRoutes._ROUTE_HEALTH_CARD_EXAMPLE:
      OnboardingPages.HEALTH_CARD_EXAMPLE,
  _OnboardingAppRoutes._ROUTE_ECO_CARD_EXAMPLE:
      OnboardingPages.ECO_CARD_EXAMPLE,
  _OnboardingAppRoutes._ROUTE_PREFERENCES: OnboardingPages.PREFERENCES_PAGE,
  _OnboardingAppRoutes._ROUTE_CONSENT: OnboardingPages.CONSENT_PAGE,
  _OnboardingAppRoutes._ROUTE_COMPLETED: OnboardingPages.ONBOARDING_COMPLETE,
};

extension _OnboardingPagesExt on OnboardingPages {
  int get position => _onBoardingPagesOrder.indexOf(this);

  OnboardingPages? get next {
    final int pagePosition = position;

    if (pagePosition < _onBoardingPagesOrder.length) {
      return _onBoardingPagesOrder[pagePosition + 1];
    } else {
      return null;
    }
  }

  String get path {
    for (final MapEntry<String, OnboardingPages> entry
        in _onBoardingPages.entries) {
      if (entry.value == this) {
        return entry.key;
      }
    }

    throw UnimplementedError();
  }
}

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'mocks.dart';

/// Generate new golden file images by running:
///     flutter test --update-goldens

/// Allowable percentage of pixel difference for cross-platform testing. Adjust as
/// needed to accommodate golden file testing on all machines.
///
/// Golden files can sometimes have insignificant differences when run on
/// different platforms (i.e. linux versus mac).
const double _kGoldenDiffTolerance = 0.10;

/// Wrapper function for golden tests in smooth_app.
///
/// Ensures tests are only fail when the tolerance level is exceeded, and
/// golden files are stored in a directory named goldens.
Future<void> expectGoldenMatches(dynamic actual, String goldenFileKey) async {
  final String goldenPath = path.join('goldens', goldenFileKey);
  goldenFileComparator = SmoothieFileComparator(path.join(
    (goldenFileComparator as LocalFileComparator).basedir.toString(),
    goldenFileKey,
  ));
  return expectLater(actual, matchesGoldenFile(goldenPath));
}

typedef WidgetTesterBrightnessCallback = Future<void> Function(
  WidgetTester widgetTester,
  SmoothieAppTheme currentTheme,
);

/// Starts a golden test which checks both light and dark mode.
/// - [initTestCallback] allows to navigate to the test page.
/// - [mockHttp] may be set to true to mock the HTTP requests with a
/// [MockHttpOverrides].
/// - [goldenFileNameCallback] is a callback that returns the name of the golden
/// depending on the theme.
/// - [goldenWidget] is the Widget used to compare the golden test.
/// - [disposeTestCallback] is an optional callback that is called after the test.
void testGoldenWithLightAndDarkModes(
  WidgetTesterBrightnessCallback initTestCallback,
  GoldenFileNameCallbackFinder goldenFileNameCallback,
  GoldenWidgetFinder goldenWidget, {
  WidgetTesterBrightnessCallback? disposeTestCallback,
  bool? mockHttp = true,
}) {
  for (final SmoothieAppTheme theme in SmoothieAppTheme.values) {
    testWidgets(theme.label, (WidgetTester tester) async {
      final HttpOverrides? priorOverrides;
      if (mockHttp == true) {
        // Override & mock out HTTP Requests
        priorOverrides = HttpOverrides.current;
        HttpOverrides.global = MockHttpOverrides();
      } else {
        priorOverrides = null;
      }

      await initTestCallback(tester, theme);

      await expectGoldenMatches(
        goldenWidget(tester),
        goldenFileNameCallback(theme),
      );

      expect(tester, meetsGuideline(textContrastGuideline));
      expect(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester, meetsGuideline(iOSTapTargetGuideline));
      expect(tester, meetsGuideline(androidTapTargetGuideline));

      if (disposeTestCallback != null) {
        disposeTestCallback.call(tester, theme);
      }

      if (mockHttp == true) {
        // Restore prior overrides
        HttpOverrides.global = priorOverrides;
      }
    });
  }
}

/// Filename in the "goldens" directory
typedef GoldenFileNameCallbackFinder = String Function(SmoothieAppTheme theme);
typedef GoldenWidgetFinder = Finder Function(WidgetTester widgetTester);

enum SmoothieAppTheme {
  dark('dark'),
  light('light');

  const SmoothieAppTheme(this.label);

  final String label;

  bool get isDark => this == dark;
}

class SmoothieFileComparator extends LocalFileComparator {
  SmoothieFileComparator(String testFile) : super(Uri.parse(testFile));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent > _kGoldenDiffTolerance) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    if (!result.passed) {
      log('A tolerable difference of ${result.diffPercent * 100}% was found when '
          'comparing $golden.');
    }
    return result.passed || result.diffPercent <= _kGoldenDiffTolerance;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_shams_mobile/features/splash/presentation/view/splash_view.dart';
import 'package:noor_shams_mobile/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoorAlShamsApp());

    // Verify that SplashView is present.
    expect(find.byType(SplashView), findsOneWidget);

    // Verify that Loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

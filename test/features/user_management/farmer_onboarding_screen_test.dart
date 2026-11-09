import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/user_management/presentation/onboarding/farmer_onboarding_screen.dart';
import 'package:muyu_app/l10n/app_localizations.dart';

void main() {
  testWidgets('shows the three farmer benefits and finishes the walkthrough', (tester) async {
    var finished = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FarmerOnboardingScreen(onFinished: () async => finished = true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('List your plot'), findsOneWidget);
    expect(find.bySemanticsLabel('A new crop growing from a plot'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Escrow financing'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Free weather alerts'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
  });
}

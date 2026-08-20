import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesti/adapters/in_memory_care_history_repository.dart';
import 'package:nesti/adapters/in_memory_settings_repository.dart';
import 'package:nesti/adapters/offline_companion_gateway.dart';
import 'package:nesti/adapters/prototype_context_provider.dart';
import 'package:nesti/app.dart';
import 'package:nesti/application/companion_orchestrator.dart';
import 'package:nesti/application/proactive_care_engine.dart';
import 'package:nesti/core/clock.dart';
import 'package:nesti/domain/user_preferences.dart';
import 'package:nesti/presentation/controllers/nesti_controller.dart';

void main() {
  final now = DateTime(2026, 8, 19, 10, 30);

  Future<NestiController> pumpNesti(
    WidgetTester tester, {
    UserPreferences preferences = const UserPreferences(),
  }) async {
    tester.view.physicalSize = const Size(1280, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final clock = FixedClock(now);
    final settings = InMemorySettingsRepository(preferences);
    final history = InMemoryCareHistoryRepository();
    final contextProvider = PrototypeContextProvider();
    final orchestrator = CompanionOrchestrator(
      engine: const ProactiveCareEngine(),
      clock: clock,
      settings: settings,
      history: history,
      gateway: const OfflineCompanionGateway(),
      contextProvider: contextProvider,
    );
    final controller = NestiController(
      orchestrator: orchestrator,
      clock: clock,
      settings: settings,
      history: history,
      contextProvider: contextProvider,
    );
    await controller.initialize();
    await tester.pumpWidget(NestiApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 300));
    return controller;
  }

  testWidgets('onboarding leads to a single explainable greeting', (
    tester,
  ) async {
    await pumpNesti(tester);

    expect(find.text('你好，我是栖伴。'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('display_name_field')), '小林');
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('想要怎样的陪伴？'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('控制权一直在你手里。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_finish')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('栖伴 Nesti'), findsOneWidget);
    expect(find.textContaining('小林好，今天也一起慢慢来'), findsOneWidget);
    expect(find.textContaining('为什么出现'), findsOneWidget);
  });

  testWidgets('care can be completed and then becomes quiet', (tester) async {
    final controller = await pumpNesti(
      tester,
      preferences: const UserPreferences(
        displayName: '小林',
        onboardingCompleted: true,
        reduceMotion: true,
      ),
    );

    expect(find.byKey(const Key('complete_care')), findsOneWidget);
    await tester.tap(find.byKey(const Key('complete_care')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.currentCare, isNull);
    expect(find.text('安静陪伴中'), findsWidgets);
    expect(find.byKey(const Key('complete_care')), findsNothing);
  });

  testWidgets('offline chat responds without external service', (tester) async {
    await pumpNesti(
      tester,
      preferences: const UserPreferences(
        displayName: '小林',
        onboardingCompleted: true,
      ),
    );

    await tester.tap(find.byKey(const Key('chat_button')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.enterText(find.byKey(const Key('chat_input')), '今天有点累');
    await tester.tap(find.byKey(const Key('send_message')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('今天有点累'), findsOneWidget);
    expect(find.textContaining('今天有点费力'), findsOneWidget);
    expect(find.text('离线模式'), findsOneWidget);
  });
}

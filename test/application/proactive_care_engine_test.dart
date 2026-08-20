import 'package:flutter_test/flutter_test.dart';
import 'package:nesti/application/proactive_care_engine.dart';
import 'package:nesti/domain/care_action.dart';
import 'package:nesti/domain/care_context.dart';
import 'package:nesti/domain/care_interaction.dart';
import 'package:nesti/domain/user_preferences.dart';

void main() {
  final now = DateTime(2026, 8, 19, 10, 30);
  const engine = ProactiveCareEngine();

  CareEvaluationInput input({
    UserPreferences preferences = const UserPreferences(
      onboardingCompleted: true,
    ),
    CareContext context = const CareContext(working: true),
    List<CareInteraction> history = const [],
    DateTime? workSessionStartedAt,
  }) {
    return CareEvaluationInput(
      now: now,
      preferences: preferences,
      context: context,
      history: history,
      workSessionStartedAt:
          workSessionStartedAt ?? now.subtract(const Duration(hours: 2)),
    );
  }

  group('hard suppression', () {
    test('stays quiet during do not disturb', () {
      final decision = engine.evaluate(
        input(context: const CareContext(working: true, doNotDisturb: true)),
      );

      expect(decision.isQuiet, isTrue);
      expect(decision.reason, CareDecisionReason.doNotDisturb);
    });

    test(
      'stays quiet during meetings, fullscreen, and active conversation',
      () {
        for (final context in [
          const CareContext(working: true, meetingLikely: true),
          const CareContext(working: true, fullscreen: true),
          const CareContext(working: true, conversationActive: true),
        ]) {
          expect(engine.evaluate(input(context: context)).isQuiet, isTrue);
        }
      },
    );

    test('stays quiet inside configured quiet hours', () {
      final decision = engine.evaluate(
        input(
          preferences: const UserPreferences(
            onboardingCompleted: true,
            quietHours: QuietHours(startMinute: 9 * 60, endMinute: 11 * 60),
          ),
        ),
      );

      expect(decision.reason, CareDecisionReason.quietHours);
    });
  });

  group('candidate selection', () {
    test('offers a greeting at most once per local day', () {
      final first = engine.evaluate(input());
      expect(first.action?.type, CareType.greeting);

      final second = engine.evaluate(
        input(
          history: [
            CareInteraction(
              actionId: first.action!.id,
              type: CareType.greeting,
              outcome: CareOutcome.shown,
              occurredAt: now.subtract(const Duration(minutes: 5)),
            ),
          ],
        ),
      );

      expect(second.action?.type, CareType.hydration);
    });

    test('respects hydration cooldown', () {
      final decision = engine.evaluate(
        input(
          history: [
            CareInteraction(
              actionId: 'greeting-today',
              type: CareType.greeting,
              outcome: CareOutcome.shown,
              occurredAt: now.subtract(const Duration(minutes: 10)),
            ),
            CareInteraction(
              actionId: 'water-recent',
              type: CareType.hydration,
              outcome: CareOutcome.completed,
              occurredAt: now.subtract(const Duration(minutes: 20)),
            ),
          ],
        ),
      );

      expect(decision.action?.type, CareType.movement);
    });

    test('a recent dismissal lengthens same-type cooldown', () {
      final decision = engine.evaluate(
        input(
          preferences: const UserPreferences(
            onboardingCompleted: true,
            movementEnabled: false,
          ),
          history: [
            CareInteraction(
              actionId: 'greeting-today',
              type: CareType.greeting,
              outcome: CareOutcome.shown,
              occurredAt: now.subtract(const Duration(minutes: 10)),
            ),
            CareInteraction(
              actionId: 'water-dismissed',
              type: CareType.hydration,
              outcome: CareOutcome.dismissed,
              occurredAt: now.subtract(const Duration(minutes: 90)),
            ),
          ],
        ),
      );

      expect(decision.isQuiet, isTrue);
      expect(decision.reason, CareDecisionReason.cooldown);
    });

    test('three consecutive ignores enter a quiet state', () {
      final history = List.generate(
        3,
        (index) => CareInteraction(
          actionId: 'ignored-$index',
          type: CareType.hydration,
          outcome: CareOutcome.ignored,
          occurredAt: now.subtract(Duration(hours: index + 1)),
        ),
      );

      final decision = engine.evaluate(input(history: history));

      expect(decision.isQuiet, isTrue);
      expect(decision.reason, CareDecisionReason.repeatedIgnoring);
    });

    test('disabled reminder types are never generated', () {
      final decision = engine.evaluate(
        input(
          preferences: const UserPreferences(
            onboardingCompleted: true,
            greetingEnabled: false,
            hydrationEnabled: false,
            movementEnabled: false,
          ),
        ),
      );

      expect(decision.isQuiet, isTrue);
      expect(decision.reason, CareDecisionReason.noCandidate);
    });
  });
}

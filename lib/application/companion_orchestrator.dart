import '../core/clock.dart';
import '../domain/care_action.dart';
import '../domain/care_interaction.dart';
import '../ports/care_history_repository.dart';
import '../ports/companion_gateway.dart';
import '../ports/context_provider.dart';
import '../ports/settings_repository.dart';
import 'proactive_care_engine.dart';

class CompanionOrchestrator {
  const CompanionOrchestrator({
    required this.engine,
    required this.clock,
    required this.settings,
    required this.history,
    required this.gateway,
    required this.contextProvider,
  });

  final ProactiveCareEngine engine;
  final Clock clock;
  final SettingsRepository settings;
  final CareHistoryRepository history;
  final CompanionGateway gateway;
  final ContextProvider contextProvider;

  Future<CareDecision> evaluateCare({
    required DateTime workSessionStartedAt,
  }) async {
    final now = clock.now();
    final decision = engine.evaluate(
      CareEvaluationInput(
        now: now,
        preferences: await settings.load(),
        context: await contextProvider.snapshot(),
        history: await history.list(),
        workSessionStartedAt: workSessionStartedAt,
      ),
    );
    final action = decision.action;
    if (action != null) {
      await history.add(
        CareInteraction(
          actionId: action.id,
          type: action.type,
          outcome: CareOutcome.shown,
          occurredAt: now,
        ),
      );
    }
    return decision;
  }

  Future<String> replyToUser(String message) async {
    final preferences = await settings.load();
    return gateway.reply(
      message: message,
      displayName: preferences.displayName,
    );
  }

  Future<void> recordOutcome(
    CareAction action,
    CareOutcome outcome, {
    Duration snooze = const Duration(minutes: 20),
  }) async {
    final now = clock.now();
    await history.add(
      CareInteraction(
        actionId: action.id,
        type: action.type,
        outcome: outcome,
        occurredAt: now,
        snoozedUntil: outcome == CareOutcome.snoozed ? now.add(snooze) : null,
      ),
    );
    if (outcome == CareOutcome.typeDisabled) {
      await disableType(action.type);
    }
  }

  Future<void> disableType(CareType type) async {
    final current = await settings.load();
    final next = switch (type) {
      CareType.greeting => current.copyWith(greetingEnabled: false),
      CareType.hydration => current.copyWith(hydrationEnabled: false),
      CareType.movement => current.copyWith(movementEnabled: false),
      _ => current,
    };
    await settings.save(next);
  }
}

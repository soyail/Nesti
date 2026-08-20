import '../domain/care_action.dart';
import '../domain/care_context.dart';
import '../domain/care_interaction.dart';
import '../domain/user_preferences.dart';

class CareEvaluationInput {
  const CareEvaluationInput({
    required this.now,
    required this.preferences,
    required this.context,
    required this.history,
    required this.workSessionStartedAt,
  });

  final DateTime now;
  final UserPreferences preferences;
  final CareContext context;
  final List<CareInteraction> history;
  final DateTime workSessionStartedAt;
}

class ProactiveCareEngine {
  const ProactiveCareEngine();

  CareDecision evaluate(CareEvaluationInput input) {
    final hardSuppression = _hardSuppression(input);
    if (hardSuppression != null) return CareDecision.quiet(hardSuppression);

    if (_hasRepeatedIgnoring(input.history)) {
      return const CareDecision.quiet(CareDecisionReason.repeatedIgnoring);
    }

    final candidates = _generateCandidates(input);
    if (candidates.isEmpty) {
      final hasEnabledDueType =
          input.preferences.greetingEnabled ||
          input.preferences.hydrationEnabled ||
          input.preferences.movementEnabled;
      return CareDecision.quiet(
        hasEnabledDueType
            ? CareDecisionReason.cooldown
            : CareDecisionReason.noCandidate,
      );
    }

    candidates.sort((a, b) {
      final byPriority = b.priority.index.compareTo(a.priority.index);
      if (byPriority != 0) return byPriority;
      return a.type.index.compareTo(b.type.index);
    });
    return CareDecision.selected(candidates.first);
  }

  CareDecisionReason? _hardSuppression(CareEvaluationInput input) {
    if (input.preferences.carePaused) return CareDecisionReason.carePaused;
    if (input.context.doNotDisturb) return CareDecisionReason.doNotDisturb;
    if (input.preferences.quietHours.contains(input.now)) {
      return CareDecisionReason.quietHours;
    }
    if (input.context.meetingLikely) return CareDecisionReason.meetingLikely;
    if (input.context.fullscreen) return CareDecisionReason.fullscreen;
    if (input.context.conversationActive) {
      return CareDecisionReason.activeConversation;
    }
    if (!input.context.working) return CareDecisionReason.notWorking;
    return null;
  }

  bool _hasRepeatedIgnoring(List<CareInteraction> history) {
    final recent = [...history]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (recent.length < 3) return false;
    return recent.take(3).every((item) => item.outcome == CareOutcome.ignored);
  }

  List<CareAction> _generateCandidates(CareEvaluationInput input) {
    final actions = <CareAction>[];
    final preferences = input.preferences;

    if (preferences.greetingEnabled && !_hasGreetingToday(input)) {
      actions.add(
        _action(
          input: input,
          type: CareType.greeting,
          priority: CarePriority.high,
          reason: '今天第一次进入工作状态',
          cooldown: const Duration(days: 1),
          message: '${_friendlyName(preferences.displayName)}，今天也一起慢慢来。',
          expectedAction: ExpectedAction.acknowledge,
          signals: const ['working', 'firstGreetingToday'],
        ),
      );
    }

    if (preferences.hydrationEnabled &&
        _sessionElapsed(input, preferences.hydrationInterval) &&
        _cooldownElapsed(
          input,
          CareType.hydration,
          preferences.hydrationInterval,
        )) {
      actions.add(
        _action(
          input: input,
          type: CareType.hydration,
          priority: CarePriority.normal,
          reason: '距离上次喝水关怀已有一段时间',
          cooldown: preferences.hydrationInterval,
          message: '已经专注一阵子啦，要不要顺手接杯水？',
          expectedAction: ExpectedAction.hydrate,
          signals: const ['working', 'hydrationIntervalElapsed'],
        ),
      );
    }

    if (preferences.movementEnabled &&
        _sessionElapsed(input, preferences.movementInterval) &&
        _cooldownElapsed(
          input,
          CareType.movement,
          preferences.movementInterval,
        )) {
      actions.add(
        _action(
          input: input,
          type: CareType.movement,
          priority: CarePriority.low,
          reason: '持续工作了一段时间且近期没有活动关怀',
          cooldown: preferences.movementInterval,
          message: '肩膀也许想换个姿势了，要不要起来走两步？',
          expectedAction: ExpectedAction.move,
          signals: const ['working', 'movementIntervalElapsed'],
        ),
      );
    }

    return actions;
  }

  String _friendlyName(String name) => name.trim().isEmpty ? '嗨' : '$name好';

  bool _sessionElapsed(CareEvaluationInput input, Duration interval) {
    return !input.now.isBefore(input.workSessionStartedAt.add(interval));
  }

  bool _hasGreetingToday(CareEvaluationInput input) {
    return input.history.any(
      (item) =>
          item.type == CareType.greeting &&
          item.occurredAt.year == input.now.year &&
          item.occurredAt.month == input.now.month &&
          item.occurredAt.day == input.now.day,
    );
  }

  bool _cooldownElapsed(
    CareEvaluationInput input,
    CareType type,
    Duration baseCooldown,
  ) {
    final sameType = input.history.where((item) => item.type == type).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (sameType.isEmpty) return true;

    final latest = sameType.first;
    if (latest.snoozedUntil != null &&
        input.now.isBefore(latest.snoozedUntil!)) {
      return false;
    }
    final multiplier = switch (latest.outcome) {
      CareOutcome.dismissed || CareOutcome.ignored => 2,
      _ => 1,
    };
    return !input.now.isBefore(
      latest.occurredAt.add(baseCooldown * multiplier),
    );
  }

  CareAction _action({
    required CareEvaluationInput input,
    required CareType type,
    required CarePriority priority,
    required String reason,
    required Duration cooldown,
    required String message,
    required ExpectedAction expectedAction,
    required List<String> signals,
  }) {
    final minuteBucket = input.now.millisecondsSinceEpoch ~/ 60000;
    final key =
        '${type.name}-${input.now.year}-${input.now.month}-${input.now.day}';
    return CareAction(
      id: '${type.name}-$minuteBucket',
      type: type,
      reason: reason,
      priority: priority,
      createdAt: input.now,
      cooldown: cooldown,
      quietHoursApplied: true,
      userPreferenceEnabled: true,
      dismissible: true,
      suggestedMessage: message,
      expectedAction: expectedAction,
      expiresAt: input.now.add(const Duration(minutes: 15)),
      deduplicationKey: key,
      sourceSignals: signals,
    );
  }
}

enum CareType {
  greeting,
  encouragement,
  hydration,
  movement,
  rest,
  journal,
  checkIn,
  celebration,
  quiet,
}

enum CarePriority { low, normal, high }

enum ExpectedAction { acknowledge, hydrate, move, rest, reflect, chat, none }

class CareAction {
  const CareAction({
    required this.id,
    required this.type,
    required this.reason,
    required this.priority,
    required this.createdAt,
    required this.cooldown,
    required this.quietHoursApplied,
    required this.userPreferenceEnabled,
    required this.dismissible,
    required this.suggestedMessage,
    required this.expectedAction,
    required this.expiresAt,
    required this.deduplicationKey,
    required this.sourceSignals,
    this.policyVersion = 'care-v1',
  });

  final String id;
  final CareType type;
  final String reason;
  final CarePriority priority;
  final DateTime createdAt;
  final Duration cooldown;
  final bool quietHoursApplied;
  final bool userPreferenceEnabled;
  final bool dismissible;
  final String suggestedMessage;
  final ExpectedAction expectedAction;
  final DateTime expiresAt;
  final String deduplicationKey;
  final List<String> sourceSignals;
  final String policyVersion;

  bool isExpiredAt(DateTime time) => !expiresAt.isAfter(time);
}

enum CareDecisionReason {
  selected,
  carePaused,
  doNotDisturb,
  quietHours,
  meetingLikely,
  fullscreen,
  activeConversation,
  notWorking,
  repeatedIgnoring,
  cooldown,
  noCandidate,
}

class CareDecision {
  const CareDecision._({required this.reason, this.action});

  const CareDecision.selected(CareAction action)
    : this._(reason: CareDecisionReason.selected, action: action);

  const CareDecision.quiet(CareDecisionReason reason) : this._(reason: reason);

  final CareDecisionReason reason;
  final CareAction? action;

  bool get isQuiet => action == null;
}

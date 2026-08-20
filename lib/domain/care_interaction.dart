import 'care_action.dart';

enum CareOutcome { shown, ignored, dismissed, snoozed, completed, typeDisabled }

class CareInteraction {
  const CareInteraction({
    required this.actionId,
    required this.type,
    required this.outcome,
    required this.occurredAt,
    this.snoozedUntil,
  });

  final String actionId;
  final CareType type;
  final CareOutcome outcome;
  final DateTime occurredAt;
  final DateTime? snoozedUntil;
}

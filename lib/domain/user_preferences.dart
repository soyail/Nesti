class QuietHours {
  const QuietHours({required this.startMinute, required this.endMinute});

  final int startMinute;
  final int endMinute;

  bool contains(DateTime localTime) {
    final minute = localTime.hour * 60 + localTime.minute;
    if (startMinute == endMinute) return false;
    if (startMinute < endMinute) {
      return minute >= startMinute && minute < endMinute;
    }
    return minute >= startMinute || minute < endMinute;
  }
}

class UserPreferences {
  const UserPreferences({
    this.displayName = '你',
    this.onboardingCompleted = false,
    this.greetingEnabled = true,
    this.hydrationEnabled = true,
    this.movementEnabled = true,
    this.hydrationInterval = const Duration(minutes: 75),
    this.movementInterval = const Duration(minutes: 90),
    this.quietHours = const QuietHours(startMinute: 22 * 60, endMinute: 8 * 60),
    this.carePaused = false,
    this.sensingPaused = false,
    this.reduceMotion = false,
  });

  final String displayName;
  final bool onboardingCompleted;
  final bool greetingEnabled;
  final bool hydrationEnabled;
  final bool movementEnabled;
  final Duration hydrationInterval;
  final Duration movementInterval;
  final QuietHours quietHours;
  final bool carePaused;
  final bool sensingPaused;
  final bool reduceMotion;

  UserPreferences copyWith({
    String? displayName,
    bool? onboardingCompleted,
    bool? greetingEnabled,
    bool? hydrationEnabled,
    bool? movementEnabled,
    Duration? hydrationInterval,
    Duration? movementInterval,
    QuietHours? quietHours,
    bool? carePaused,
    bool? sensingPaused,
    bool? reduceMotion,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      greetingEnabled: greetingEnabled ?? this.greetingEnabled,
      hydrationEnabled: hydrationEnabled ?? this.hydrationEnabled,
      movementEnabled: movementEnabled ?? this.movementEnabled,
      hydrationInterval: hydrationInterval ?? this.hydrationInterval,
      movementInterval: movementInterval ?? this.movementInterval,
      quietHours: quietHours ?? this.quietHours,
      carePaused: carePaused ?? this.carePaused,
      sensingPaused: sensingPaused ?? this.sensingPaused,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

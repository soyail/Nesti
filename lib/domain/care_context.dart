class CareContext {
  const CareContext({
    this.working = false,
    this.meetingLikely = false,
    this.fullscreen = false,
    this.doNotDisturb = false,
    this.conversationActive = false,
    this.sensingAvailable = true,
  });

  final bool working;
  final bool meetingLikely;
  final bool fullscreen;
  final bool doNotDisturb;
  final bool conversationActive;
  final bool sensingAvailable;

  CareContext copyWith({
    bool? working,
    bool? meetingLikely,
    bool? fullscreen,
    bool? doNotDisturb,
    bool? conversationActive,
    bool? sensingAvailable,
  }) {
    return CareContext(
      working: working ?? this.working,
      meetingLikely: meetingLikely ?? this.meetingLikely,
      fullscreen: fullscreen ?? this.fullscreen,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      conversationActive: conversationActive ?? this.conversationActive,
      sensingAvailable: sensingAvailable ?? this.sensingAvailable,
    );
  }
}

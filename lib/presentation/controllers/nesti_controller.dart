import 'package:flutter/foundation.dart';

import '../../adapters/prototype_context_provider.dart';
import '../../application/companion_orchestrator.dart';
import '../../core/clock.dart';
import '../../domain/care_action.dart';
import '../../domain/care_context.dart';
import '../../domain/care_interaction.dart';
import '../../domain/chat_message.dart';
import '../../domain/user_preferences.dart';
import '../../ports/care_history_repository.dart';
import '../../ports/settings_repository.dart';

enum CompanionPanel { home, chat, settings }

class NestiController extends ChangeNotifier {
  NestiController({
    required this.orchestrator,
    required this.clock,
    required this.settings,
    required this.history,
    required this.contextProvider,
  }) : workSessionStartedAt = clock.now().subtract(const Duration(hours: 2));

  final CompanionOrchestrator orchestrator;
  final Clock clock;
  final SettingsRepository settings;
  final CareHistoryRepository history;
  final PrototypeContextProvider contextProvider;
  final DateTime workSessionStartedAt;

  UserPreferences preferences = const UserPreferences();
  CompanionPanel panel = CompanionPanel.home;
  CareAction? currentCare;
  CareDecisionReason lastDecisionReason = CareDecisionReason.noCandidate;
  bool isReady = false;
  bool isReplying = false;
  final List<ChatMessage> messages = [];

  Future<void> initialize() async {
    preferences = await settings.load();
    isReady = true;
    notifyListeners();
    if (preferences.onboardingCompleted) await evaluateCare();
  }

  Future<void> completeOnboarding({
    required String displayName,
    required bool hydrationEnabled,
    required bool movementEnabled,
    required bool greetingEnabled,
    required bool reduceMotion,
  }) async {
    preferences = preferences.copyWith(
      displayName: displayName.trim().isEmpty ? '你' : displayName.trim(),
      onboardingCompleted: true,
      hydrationEnabled: hydrationEnabled,
      movementEnabled: movementEnabled,
      greetingEnabled: greetingEnabled,
      reduceMotion: reduceMotion,
    );
    await settings.save(preferences);
    notifyListeners();
    await evaluateCare();
  }

  Future<void> evaluateCare() async {
    final decision = await orchestrator.evaluateCare(
      workSessionStartedAt: workSessionStartedAt,
    );
    currentCare = decision.action;
    lastDecisionReason = decision.reason;
    notifyListeners();
  }

  Future<void> actOnCare(CareOutcome outcome) async {
    final action = currentCare;
    if (action == null) return;
    // Remove the visible candidate immediately so an interaction never leaves
    // a stale action on screen while persistence completes.
    currentCare = null;
    notifyListeners();
    await orchestrator.recordOutcome(action, outcome);
    preferences = await settings.load();
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final message = content.trim();
    if (message.isEmpty || isReplying) return;
    panel = CompanionPanel.chat;
    isReplying = true;
    currentCare = null;
    contextProvider.update(
      contextProvider.current.copyWith(conversationActive: true),
    );
    messages.add(
      ChatMessage(
        id: 'user-${clock.now().microsecondsSinceEpoch}',
        role: ChatRole.user,
        content: message,
        createdAt: clock.now(),
      ),
    );
    notifyListeners();

    final reply = await orchestrator.replyToUser(message);
    messages.add(
      ChatMessage(
        id: 'nesti-${clock.now().microsecondsSinceEpoch}',
        role: ChatRole.companion,
        content: reply,
        createdAt: clock.now(),
      ),
    );
    contextProvider.update(
      contextProvider.current.copyWith(conversationActive: false),
    );
    isReplying = false;
    notifyListeners();
  }

  void showPanel(CompanionPanel next) {
    panel = next;
    notifyListeners();
  }

  Future<void> setCarePaused(bool value) async {
    preferences = preferences.copyWith(carePaused: value);
    await settings.save(preferences);
    if (value) currentCare = null;
    notifyListeners();
  }

  Future<void> setSensingPaused(bool value) async {
    preferences = preferences.copyWith(sensingPaused: value);
    contextProvider.update(
      contextProvider.current.copyWith(sensingAvailable: !value),
    );
    await settings.save(preferences);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    preferences = preferences.copyWith(reduceMotion: value);
    await settings.save(preferences);
    notifyListeners();
  }

  Future<void> setReminderEnabled(CareType type, bool value) async {
    preferences = switch (type) {
      CareType.greeting => preferences.copyWith(greetingEnabled: value),
      CareType.hydration => preferences.copyWith(hydrationEnabled: value),
      CareType.movement => preferences.copyWith(movementEnabled: value),
      _ => preferences,
    };
    await settings.save(preferences);
    notifyListeners();
  }

  void setDoNotDisturb(bool value) {
    contextProvider.update(
      contextProvider.current.copyWith(doNotDisturb: value),
    );
    if (value) currentCare = null;
    notifyListeners();
  }

  Future<void> deletePrototypeData() async {
    await history.clear();
    messages.clear();
    currentCare = null;
    notifyListeners();
  }

  CareContext get context => contextProvider.current;

  String get quietStatus {
    if (preferences.carePaused) return '主动关怀已暂停';
    if (context.doNotDisturb) return '勿扰模式中';
    if (preferences.sensingPaused) return '桌面感知已暂停';
    return '安静陪伴中';
  }
}

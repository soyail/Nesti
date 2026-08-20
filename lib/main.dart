import 'package:flutter/widgets.dart';

import 'adapters/in_memory_care_history_repository.dart';
import 'adapters/in_memory_settings_repository.dart';
import 'adapters/offline_companion_gateway.dart';
import 'adapters/prototype_context_provider.dart';
import 'app.dart';
import 'application/companion_orchestrator.dart';
import 'application/proactive_care_engine.dart';
import 'core/clock.dart';
import 'presentation/controllers/nesti_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final clock = const SystemClock();
  final settings = InMemorySettingsRepository();
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
  controller.initialize();
  runApp(NestiApp(controller: controller));
}

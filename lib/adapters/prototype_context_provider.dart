import '../domain/care_context.dart';
import '../ports/context_provider.dart';

class PrototypeContextProvider implements ContextProvider {
  PrototypeContextProvider([
    this.current = const CareContext(working: true, sensingAvailable: false),
  ]);

  CareContext current;

  @override
  Future<CareContext> snapshot() async => current;

  void update(CareContext context) => current = context;
}

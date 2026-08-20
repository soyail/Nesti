import '../domain/care_context.dart';

abstract interface class ContextProvider {
  Future<CareContext> snapshot();
}

import '../ports/companion_gateway.dart';

class OfflineCompanionGateway implements CompanionGateway {
  const OfflineCompanionGateway();

  @override
  Future<String> reply({
    required String message,
    required String displayName,
  }) async {
    final normalized = message.trim();
    if (normalized.isEmpty) return '我在呢。';
    if (_containsAny(normalized, const ['累', '烦', '难受', '低落'])) {
      return '听起来今天有点费力。我先陪你待一会儿；如果你愿意，也可以只说最卡住的那一点。';
    }
    if (_containsAny(normalized, const ['完成', '搞定', '做完'])) {
      return '好耶，稳稳收下一小步。要不要先喘口气，再想下一件事？';
    }
    if (_containsAny(normalized, const ['你好', '嗨', '早'])) {
      return '$displayName好呀。今天想安静一起工作，还是先聊两句？';
    }
    return '收到啦。我现在是离线陪伴模式，不会把这段话发到外部；你可以继续说，我会在这里陪着。';
  }

  bool _containsAny(String value, List<String> needles) {
    return needles.any(value.contains);
  }
}

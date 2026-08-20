enum CapabilityStatus {
  supported,
  unsupported,
  permissionRequired,
  permissionDenied,
  temporarilyUnavailable,
}

class CapabilityResult<T> {
  const CapabilityResult({required this.status, this.value, this.reason});

  final CapabilityStatus status;
  final T? value;
  final String? reason;
}

abstract interface class WindowController {
  Future<CapabilityResult<void>> show();
  Future<CapabilityResult<void>> hide();
  Future<CapabilityResult<void>> setAlwaysOnTop(bool enabled);
  Future<CapabilityResult<void>> setClickThrough(bool enabled);
}

abstract interface class PowerStateProvider {
  Future<CapabilityResult<bool>> isEnergySaving();
}

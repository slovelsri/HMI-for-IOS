/// Sealed failure types for structured error handling across the app.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-related failure (timeout, no WiFi, socket error).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// HMI device is unreachable at the given IP:port.
class UnreachableFailure extends Failure {
  const UnreachableFailure(super.message);
}

/// Local storage read/write failure.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Input validation failure (invalid IP format, empty name, etc.).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

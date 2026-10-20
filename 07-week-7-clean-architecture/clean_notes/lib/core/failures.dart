// Failure = kegagalan yang sudah diterjemahkan ke bahasa pengguna.
// Berada di core (bukan di dalam fitur) karena dipakai lintas fitur.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Exception pembungkus Failure agar bisa dilempar keluar dari provider.
/// UI tetap hanya membaca `message`, bukan exception mentah.
class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => failure.message;
}

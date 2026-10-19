class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

// Mock auth provider + JWT simulasi agar codelab bisa berjalan tanpa backend.
// Saat backend Firebase siap, ganti isi login() dengan:
//   FirebaseAuth.instance.signInWithEmailAndPassword(...)
// karena pola repository + token refresh di bawah tetap sama.
class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    // Simulasi JWT: header.payload.signature.
    // Jangan pernah mem-parse JWT manual di produksi; verifikasi di server.
    return AuthSession(
      access: 'mock-access-for-$email-${DateTime.now().millisecondsSinceEpoch}',
      refresh: 'mock-refresh-for-$email',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}

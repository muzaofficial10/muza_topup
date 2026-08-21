import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

class AuthService {
  final _client = SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
    // Profile row is auto-created by a DB trigger (see schema.sql:
    // handle_new_user()) so it can never be skipped by a client bug.
    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Checks the `is_admin` flag on the caller's own profile row.
  /// This is a convenience UI check only — actual admin authorization is
  /// enforced server-side via RLS policies that check the same flag, so a
  /// modified client can never gain real admin access.
  Future<bool> isCurrentUserAdmin() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await _client
        .from('profiles')
        .select('is_admin')
        .eq('id', uid)
        .maybeSingle();
    return row?['is_admin'] == true;
  }

  User? get currentUser => _client.auth.currentUser;
}

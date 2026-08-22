import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const String _url = 'https://lcslhmrtfdzzqbmcaoqx.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxjc2xobXJ0ZmR6enFibWNhb3F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyODE1NDksImV4cCI6MjEwMjg1NzU0OX0.tvhZVpXBaFvguCCKZaZpAJ3kgI-h-MPWNCar-DUdrXE';

  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
}

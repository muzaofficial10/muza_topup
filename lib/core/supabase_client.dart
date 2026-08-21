import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase access point.
///
/// Reads credentials from `.env` (never hard-code keys in source).
/// Only the ANON key belongs in the app — the service_role key must
/// stay server-side (Supabase Edge Functions / admin dashboard backend).
class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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

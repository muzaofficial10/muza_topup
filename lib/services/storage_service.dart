import 'dart:io';
import 'package:uuid/uuid.dart';
import '../core/supabase_client.dart';

class StorageService {
  final _client = SupabaseService.client;
  static const String bucket = 'payment-screenshots';
  final _uuid = const Uuid();

  /// Uploads a payment screenshot to the private `payment-screenshots`
  /// bucket, namespaced by user id so RLS storage policies can restrict
  /// each user to their own folder. Returns the storage path (not a public
  /// URL — screenshots are private; use [getSignedUrl] to view them).
  Future<String> uploadScreenshot(File file, String userId) async {
    final ext = file.path.split('.').last;
    final path = '$userId/${_uuid.v4()}.$ext';
    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(cacheControl: '3600', upsert: false),
        );
    return path;
  }

  /// Generates a time-limited signed URL for viewing a private screenshot
  /// (used by both the customer's own order detail view and the admin
  /// dashboard).
  Future<String> getSignedUrl(String path, {int expiresInSeconds = 3600}) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }
}

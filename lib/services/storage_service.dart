import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String AVATAR_BUCKET = 'avatars';

  static Future<String?> uploadAvatar(File imageFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException("User is not authenticated for upload.");
    }

    final userId = user.id;
    final fileExtension = p.extension(imageFile.path);

    final fileName = 'profile_avatar$fileExtension';
    final storagePath = '$userId/$fileName';

    try {
      await _supabase.storage
          .from(AVATAR_BUCKET)
          .upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _supabase.storage
          .from(AVATAR_BUCKET)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Storage Upload Error: $e');
      rethrow;
    }
  }
}

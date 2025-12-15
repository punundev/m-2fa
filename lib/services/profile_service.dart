import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// phanunboy007@gmail.com  password

class ProfileService {
  static Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    try {
      final profileUpdateData = {
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('profiles')
          .update(profileUpdateData)
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update profile data: ${e.message}');
    }

    try {
      final authUpdateData = UserAttributes(
        data: {'name': fullName, 'avatar_url': avatarUrl},
      );

      await supabase.auth.updateUser(authUpdateData);
    } on AuthException catch (e) {
      throw Exception('Failed to update user metadata: ${e.message}');
    }
  }
}

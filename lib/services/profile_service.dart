import 'package:auth/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProfileService {
  static Future<UserModel?> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    final res = await supabase.auth.updateUser(
      UserAttributes(data: {'name': name, 'avatar_url': avatarUrl}),
    );

    if (res.user != null) {
      return UserModel.fromJson(res.user!.toJson());
    }
    return null;
  }
}

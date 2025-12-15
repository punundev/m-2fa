class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  UserModel({required this.id, required this.email, this.name, this.avatarUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['user_metadata']?['name'],
      avatarUrl: json['user_metadata']?['avatar_url'],
    );
  }
}

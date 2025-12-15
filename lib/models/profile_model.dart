class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? hashedPin;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.hashedPin,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      hashedPin: json['hashed_pin'],
    );
  }
}

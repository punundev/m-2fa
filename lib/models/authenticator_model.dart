class AuthenticatorAccount {
  final String id;
  final String userId;
  final String serviceName;
  final String email;
  final String secret;
  final DateTime createdAt;

  AuthenticatorAccount({
    required this.id,
    required this.userId,
    required this.serviceName,
    required this.email,
    required this.secret,
    required this.createdAt,
  });

  factory AuthenticatorAccount.fromMap(Map<String, dynamic> data) {
    return AuthenticatorAccount(
      id: data['id'].toString(),
      userId: data['user_id'],
      serviceName: data['service_name'],
      email: data['email'] ?? '',
      secret: data['secret'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

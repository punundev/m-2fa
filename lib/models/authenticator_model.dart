class AuthenticatorAccount {
  final String id;
  final String serviceName;
  final String email;
  final String secret;

  AuthenticatorAccount({
    required this.id,
    required this.serviceName,
    required this.email,
    required this.secret,
  });
}

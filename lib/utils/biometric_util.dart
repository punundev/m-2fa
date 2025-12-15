import 'package:local_auth/local_auth.dart';

class BiometricUtil {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkBiometricsAvailability() async {
    final bool canCheck = await auth.canCheckBiometrics;
    if (!canCheck) return false;

    final List<BiometricType> availableBiometrics = await auth
        .getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint or face to quickly unlock Nun Authenticator',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Biometric Error: $e');
      return false;
    }
  }
}

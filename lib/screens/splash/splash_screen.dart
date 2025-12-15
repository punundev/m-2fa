import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';

const String _appName = 'Nun Authenticator';
const String _logoAssetPath = 'assets/images/fingerprint.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStateAndProfile();
  }

  Future<void> _checkAuthStateAndProfile() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || _isNavigating) return;

    _isNavigating = true;

    final auth = context.read<AuthProvider>();

    final isLoggedInAndProfileReady = await auth.reloadUser();

    if (!mounted) return;

    if (isLoggedInAndProfileReady) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }

    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              _logoAssetPath,
              height: 100,
              width: 100,
              color: primaryColor,
              colorBlendMode: BlendMode.srcIn,
            ),

            const SizedBox(height: 24),

            Text(
              _appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

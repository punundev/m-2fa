import 'package:auth/controllers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String _appName = 'Nun Authenticator';
const String _googleAsset = 'assets/images/google.png';
const String _githubAsset = 'assets/images/github.png';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthProvider auth) async {
    setState(() => loading = true);
    try {
      await auth.login(emailController.text, passwordController.text);

      if (!mounted) return;
      if (auth.is2FARequired) {
        Navigator.pushReplacementNamed(context, '/2fa');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      String message = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ').last
          : 'An unknown error occurred.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    const double _textSize = 16.0;

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: MediaQuery.paddingOf(context).top + 60),

            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to your $_appName account',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email', Icons.email_outlined),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline,
                isPassword: true,
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 20),

            loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ElevatedButton(
                    onPressed: loading ? null : () => _handleLogin(auth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

            const SizedBox(height: 24),

            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('OR', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialLoginButton(
                  assetPath: _googleAsset,
                  onPressed: () async {
                    await _handleOAuthLogin(auth, 'google');
                  },
                  label: 'Google',
                ),
                _SocialLoginButton(
                  assetPath: _githubAsset,
                  onPressed: () async {
                    await _handleOAuthLogin(auth, 'github');
                  },
                  label: 'GitHub',
                ),
              ],
            ),

            const SizedBox(height: 40),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    fontSize: _textSize,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: _textSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Future<void> _handleOAuthLogin(AuthProvider auth, String provider) async {
  //   try {
  //     await auth.oauthLogin(provider);

  //     if (!mounted) return;
  //     if (auth.is2FARequired) {
  //       Navigator.pushReplacementNamed(context, '/2fa');
  //     } else {
  //       Navigator.pushReplacementNamed(context, '/home');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     String message = e.toString().contains('Exception:')
  //         ? e.toString().split('Exception: ').last
  //         : 'An unknown OAuth error occurred.';
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('OAuth failed: $message'),
  //         backgroundColor: Theme.of(context).colorScheme.error,
  //       ),
  //     );
  //   }
  // }

  Future<void> _handleOAuthLogin(AuthProvider auth, String provider) async {
    setState(() => loading = true);

    try {
      await auth.oauthLogin(provider);

      if (!mounted) return;

      if (auth.is2FARequired) {
        Navigator.pushReplacementNamed(context, '/2fa');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      String message = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ').last
          : 'An unknown OAuth error occurred.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OAuth failed: $message'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final String label;

  const _SocialLoginButton({
    required this.assetPath,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Image.asset(assetPath, height: 24.0),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

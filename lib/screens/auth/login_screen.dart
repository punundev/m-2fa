import 'package:auth/controllers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);
                      try {
                        await auth.login(
                          emailController.text,
                          passwordController.text,
                        );

                        if (!mounted) return;
                        if (auth.is2FARequired) {
                          Navigator.pushReplacementNamed(context, '/2fa');
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        if (mounted)
                          setState(
                            () => loading = false,
                          ); // fix control_flow_in_finally
                      }
                    },
                    child: const Text('Login'),
                  ),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text("Forgot Password?"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async => await auth.oauthLogin('google'),
              child: const Text('Login with Google'),
            ),
            ElevatedButton(
              onPressed: () async => await auth.oauthLogin('github'),
              child: const Text('Login with GitHub'),
            ),
          ],
        ),
      ),
    );
  }
}

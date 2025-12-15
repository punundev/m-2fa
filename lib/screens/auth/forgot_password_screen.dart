import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Constant for the App name
const String _appName = 'Nun Authenticator';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;
  // Use context.read<AuthProvider>() if the Supabase client is managed there,
  // but keeping your direct initialization for simplicity.
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Helper function for consistent input decoration styling
  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  // Logic to handle password reset request
  Future<void> _handlePasswordReset() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.resetPasswordForEmail(
        emailController.text,
        redirectTo: 'io.supabase.flutter://callback',
      );

      if (!mounted) return;

      // Success message and navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success! Check your email for the reset link.'),
          backgroundColor: Colors.green, // Use a success color
        ),
      );

      if (!mounted) return;
      // Navigate back to the Login screen after success
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // The Reset Password screen can be placed inside a back button
      // if using an AppBar, but since we removed the AppBar, we'll
      // add an explicit back button.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- 1. Top Spacing and Back Button ---
            SizedBox(height: MediaQuery.paddingOf(context).top + 20),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            SizedBox(height: 40),

            // --- 2. Branding and Instructions ---
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the email associated with your account and we will send you a link to reset your password.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // --- 3. Input Field ---
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                'Email Address',
                Icons.email_outlined,
                context,
              ),
            ),

            const SizedBox(height: 32),

            // --- 4. Send Reset Link Button ---
            loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ElevatedButton(
                    onPressed: loading ? null : _handlePasswordReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({Key? key}) : super(key: key);

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final emailController = TextEditingController();
//   bool loading = false;
//   final supabase = Supabase.instance.client;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Forgot Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 20),
//             loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () async {
//                       setState(() => loading = true);
//                       try {
//                         // Latest Supabase: resetPasswordForEmail returns void
//                         await supabase.auth.resetPasswordForEmail(
//                           emailController.text,
//                           redirectTo: 'io.supabase.flutter://callback',
//                         );

//                         if (!mounted) return;
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Check your email to reset your password.',
//                             ),
//                           ),
//                         );
//                         if (!mounted) return;
//                         Navigator.pop(context);
//                       } catch (e) {
//                         if (!mounted) return;
//                         ScaffoldMessenger.of(
//                           context,
//                         ).showSnackBar(SnackBar(content: Text(e.toString())));
//                       } finally {
//                         if (!mounted) return;
//                         setState(() => loading = false);
//                       }
//                     },
//                     child: const Text('Send Reset Link'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

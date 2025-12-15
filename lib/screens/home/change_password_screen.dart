import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';

final supabase = Supabase.instance.client;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    String errorMessage = 'Failed to update password.';
    final primaryColor = Theme.of(context).primaryColor;

    try {
      final userEmail = supabase.auth.currentUser?.email;
      final oldPassword = _oldPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      if (userEmail == null) {
        throw Exception('User email not found. Please re-login.');
      }

      final AuthResponse authRes = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: oldPassword,
      );

      if (authRes.user == null) {
        throw Exception('Invalid current password.');
      }

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      Provider.of<AuthProvider>(context, listen: false).reloadUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (errorMessage != 'Failed to update password.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Update your login credentials.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your current password.' : null,
                decoration: _inputDecoration(
                  'Current Password',
                  Icons.lock_outline,
                  primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a new password.' : null,
                decoration: _inputDecoration(
                  'New Password',
                  Icons.vpn_key_outlined,
                  primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Confirm your new password.';
                  if (value != _newPasswordController.text)
                    return 'Passwords do not match.';
                  return null;
                },
                decoration: _inputDecoration(
                  'Confirm New Password',
                  Icons.check_circle_outline,
                  primaryColor,
                ),
              ),

              const SizedBox(height: 40),

              _loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : ElevatedButton(
                      onPressed: _loading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save New Password',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  String label,
  IconData icon,
  Color primaryColor,
) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: primaryColor),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );
}

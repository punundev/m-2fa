import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      return;
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pop(context);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Update your login credentials.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: _inputDecoration(
                'Current Password',
                Icons.lock_outline,
                primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: _inputDecoration(
                'New Password',
                Icons.vpn_key_outlined,
                primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration(
                'Confirm New Password',
                Icons.check_circle_outline,
                primaryColor,
              ),
            ),

            const SizedBox(height: 40),

            _loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
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

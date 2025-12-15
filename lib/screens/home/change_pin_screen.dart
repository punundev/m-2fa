import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/core/secure_storage.dart';
import 'package:auth/utils/hashing.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  InputDecoration _pinInputDecoration(
    String label,
    Color primaryColor, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(isPassword ? Icons.lock_outline : Icons.pin),
      counterText: isPassword ? null : "",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Future<void> _handleChangePin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPassword = _currentPasswordController.text;
    final newPin = _newPinController.text;

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: authProvider.user!.email!,
        password: currentPassword,
      );

      if (response.user == null) {
        throw Exception('Incorrect current password.');
      }

      final pinHash = hashPin(newPin);

      await SecureStorage.savePin(newPin);

      await Supabase.instance.client
          .from('profiles')
          .update({'hashed_pin': pinHash})
          .eq('id', authProvider.user!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN updated successfully! (Security Verified)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN Code'),
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
                'Verify your identity and set a new quick access PIN.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: _pinInputDecoration(
                  'Current Account Password',
                  primaryColor,
                  isPassword: true,
                ),
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Please enter your current password for verification.';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),

              TextFormField(
                controller: _newPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: _pinInputDecoration(
                  'New 4-digit PIN',
                  primaryColor,
                ),
                validator: (value) {
                  if (value!.length != 4)
                    return 'PIN must be exactly 4 digits.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: _pinInputDecoration(
                  'Confirm New PIN',
                  primaryColor,
                ),
                validator: (value) {
                  if (value != _newPinController.text)
                    return 'PINs do not match.';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              _loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : ElevatedButton(
                      onPressed: _loading ? null : _handleChangePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save New PIN',
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

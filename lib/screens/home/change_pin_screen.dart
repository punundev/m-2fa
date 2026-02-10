import 'dart:ui';
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

  bool _isCurrentPasswordVisible = false;
  bool _isNewPinVisible = false;
  bool _isConfirmPinVisible = false;

  void _toggleVisibility(bool isPassword) {
    setState(() {
      if (isPassword) {
        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
      } else {
        _isNewPinVisible = !_isNewPinVisible;
        _isConfirmPinVisible = !_isConfirmPinVisible;
      }
    });
  }

  InputDecoration _glassInputDecoration({
    required String label,
    required bool isObscure,
    required bool isPassword,
    required VoidCallback toggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(
        isPassword ? Icons.lock_outline : Icons.pin,
        color: Colors.white70,
      ),
      counterText: "",
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white54, width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility : Icons.visibility_off,
          color: Colors.white70,
        ),
        onPressed: toggleVisibility,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.message}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Change PIN Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withBlue(150),
                  primaryColor.withRed(100).withBlue(200),
                  primaryColor.withRed(50),
                ],
              ),
            ),
          ),
          // Floating Orbs
          Positioned(
            top: 60,
            right: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Glass Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Icon(
                              Icons.dialpad_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Update PIN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verify your identity and set a new quick access PIN.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: !_isCurrentPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration: _glassInputDecoration(
                                label: 'Account Password',
                                isPassword: true,
                                isObscure: !_isCurrentPasswordVisible,
                                toggleVisibility: () => _toggleVisibility(true),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Verification required.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _newPinController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: !_isNewPinVisible,
                              style: const TextStyle(
                                color: Colors.white,
                                letterSpacing: 8,
                              ),
                              decoration: _glassInputDecoration(
                                label: 'New PIN',
                                isPassword: false,
                                isObscure: !_isNewPinVisible,
                                toggleVisibility: () =>
                                    _toggleVisibility(false),
                              ),
                              validator: (value) {
                                if (value!.length != 4) {
                                  return 'PIN must be 4 digits.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmPinController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: !_isConfirmPinVisible,
                              style: const TextStyle(
                                color: Colors.white,
                                letterSpacing: 8,
                              ),
                              decoration: _glassInputDecoration(
                                label: 'Confirm PIN',
                                isPassword: false,
                                isObscure: !_isConfirmPinVisible,
                                toggleVisibility: () =>
                                    _toggleVisibility(false),
                              ),
                              validator: (value) {
                                if (value != _newPinController.text) {
                                  return 'PINs mismatch.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            _loading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _loading
                                          ? null
                                          : _handleChangePin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Save New PIN',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:auth/l10n/app_localizations.dart';
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

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _passwordInputDecoration({
    required String label,
    required IconData icon,
    required Color primaryColor,
    required bool isObscure,
    required VoidCallback toggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility : Icons.visibility_off,
          color: primaryColor,
        ),
        onPressed: toggleVisibility,
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final T = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T.passwordMismatch),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    String errorMessage = T.updatePasswordFailed;

    try {
      final userEmail = supabase.auth.currentUser?.email;
      final oldPassword = _oldPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      if (userEmail == null) {
        throw Exception(T.userEmailNotFound);
      }

      final AuthResponse authRes = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: oldPassword,
      );

      if (authRes.user == null) {
        throw Exception(T.invalidCurrentPassword);
      }

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      Provider.of<AuthProvider>(context, listen: false).reloadUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T.passwordUpdateSuccess),
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
        if (errorMessage != T.updatePasswordFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final T = AppLocalizations.of(context)!;

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.changePasswordTitle),
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
                T.updateCredentialsText,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                validator: (value) =>
                    value!.isEmpty ? T.enterCurrentPassword : null,
                decoration: _passwordInputDecoration(
                  label: T.currentPasswordLabel,
                  icon: Icons.lock_outline,
                  primaryColor: primaryColor,
                  isObscure: !_isOldPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                validator: (value) =>
                    value!.isEmpty ? T.enterNewPassword : null,
                decoration: _passwordInputDecoration(
                  label: T.newPasswordLabel,
                  icon: Icons.vpn_key_outlined,
                  primaryColor: primaryColor,
                  isObscure: !_isNewPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value!.isEmpty) return T.confirmNewPassword;
                  if (value != _newPasswordController.text) {
                    return T.passwordsDoNotMatch;
                  }
                  return null;
                },
                decoration: _passwordInputDecoration(
                  label: T.confirmNewPasswordLabel,
                  icon: Icons.check_circle_outline,
                  primaryColor: primaryColor,
                  isObscure: !_isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
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
                      child: Text(
                        T.saveNewPassword,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

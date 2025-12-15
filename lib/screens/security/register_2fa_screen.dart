import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp/otp.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';

final supabase = Supabase.instance.client;

class Register2FAScreen extends StatefulWidget {
  const Register2FAScreen({super.key});

  @override
  State<Register2FAScreen> createState() => _Register2FAScreenState();
}

class _Register2FAScreenState extends State<Register2FAScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String _secret = '';
  String _qrCodeUrl = '';
  static const String _serviceName = 'NunAuthApp';

  @override
  void initState() {
    super.initState();
    _generateSecretAndQr();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _generateSecretAndQr() {
    final newSecret = OTP.randomSecret();
    setState(() {
      _secret = newSecret;

      final userEmail = supabase.auth.currentUser?.email ?? 'user@example.com';
      _qrCodeUrl =
          'otpauth://totp/$_serviceName:$userEmail?secret=$_secret&issuer=$_serviceName&algorithm=SHA1&digits=6&period=30';
    });
  }

  Future<void> _verifyAndSave2FA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final enteredCode = _codeController.text.trim();

    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final generatedCode = OTP.generateTOTPCodeString(
        _secret,
        currentTimestamp,
        length: 6,
        interval: 30,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      final isValid = generatedCode == enteredCode;

      if (!isValid) {
        throw Exception(
          'Invalid verification code. Please check your authenticator app and try again.',
        );
      }

      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'2fa_enabled': true, '2fa_secret': _secret}),
      );

      if (response.user == null) {
        throw Exception('Failed to save 2FA settings.');
      }

      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).reloadUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2FA setup complete! Please keep your secret safe.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth Error: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        String displayError = e.toString().contains('Exception:')
            ? e.toString().replaceFirst('Exception: ', '')
            : 'An unexpected error occurred.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(displayError), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final userEmail = supabase.auth.currentUser?.email ?? 'User Account';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup 2FA'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Step 1: Scan the QR Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Google Authenticator or a similar app to scan the code below for "$userEmail".',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QrImageView(
                  data: _qrCodeUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Step 2: Manual Key (If scanning fails)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                _secret,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Step 3: Verify the setup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter 6-digit Code from App',
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Code must be 6 digits.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            _loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ElevatedButton(
                    onPressed: _verifyAndSave2FA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enable 2FA and Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/utils/hashing.dart';
import 'package:auth/core/secure_storage.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();

  String _currentStep = 'SET_PIN';
  bool _isLoading = false;

  String? _newPin;

  Future<void> _savePin(String confirmedPin) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final hashedPin = hashPin(confirmedPin);

      await Supabase.instance.client
          .from('profiles')
          .update({'hashed_pin': hashedPin})
          .eq('id', userId);

      await SecureStorage.savePin(confirmedPin);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN successfully set!')));

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PIN: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePinInput(String value) {
    if (value.length == 4) {
      if (_currentStep == 'SET_PIN') {
        setState(() {
          _newPin = value;
          _currentStep = 'CONFIRM_PIN';
          _pinController.clear();
        });
      } else if (_currentStep == 'CONFIRM_PIN') {
        if (_newPin == value) {
          _savePin(value);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PINs do not match. Start over.')),
          );
          setState(() {
            _currentStep = 'SET_PIN';
            _newPin = null;
            _pinController.clear();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    String screenTitle = _currentStep == 'SET_PIN'
        ? 'Set Your New PIN'
        : 'Confirm Your New PIN';

    return Scaffold(
      appBar: AppBar(title: Text(screenTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                screenTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              if (_isLoading)
                CircularProgressIndicator(color: primaryColor)
              else
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _pinController,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, letterSpacing: 20.0),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: '----',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        letterSpacing: 10.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    onChanged: _handlePinInput,
                  ),
                ),

              const SizedBox(height: 20),
              Text(
                _currentStep == 'SET_PIN'
                    ? 'Enter your desired 4-digit PIN'
                    : 'Re-enter your 4-digit PIN to confirm',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

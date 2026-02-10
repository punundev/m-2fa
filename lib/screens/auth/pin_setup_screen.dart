import 'dart:ui';
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN successfully set!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PIN: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
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
            const SnackBar(
              content: Text('PINs do not match. Start over.'),
              behavior: SnackBarBehavior.floating,
            ),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
            left: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.pin_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            screenTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (_isLoading)
                            const CircularProgressIndicator(color: Colors.white)
                          else
                            SizedBox(
                              width: 220,
                              child: TextField(
                                controller: _pinController,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  letterSpacing: 20.0,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: '----',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.2),
                                    letterSpacing: 10.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.white54,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: _handlePinInput,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            _currentStep == 'SET_PIN'
                                ? 'Enter your desired 4-digit PIN'
                                : 'Re-enter your 4-digit PIN to confirm',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                        ],
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

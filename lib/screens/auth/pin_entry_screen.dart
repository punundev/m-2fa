import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/utils/hashing.dart';
import 'package:auth/utils/biometric_util.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController _pinController = TextEditingController();
  final BiometricUtil _biometricUtil = BiometricUtil();
  String? _remotePinHash;
  bool _loading = false;
  bool _hasUser = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadPinData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricsAndAuthenticate();
    });
  }

  Future<void> _checkAndLoadPinData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      if (mounted) setState(() => _hasUser = true);
      await _loadRemotePinHash(user.id);
    } else {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        });
      }
    }
  }

  Future<void> _loadRemotePinHash(String userId) async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('hashed_pin')
          .eq('id', userId)
          .limit(1)
          .single();

      if (!mounted) return;

      if (response.isNotEmpty && response['hashed_pin'] != null) {
        _remotePinHash = response['hashed_pin'] as String;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN not set up. Redirecting to setup.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/setup-pin');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading PIN data: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkBiometricsAndAuthenticate() async {
    final isAvailable = await _biometricUtil.checkBiometricsAvailability();
    if (!mounted) return;

    setState(() {
      _biometricsAvailable = isAvailable;
    });

    if (isAvailable) {
      final authenticated = await _biometricUtil.authenticate();
      if (!mounted) return;

      if (authenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _verifyPin(String enteredPin) {
    if (_remotePinHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN data not ready. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _pinController.clear();
      return;
    }

    final enteredPinHash = hashPin(enteredPin);
    _pinController.clear();

    if (enteredPinHash == _remotePinHash) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid PIN. Try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
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
                            Icons.lock_person_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nun Auth Lock',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          (_loading || !_hasUser)
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Column(
                                  children: [
                                    if (_biometricsAvailable) ...[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.fingerprint_rounded,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                        onPressed:
                                            _checkBiometricsAndAuthenticate,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Tap to use Biometrics',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            letterSpacing: 10.0,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.05,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.white54,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.length == 4) {
                                            _verifyPin(value);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Enter 4-digit PIN',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 48),
                                    TextButton(
                                      onPressed: () async {
                                        await Supabase.instance.client.auth
                                            .signOut();
                                        if (mounted) {
                                          Navigator.of(
                                            context,
                                          ).pushReplacementNamed('/login');
                                        }
                                      },
                                      child: const Text(
                                        'Use different account',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

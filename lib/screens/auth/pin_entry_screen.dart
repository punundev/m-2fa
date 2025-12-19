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
          ),
        );
        Navigator.of(context).pushReplacementNamed('/setup-pin');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PIN data: ${e.toString()}')),
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
        const SnackBar(content: Text('PIN data not ready. Try again.')),
      );
      _pinController.clear();
      return;
    }

    final enteredPinHash = hashPin(enteredPin);
    _pinController.clear();

    if (enteredPinHash == _remotePinHash) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid PIN. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Nun Auth Lock',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              (_loading || !_hasUser)
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : Column(
                      children: [
                        if (_biometricsAvailable)
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.fingerprint,
                                  size: 80,
                                  color: primaryColor,
                                ),
                                onPressed: _checkBiometricsAndAuthenticate,
                                tooltip: 'Authenticate with Biometrics',
                              ),
                              const SizedBox(height: 20),
                              const Text('Tap to use Fingerprint/Face ID'),
                              const SizedBox(height: 30),
                              const Text('--- OR ---'),
                              const SizedBox(height: 30),
                            ],
                          ),

                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _pinController,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              letterSpacing: 20.0,
                            ),
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
                                borderSide: BorderSide(
                                  color: primaryColor,
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
                        const SizedBox(height: 20),
                        const Text('Enter your 4-digit PIN'),
                        const SizedBox(height: 60),

                        TextButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (mounted) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            }
                          },
                          child: const Text('Log Out / Use different account'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

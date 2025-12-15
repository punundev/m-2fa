import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/utils/hashing.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _remotePinHash;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRemotePinHash();
  }

  Future<void> _loadRemotePinHash() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('hashed_pin')
          .eq('id', Supabase.instance.client.auth.currentUser!.id)
          .limit(1)
          .single();

      if (!mounted) return;

      if (response.isNotEmpty && response['hashed_pin'] != null) {
        _remotePinHash = response['hashed_pin'] as String;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN not set up. Please set your PIN.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PIN data: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _verifyPin(String enteredPin) {
    if (_remotePinHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN data not available. Check connection.'),
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

              _loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : Column(
                      children: [
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
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                          child: const Text('Login with Email/Password'),
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

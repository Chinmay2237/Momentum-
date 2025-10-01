import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MpinSetupScreen extends StatefulWidget {
  const MpinSetupScreen({Key? key}) : super(key: key);

  @override
  State<MpinSetupScreen> createState() => _MpinSetupScreenState();
}

class _MpinSetupScreenState extends State<MpinSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mpinController = TextEditingController();
  final _confirmMpinController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _mpinController.dispose();
    _confirmMpinController.dispose();
    super.dispose();
  }

  void _saveMpin() async {
    if (_formKey.currentState!.validate()) {
      await _secureStorage.write(key: 'mpin', value: _mpinController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up MPIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _mpinController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter 4-digit MPIN',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an MPIN';
                  }
                  if (value.length != 4) {
                    return 'MPIN must be 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmMpinController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm MPIN',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your MPIN';
                  }
                  if (value != _mpinController.text) {
                    return 'MPINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveMpin,
                child: const Text('Save MPIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

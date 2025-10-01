import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MpinAuthScreen extends StatefulWidget {
  final Function onAuthenticated;
  const MpinAuthScreen({Key? key, required this.onAuthenticated}) : super(key: key);

  @override
  State<MpinAuthScreen> createState() => _MpinAuthScreenState();
}

class _MpinAuthScreenState extends State<MpinAuthScreen> {
  final _mpinController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  void _verifyMpin() async {
    final storedMpin = await _secureStorage.read(key: 'mpin');
    if (storedMpin == _mpinController.text) {
      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid MPIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter MPIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mpinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter MPIN',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _verifyMpin,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}

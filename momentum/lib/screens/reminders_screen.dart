
import 'package:flutter/material.dart';
import 'package:momentum/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime!.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set a Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Reminder Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _selectedTime != null) {
                  final now = DateTime.now();
                  final scheduledTime = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
                  NotificationService().showNotification(
                    0,
                    _titleController.text,
                    'Your reminder is due!',
                    scheduledTime,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

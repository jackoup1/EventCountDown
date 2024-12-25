import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _dateError = false;

  Future<void> _saveEvent() async {
    setState(() {
      _dateError = _selectedDate == null;
    });

    if (_formKey.currentState!.validate() && !_dateError) {
      final eventName = _nameController.text.trim();
      final eventDate = _selectedDate!;

      print("Saving event: $eventName at $eventDate");

      try {
        await FirebaseFirestore.instance.collection('events').add({
          'name': eventName,
          'date': eventDate.toIso8601String(),
        });

        print("Event saved successfully!");
        Navigator.pop(context, true);
      } catch (e) {
        print("Error saving event: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      }
    } else {
      print("Form validation failed or date not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Event name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                _selectedDate == null
                    ? 'No date selected'
                    : 'Selected Date: ${_selectedDate.toString()}',
                style: TextStyle(
                  color: _dateError ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        _dateError = false;
                      });
                    }
                  }
                },
                child: Text('Select Date and Time'),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text('Save Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

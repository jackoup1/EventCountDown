import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController(); // For comments
  DateTime? _selectedDate;
  bool _showDateError = false;

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final eventName = _nameController.text.trim();
      final eventComment = _commentController.text.trim(); // Optional
      final eventDate = _selectedDate!;

      try {
        await FirebaseFirestore.instance.collection('events').add({
          'name': eventName,
          'date': eventDate.toIso8601String(),
          'comment': eventComment.isEmpty ? null : eventComment, // Add comment only if not empty
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      }
    } else {
      setState(() {
        _showDateError = _selectedDate == null;
      });
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
              if (_showDateError || _selectedDate != null)
                Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : 'Selected Date: ${_selectedDate.toString()}',
                  style: TextStyle(
                    color: _showDateError ? Colors.red : Colors.black,
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
                        _showDateError = false; // Reset error
                      });
                    }
                  }
                },
                child: Text('Select Date and Time'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Event Comments (optional)'),
                maxLines: 3,
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_event_screen.dart'; // Import your CreateEventScreen

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load events.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          final events = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] as String? ?? 'Unnamed Event';
            final date = DateTime.tryParse(data['date'] as String? ?? '') ??
                DateTime.now();
            return {
              'name': name,
              'date': date,
            };
          }).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final name = event['name'] as String;
              final date = event['date'] as DateTime;

              final now = DateTime.now();
              final difference = date.difference(now);
              final countdown = difference.isNegative
                  ? 'Event has passed'
                  : '${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m';

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  'Date: ${DateFormat.yMMMd().add_jm().format(date)}\nCountdown: $countdown',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Event added successfully!')),
            );
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
}

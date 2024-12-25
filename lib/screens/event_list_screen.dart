import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_event_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Event List')),
        body: Center(child: Text('Please log in to view your events.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Event List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('user_id', isEqualTo: user.uid) // Filter by the user's ID
            .snapshots(),
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
            final comment = data['comment'] as String? ?? '';
            final timeCreated = DateTime.tryParse(
                data['time_created'] as String? ?? '') ?? DateTime.now();
            return {
              'id': doc.id,
              'name': name,
              'date': date,
              'comment': comment,
              'timeCreated': timeCreated,
            };
          }).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final id = event['id'] as String;
              final name = event['name'] as String;
              final date = event['date'] as DateTime;
              final comment = event['comment'] as String;
              final timeCreated = event['timeCreated'] as DateTime;

              final now = DateTime.now();
              final difference = date.difference(now);
              final countdown = difference.isNegative
                  ? 'Event has passed'
                  : '${difference.inDays}d ${difference.inHours %
                  24}h ${difference.inMinutes % 60}m';

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  'Date: ${DateFormat.yMMMd().add_jm().format(
                      date)}\nCountdown: $countdown\nComment: $comment',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EventDetailsPopup(
                          eventId: id,
                          eventName: name,
                          eventComment: comment,
                          eventTimeCreated: timeCreated,
                          eventDate: date,
                        );
                      },
                    );
                  },
                  child: Text('Show Details'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
}

class EventDetailsPopup extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventComment;
  final DateTime eventTimeCreated;
  final DateTime eventDate;

  EventDetailsPopup({
    required this.eventId,
    required this.eventName,
    required this.eventComment,
    required this.eventTimeCreated,
    required this.eventDate,
  });

  @override
  _EventDetailsPopupState createState() => _EventDetailsPopupState();
}

class _EventDetailsPopupState extends State<EventDetailsPopup> {
  late TextEditingController _commentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.eventComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    final updatedComment = _commentController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'comment': updatedComment.isEmpty ? null : updatedComment,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeElapsed = now.difference(widget.eventTimeCreated).inMinutes;
    final totalDuration = widget.eventDate.difference(widget.eventTimeCreated).inMinutes;
     var progress = (timeElapsed / totalDuration) ;
    if(progress > 1)
      progress =1;

    final remainingTime = widget.eventDate.difference(now);
    final remainingDays = remainingTime.inDays;
    final remainingHours = remainingTime.inHours % 24;
    final remainingMinutes = remainingTime.inMinutes % 60;

    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      title: Center(
        child: Text(
          widget.eventName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            animation: true,
            animationDuration: 1000,
            radius: 100.0,
            lineWidth: 12.0,
            percent: progress,
            center: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress * 100), // Animate from 0 to progress * 100
              duration: Duration(milliseconds: 1000), // Match animation duration of the circular bar
              builder: (context, value, child) {
                return Text(
                  '${value.toInt()}%', // Display the animated value as an integer
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            progressColor: Colors.cyan,
            backgroundColor: Colors.white30,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 16),
          Text(
            remainingTime.inMinutes < 0
              ?'Event has passed':
             '$remainingDays d $remainingHours h $remainingMinutes m'
            ,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _commentController,
            enabled: _isEditing,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Event Comment',
              hintText: 'Add a comment...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _isEditing ? _saveComment : () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Text(_isEditing ? 'Save' : 'Edit Comment'),
              ),
              if (_isEditing)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _commentController.text = widget.eventComment;
                    });
                  },
                  child: Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class Event {
  final String id;
  final String name;
  final DateTime date;

  Event({required this.id, required this.name, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
    );
  }
}

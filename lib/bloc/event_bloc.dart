import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event.dart';

// BLoC: Events
abstract class EventEvent {}

class LoadEvents extends EventEvent {}

// BLoC: States
abstract class EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Event> events;
  EventLoaded(this.events);
}

class EventError extends EventState {}

// BLoC Implementation
class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(EventLoading()) {
    // Registering the event handler
    on<LoadEvents>((event, emit) async {
      emit(EventLoading());
      try {
        final response = await http.get(Uri.parse('<YOUR_API_ENDPOINT>'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final events = data.map((e) => Event.fromJson(e)).toList();
          emit(EventLoaded(events));
        } else {
          emit(EventError());
        }
      } catch (e) {
        emit(EventError());
      }
    });
  }
}

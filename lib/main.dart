// Import necessary packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/firebase_init.dart';
import 'bloc/event_bloc.dart';
import 'screens/event_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(EventCountdownApp());
}

class EventCountdownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => EventBloc()..add(LoadEvents()),
        child: EventListScreen(),
      ),
    );
  }
}

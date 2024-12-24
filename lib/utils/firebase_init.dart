import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDBsKEyGL5GoLIHq37ozhECjvQQlyjxofI",
      authDomain: "evecou-a286d.firebaseapp.com",
      projectId: "evecou-a286d",
      storageBucket: "evecou-a286d.firebasestorage.app",
      messagingSenderId: "808924373972",
      appId: "1:808924373972:web:6705d79737115b1eff2c41",
      measurementId: "G-6H9WDLTWCB"
    ),
  );
}
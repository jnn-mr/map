import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:map/firebase_options.dart';
import 'package:map/homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const webAPI());
}

class webAPI extends StatelessWidget {
  const webAPI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
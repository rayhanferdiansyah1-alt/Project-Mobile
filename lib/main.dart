import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPK WIP Bodi & Cat',
      home: Scaffold(
        appBar: AppBar(title: const Text('SPK WIP Bodi & Cat')),
        body: Center(
          child: Text(
            'Firebase terhubung: ${Firebase.app().options.projectId}',
          ),
        ),
      ),
    );
  }
}
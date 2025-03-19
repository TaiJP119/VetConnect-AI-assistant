import 'package:flutter/material.dart';

import 'ai assist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo version',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 56, 228, 128)),
        useMaterial3: false,
      ),
      home: const WasteSortScreen(),
    );
  }
}

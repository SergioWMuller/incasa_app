import 'package:flutter/material.dart';
import 'package:projeto_incasa_app/features/home/pages/home_page.dart';

void main() => runApp(const InCasaApp());

class InCasaApp extends StatelessWidget {
  const InCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InCasa App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

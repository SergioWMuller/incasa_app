import 'package:flutter/material.dart';
import 'package:projeto_incasa_app/features/home/pages/home_page.dart';
import 'package:projeto_incasa_app/data/supabase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SupabaseService.init();
  runApp(const InCasaApp());
}

class InCasaApp extends StatelessWidget {
  const InCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inCasa App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import '../services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.loadBaseUrl();
  runApp(const RecipeApp());
}


class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recepti',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

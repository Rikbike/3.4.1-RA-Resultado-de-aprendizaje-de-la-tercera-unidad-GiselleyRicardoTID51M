import 'package:flutter/material.dart';
import 'home.dart'; // Importa el home.dart

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(), // Usa la pantalla Home
      routes: {
      },
    );
  }
}

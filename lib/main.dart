import 'package:flutter/material.dart';
import 'abc_assessment.dart';


void main() {
  runApp(const HealixApp());
}

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healix - Combat Medic Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Healix',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ABCAssessmentScreen()),
                );
              },
              child: const Text('Start ABC Assessment'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Placeholder for additional features
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('More features coming soon!')),
                );
              },
              child: const Text('Other Features'),
            ),
          ],
        ),
      ),
    );
  }
}

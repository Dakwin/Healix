import 'package:flutter/material.dart';

void main() {
  runApp(HealixApp());
}

class HealixApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healix',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healix - Combat Medic Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Healix',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Placeholder for the ABC Guidance Screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ABC Guidance coming soon!')),
                );
              },
              child: Text('Start ABC Assessment'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Placeholder for additional features
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('More features coming soon!')),
                );
              },
              child: Text('Other Features'),
            ),
          ],
        ),
      ),
    );
  }
}

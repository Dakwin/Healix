import 'package:flutter/material.dart';

class ABCAssessmentScreen extends StatefulWidget {
  @override
  _ABCAssessmentScreenState createState() => _ABCAssessmentScreenState();
}

class _ABCAssessmentScreenState extends State<ABCAssessmentScreen> {
  int currentStep = 0;

  final List<String> steps = [
    "Airway: Ensure the airway is clear and open.",
    "Breathing: Check if the patient is breathing adequately.",
    "Circulation: Assess circulation and check for major bleeding."
  ];

  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assessment Completed!')),
        );
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ABC Assessment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              steps[currentStep],
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousStep,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: nextStep,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

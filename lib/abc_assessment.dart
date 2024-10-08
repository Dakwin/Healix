import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ABCAssessmentScreen extends StatefulWidget {
  const ABCAssessmentScreen({Key? key}) : super(key: key);

  @override
  ABCAssessmentScreenState createState() => ABCAssessmentScreenState();
}

class ABCAssessmentScreenState extends State<ABCAssessmentScreen> {
  int currentStep = 0;
  final List<String> steps = [
    "Airway: Ensure the airway is clear and open.",
    "Breathing: Check if the patient is breathing adequately.",
    "Circulation: Assess circulation and check for major bleeding."
  ];

  late stt.SpeechToText _speech; // Instance of SpeechToText
  bool _isListening = false;
  String _voiceInput = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

void _startListening() async {
  bool available = await _speech.initialize(
    onStatus: (val) => print('onStatus: $val'),
    onError: (val) => print('onError: $val'),
  );

  if (available) {
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (val) => setState(() {
        _voiceInput = val.recognizedWords;
      }),
      localeId: 'he-IL', // Specify Hebrew language code here
    );
  }
}

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
        _voiceInput = ''; // Clear voice input for next step
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment Completed!')),
        );
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
        _voiceInput = ''; // Clear voice input for previous step
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABC Assessment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              steps[currentStep],
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            if (_voiceInput.isNotEmpty)
              Text(
                'Voice Input: $_voiceInput',
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousStep,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: nextStep,
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}

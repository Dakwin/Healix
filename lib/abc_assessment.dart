import 'package:speech_to_text/speech_recognition_error.dart' as sre;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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

  DateTime? _lastCommandTime; // Timestamp for last command execution

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    if (!_isListening) {
      var status = await Permission.microphone.status;

      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => _onSpeechStatus(val),
          onError: (val) => _onSpeechError(val),
        );

        if (available) {
          setState(() {
            _isListening = true;
          });
          _speech.listen(
            onResult: (val) {
              final recognizedWords = val.recognizedWords.toLowerCase().trim();
              print('Recognized Words: "$recognizedWords"');

              // Handle commands for navigation on both interim and final results
              if (recognizedWords.contains('עבור')) {
                print('Command detected: "עבור"');

                // Use timestamp to prevent multiple executions
                _handleCommand(nextStep);
                return;
              } else if (recognizedWords.contains('אחורה')) {
                print('Command detected: "אחורה"');

                // Use timestamp to prevent multiple executions
                _handleCommand(previousStep);
                return;
              } else {
                print('No command detected.');
              }

              // Save the recognized input if it's not a command and it's a final result
              if (val.finalResult) {
                setState(() {
                  _voiceInput = recognizedWords;
                  print('Voice input updated to: $_voiceInput');
                });
              }
            },
            localeId: 'he-IL',
            listenMode: stt.ListenMode.dictation,
          );
        } else {
          print('Speech recognition not available');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Microphone permission is required to use this feature')),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Method to handle speech status changes
  void _onSpeechStatus(String status) {
    print('Speech status: $status');
    setState(() {
      _isListening = status == 'listening';
    });
  }

  // Method to handle speech recognition errors
  void _onSpeechError(sre.SpeechRecognitionError error) {
    setState(() {
      _isListening = false;
    });
    print('Speech recognition error: ${error.errorMsg}');
  }

  void _handleCommand(Function command) {
    final currentTime = DateTime.now();
    if (_lastCommandTime == null ||
        currentTime.difference(_lastCommandTime!) > Duration(seconds: 1)) {
      _lastCommandTime = currentTime;
      print('Executing command.');

      command(); // Execute the command
    } else {
      print('Command execution skipped due to cooldown.');
    }
  }

  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
        _voiceInput = ''; // Clear voice input for next step
        print('Moved to step $currentStep');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment Completed!')),
        );
        print('Assessment Completed!');
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
        _voiceInput = ''; // Clear voice input for previous step
        print('Moved back to step $currentStep');
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
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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

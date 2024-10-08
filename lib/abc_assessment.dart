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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


bool _commandCooldown = false; // Cooldown flag

void _startListening() async {
  var status = await Permission.microphone.request();

  if (status.isGranted) {
    bool available = await _speech.initialize(
      onStatus: (val) => _onSpeechStatus(val),
      onError: (val) => _onSpeechError(val as String),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (val) {
          final recognizedWords = val.recognizedWords.toLowerCase();

          if (recognizedWords.contains('עבור') && !_commandCooldown) {
            _handleCommand(() => nextStep());
          } else if (recognizedWords.contains('אחורה') && !_commandCooldown) {
            _handleCommand(() => previousStep());
          } else {
            setState(() {
              _voiceInput = recognizedWords;
            });
          }
        },
        localeId: 'he-IL', // Set language to Hebrew
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Microphone permission is required to use this feature')),
    );
  }
}

void _handleCommand(Function command) {
  setState(() {
    _commandCooldown = true; // Set the cooldown flag
  });

  command(); // Execute the command (nextStep or previousStep)

  // Set a cooldown period before allowing another command
  Timer(const Duration(seconds: 2), () {
    setState(() {
      _commandCooldown = false; // Reset the cooldown flag after 2 seconds
    });
  });
}



  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Method to handle speech status changes
  void _onSpeechStatus(String status) {
    setState(() {
      _isListening = status == 'listening';
    });
  }

  // Method to handle speech recognition errors
  void _onSpeechError(String error) {
    setState(() {
      _isListening = false;
    });
    print('Speech recognition error: $error');
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

import 'package:speech_to_text/speech_recognition_error.dart' as sre;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ABCAssessmentScreen extends StatefulWidget {
  const ABCAssessmentScreen({super.key});

  @override
  ABCAssessmentScreenState createState() => ABCAssessmentScreenState();
}

class ABCAssessmentScreenState extends State<ABCAssessmentScreen> {
  int currentStep = 0;

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'S: וודא בטיחות סביבתית לך ולמטופל.',
      'instructions': [
        'בדוק את הסביבה לאיומים פוטנציאליים.',
        'לבש ציוד מגן אישי.',
        'וודא שהמטופל נמצא במקום בטוח.',
      ],
    },
    {
      'title': 'A: פתח נתיב אוויר והסר חסימות.',
      'instructions': [
        'בדוק אם יש חסימה בנתיב האוויר.',
        'הטה את ראש המטופל לאחור כדי לפתוח את נתיב האוויר.',
        'הסר חפצים זרים מהפה או מהגרון.',
      ],
    },
    {
      'title': 'B: בדוק את הנשימה והבטח חמצון.',
      'instructions': [
        'הקשב ונטר את נשימת המטופל.',
        'השתמש במסכת חמצן במידת הצורך.',
        'התחל הנשמה מלאכותית אם אין נשימה.',
      ],
    },
    {
      'title': 'C: בדוק את הדופק וטפל בדימום.',
      'instructions': [
        'בדוק את הדופק במפרק כף היד או בצוואר.',
        'אם יש דימום, לחץ על האזור המדמם.',
        'השתמש בתחבושת לחץ או חסם עורקים במידת הצורך.',
      ],
    },
  ];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';

  DateTime? _lastCommandTime;

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

          stt.SpeechListenOptions options = stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          );

          _speech.listen(
            onResult: (val) {
              final recognizedWords =
                  val.recognizedWords.toLowerCase().trim();
              print('Recognized Words: "$recognizedWords"');

              if (recognizedWords.contains('עבור')) {
                print('Command detected: "עבור"');
                _handleCommand(nextStep);
                return;
              } else if (recognizedWords.contains('אחורה')) {
                print('Command detected: "אחורה"');
                _handleCommand(previousStep);
                return;
              } else {
                print('No command detected.');
              }

              if (val.finalResult) {
                setState(() {
                  _voiceInput = recognizedWords;
                  print('Voice input updated to: $_voiceInput');
                });
              }
            },
            localeId: 'he-IL',
            listenOptions: options,
          );
        } else {
          print('Speech recognition not available');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('דרושה הרשאת מיקרופון כדי להשתמש בתכונה זו'),
          ),
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

  void _onSpeechStatus(String status) {
    print('Speech status: $status');
    setState(() {
      _isListening = status == 'listening';
    });
  }

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

      _stopListening(); // Stop listening before executing the command

      command(); // Execute the command

      // Restart listening after a brief delay
      Future.delayed(Duration(milliseconds: 500), () {
        _startListening();
      });
    } else {
      print('Command execution skipped due to cooldown.');
    }
  }

  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
        _voiceInput = '';
        print('Moved to step $currentStep');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ההערכה הושלמה!')),
        );
        print('Assessment Completed!');
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
        _voiceInput = '';
        print('Moved back to step $currentStep');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = steps[currentStep];
    final String title = currentStepData['title'];
    final List<String> instructions = currentStepData['instructions'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'הערכה ABC',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: Row(
          children: [
            // Side bar (stepper) remains on the right side
            Container(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> step = entry.value;
                  String stepLetter = step['title'].split(':')[0]; // Extract 'S', 'A', 'B', 'C'

                  bool isActive = index == currentStep;
                  bool isCompleted = index < currentStep;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentStep = index;
                            _voiceInput = '';
                            print('Moved to step $currentStep via side bar');
                          });
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: isActive
                              ? Colors.blue
                              : isCompleted ? Colors.green : Colors.grey,
                          child: Text(
                            stepLetter,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (index != steps.length - 1)
                        Container(
                          height: 40,
                          width: 2,
                          color: Colors.grey,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            // Main content and buttons
            Expanded(
              child: Column(
                children: [
                  // Main content with scrolling
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: instructions.map((instruction) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      Expanded(
                                        child: Text(
                                          instruction,
                                          style: TextStyle(fontSize: 20.0),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20.0),
                            if (_voiceInput.isNotEmpty)
                              Text(
                                'קלט קולי: $_voiceInput',
                                style: const TextStyle(fontSize: 16.0),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buttons at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: previousStep,
                                child: const Text('אחורה'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: nextStep,
                                child: const Text('הבא'),
                              ),
                            ),
                          ],
                        ),
                        // Spacer to push 'התחל האזנה' to the bottom
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // 'התחל האזנה' button at the very bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _isListening ? _stopListening : _startListening,
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                      label: Text(
                        _isListening ? 'הפסק האזנה' : 'התחל האזנה',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
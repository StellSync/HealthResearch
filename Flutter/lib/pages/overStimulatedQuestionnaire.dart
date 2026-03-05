import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverStimulatedQuestionnaire extends StatefulWidget {
  const OverStimulatedQuestionnaire({super.key});

  @override
  State<OverStimulatedQuestionnaire> createState() => _OverStimulatedQuestionnaireState();
}

class _OverStimulatedQuestionnaireState extends State<OverStimulatedQuestionnaire> {
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};

  bool get _isNextEnabled {
    final answer = _answers[_currentIndex];
    final q = _questions[_currentIndex];
    final type = q['type'];

    // Choice-based types
    if (type == 'choice' || type == 'grid_2x2' || type == 'frequency_grid' || type == 'yes_no') {
      return answer != null;
    }

    // Numeric inputs
    if (type == 'number_1_10') {
      return answer is int && answer >= 1 && answer <= 10;
    }
    if (type == 'number_hours') {
      return answer is int && answer >= 0 && answer <= 24;
    }
    if (type == 'number_hours_6') {
      return answer is int && answer >= 0 && answer <= 6;
    }
    if (type == 'number_hours_24') {
      return answer is int && answer >= 0 && answer <= 24;
    }

    return false;
  }

  final List<Map<String, dynamic>> _questions = [
    // Q1: Noise Exposure
    {
      'title': 'How noisy is your daily environment?',
      'image': 'assets/images/question_noise.png',
      'type': 'grid_2x2',
      'key': 'Noise_Exposure',
      'range': '0-5',
      'options': [
        {'text': 'Very Quiet', 'value': 0},
        {'text': 'Quiet', 'value': 1},
        {'text': 'Moderate', 'value': 2},
        {'text': 'Loud', 'value': 3},
        {'text': 'Very Loud', 'value': 4},
        {'text': 'Extremely Loud', 'value': 5},
      ],
    },
    // Q2: Social Interaction
    {
      'title': 'On a scale of 1-10, how socially active are you?',
      'image': 'assets/images/question_social.jpg',
      'type': 'number_1_10',
      'key': 'Social_Interaction',
      'range': '0-10',
    },
    // Q3: Work Hours
    {
      'title': 'How many hours per week do you work?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours_24',
      'key': 'Work_Hours',
      'range': '0-24',
    },
    // Q4: Exercise Hours
    {
      'title': 'How many hours per day do you exercise?',
      'image': 'assets/images/question_exercise.jpg',
      'type': 'number_hours_6',
      'key': 'Exercise_Hours',
      'range': '0-6',
    },
    // Q5: Caffeine Intake
    {
      'title': 'How much caffeine do you consume daily?',
      'image': 'assets/images/question_caffeine.jpg',
      'type': 'grid_2x2',
      'key': 'Caffeine_Intake',
      'range': '0-5',
      'options': [
        {'text': 'None', 'value': 0},
        {'text': 'Less than 1 cup', 'value': 1},
        {'text': '1-2 cups', 'value': 2},
        {'text': '2-3 cups', 'value': 3},
        {'text': '3-4 cups', 'value': 4},
        {'text': 'More than 4 cups', 'value': 5},
      ],
    },
    // Q6: Multitasking Habit
    {
      'title': 'Do you have a multitasking habit?',
      'image': 'assets/images/question_work.png',
      'type': 'yes_no',
      'key': 'Multitasking_Habit',
      'range': '0-1',
    },
    // Q7: Meditation Habit
    {
      'title': 'Do you practice meditation regularly?',
      'image': 'assets/images/question_exercise2.jpg',
      'type': 'yes_no',
      'key': 'Meditation_Habit',
      'range': '0-1',
    },
    // Q8: Overthinking Score
    {
      'title': 'On a scale of 1-10, how much do you overthink?',
      'image': 'assets/images/question_stressed.jpg',
      'type': 'number_1_10',
      'key': 'Overthinking_Score',
      'range': '0-10',
    },
    // Q9: Headache Frequency
    {
      'title': 'How frequently do you experience headaches?',
      'image': 'assets/images/question_health.png',
      'type': 'grid_2x2',
      'key': 'Headache_Frequency',
      'range': '0-6',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 1},
        {'text': 'Sometimes', 'value': 2},
        {'text': 'Often', 'value': 3},
        {'text': 'Very Often', 'value': 4},
        {'text': 'Almost Daily', 'value': 5},
        {'text': 'Daily', 'value': 6},
      ],
    },
    // Q10: Sleep Quality
    {
      'title': 'How would you rate your sleep quality?',
      'image': 'assets/images/question_sleep.jpg',
      'type': 'choice',
      'key': 'Sleep_Quality',
      'range': '0-6',
      'options': [
        {'text': 'Very Poor', 'value': 0},
        {'text': 'Poor', 'value': 1},
        {'text': 'Fair', 'value': 2},
        {'text': 'Good', 'value': 3},
        {'text': 'Very Good', 'value': 4},
        {'text': 'Excellent', 'value': 5},
        {'text': 'Perfect', 'value': 6},
      ],
    },
    // Q11: Tech Usage Hours
    {
      'title': 'How many hours per day do you use technology (excluding work)?',
      'image': 'assets/images/question_tech.jpg',
      'type': 'number_hours_24',
      'key': 'Tech_Usage_Hours',
      'range': '0-24',
    },
  ];

  void _onChoiceSelected(dynamic value) {
    setState(() {
      // Handle both string and map options
      if (value is Map) {
        _answers[_currentIndex] = value['value'];
      } else {
        _answers[_currentIndex] = value;
      }
    });
  }

  void _onNumberChanged(String value, String type) {
    if (value.isEmpty) {
      _answers.remove(_currentIndex);
      setState(() {});
      return;
    }

    final n = int.tryParse(value);
    if (n != null) {
      if ((type == 'number_1_10' && n >= 1 && n <= 10) ||
          (type == 'number_hours' && n >= 0 && n <= 24) ||
          (type == 'number_hours_6' && n >= 0 && n <= 6) ||
          (type == 'number_hours_24' && n >= 0 && n <= 24)) {
        _answers[_currentIndex] = n;
      }
    }
    setState(() {});
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // Questionnaire completed - show all answers
      final allAnswers = _answersData;

      print('=== OVERSTIMULATED QUESTIONNAIRE COMPLETED ===');
      print('All Answers:');
      allAnswers.forEach((key, value) {
        print('  $key: $value');
      });
      print('==============================================');

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Questionnaire completed! 🎉'),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Get all answers in a structured format
  Map<String, dynamic> get _answersData {
    return {
      'Noise_Exposure': _answers[0] ?? 0,
      'Social_Interaction': _answers[1] ?? 0,
      'Work_Hours': _answers[2] ?? 0,
      'Exercise_Hours': _answers[3] ?? 0,
      'Caffeine_Intake': _answers[4] ?? 0,
      'Multitasking_Habit': _answers[5] == 'Yes' ? 1 : 0,
      'Meditation_Habit': _answers[6] == 'Yes' ? 1 : 0,
      'Overthinking_Score': _answers[7] ?? 0,
      'Headache_Frequency': _answers[8] ?? 0,
      'Sleep_Quality': _answers[9] ?? 0,
      'Tech_Usage_Hours': _answers[10] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Overstimulation Questionnaire',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (q['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          q['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      q['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildAnswerWidget(q),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isNextEnabled ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNextEnabled ? Colors.black : Colors.grey[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: _isNextEnabled ? 3 : 0,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(Map<String, dynamic> q) {
    final type = q['type'];
    final value = _answers[_currentIndex];

    // ── Yes/No Choice ──────────────────────────────────────────────
    if (type == 'yes_no') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Yes', 'No'].map((opt) {
          final selected = value == opt;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () => _onChoiceSelected(opt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected ? const Color(0xa3bdbaba) : Colors.grey[100],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }).toList(),
      );
    }

    // ── Grid 2x2 Selection ─────────────────────────────────────────
    if (type == 'grid_2x2' || type == 'frequency_grid') {
      final options = (q['options'] as List? ?? []);
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: options.map((option) {
          final optText = option is Map ? option['text'] : option;
          final optValue = option is Map ? option['value'] : option;
          final selected = value == optValue;

          return GestureDetector(
            onTap: () => _onChoiceSelected(option),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? const Color(0xA3BDBABA) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.black : Colors.grey[300]!,
                  width: selected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                optText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      );
    }

    // ── Regular Choice (vertical buttons) ───────────────────────────
    if (type == 'choice') {
      final options = (q['options'] as List? ?? []);
      return Column(
        children: options.map((option) {
          final optText = option is Map ? option['text'] : option;
          final optValue = option is Map ? option['value'] : option;
          final selected = value == optValue;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onChoiceSelected(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected ? const Color(0xa3bdbaba) : Colors.grey[100],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? Colors.black : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(optText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }).toList(),
      );
    }

    // ── Numeric inputs ──────────────────────────────────────────────
    String hint = 'Enter value';
    String label = '';
    int? maxLen = 3;
    List<TextInputFormatter> formatters = [
      FilteringTextInputFormatter.digitsOnly,
    ];

    if (type == 'number_1_10') {
      hint = '1–10';
      label = 'Enter a number between 1 and 10';
      maxLen = 2;
    } else if (type == 'number_hours_6') {
      hint = '0–6';
      label = 'Hours per day (0–6)';
      maxLen = 1;
    } else if (type == 'number_hours_24') {
      hint = '0–24';
      label = 'Hours per week (0–24)';
      maxLen = 2;
    }

    return Column(
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            keyboardType: TextInputType.number,
            key: ValueKey('numeric_input_$_currentIndex'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2.5),
              ),
            ),
            inputFormatters: [
              ...formatters,
              LengthLimitingTextInputFormatter(maxLen),
            ],
            onChanged: (v) => _onNumberChanged(v, type),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}

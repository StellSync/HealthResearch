import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StressQuestionnaireScreen extends StatefulWidget {
  const StressQuestionnaireScreen({super.key});

  @override
  State<StressQuestionnaireScreen> createState() => _StressQuestionnaireScreenState();
}

class _StressQuestionnaireScreenState extends State<StressQuestionnaireScreen> {
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};

  bool get _isNextEnabled {
    final answer = _answers[_currentIndex];
    final q = _questions[_currentIndex];
    final type = q['type'];

    if (type == 'choice' || type == 'frequency_grid') {
      return answer != null;
    }
    if (type == 'number_1_10') {
      return answer is int && answer >= 1 && answer <= 10;
    }
    if (type == 'number_hours') {
      return answer is int && answer >= 0 && answer <= 168;
    }
    if (type == 'number_hours_day') {
      return answer is int && answer >= 0 && answer <= 24;
    }
    if (type == 'gpa') {
      return answer is double && answer >= 0 && answer <= 4.0;
    }
    return false;
  }

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'How much caffeine do you take in a day?',
      'image': 'assets/images/question_caffeine.jpg',
      'type': 'frequency_grid',
      'options': [
        'Less than 1 Energy drinks/Coffees',
        'Less than 2 Energy drinks/Coffees',
        'Less than 5 Energy drinks/Coffees',
        'More than 5 Energy drinks/Coffees',
      ],
    },
    {
      'title': 'On a scale of 1-10, how stressed do you usually feel?',
      'image': 'assets/images/question_stressed.jpg',
      'type': 'number_1_10',
    },
    {
      'title': 'How noisy is your daily environment?',
      'image': 'assets/images/question_noise.png',
      'type': 'frequency_grid',
      'options': ['Very Quiet', 'Low Noise', 'Medium Noise', 'Very Noisy'],
    },
    {
      'title': 'On a scale of 1-10, how socially active are you?',
      'image': 'assets/images/question_social.jpg',
      'type': 'number_1_10',
    },
    {
      'title': 'How many hours per week do you work at a job?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours',
    },
    {
      'title': 'How many hours per week do you exercise?',
      'image': 'assets/images/question_exercise.jpg',
      'type': 'number_hours',
    },
    {
      'title': 'Over the past week, how often have you felt anxious, nervous, or on edge?',
      'image': 'assets/images/question_anxiety.jpg',
      'type': 'frequency_grid',
      'options': [
        'Rarely or not at all',
        'Occasionally',
        'Frequently',
        'Almost constantly',
      ],
    },
    {
      'title': 'How often have you felt sad, hopeless, or lost interest in things you usually enjoy?',
      'image': 'assets/images/question_sadness.jpg',
      'type': 'frequency_grid',
      'options': [
        'Not at all',
        'Sometimes',
        'Often',
        'Nearly every day',
      ],
    },
    {
      'title': 'How would you rate your sleep quality over the past week?',
      'image': 'assets/images/question_sleep.jpg',
      'type': 'choice',
      'options': ['Very Poor', 'Poor', 'Fair', 'Good', 'Excellent'],
    },
    {
      'title': 'On a typical day, how many total hours do you spend using technology (excluding academic classes)?',
      'image': 'assets/images/question_tech.jpg',
      'type': 'number_hours_day', // ← changed as requested
    },
    {
      'title': 'Current Grade Point Average (GPA)',
      'image': 'assets/images/question_gpa.jpg',
      'type': 'gpa',
    },
    {
      'title': 'Grade Point Average from the previous academic term',
      'image': 'assets/images/question_gpa_2.png',
      'type': 'gpa',
    },
  ];

  void _onChoiceSelected(dynamic value) {
    setState(() {
      _answers[_currentIndex] = value;
    });
  }

  void _onNumberChanged(String value, String type) {
    if (value.isEmpty) {
      _answers.remove(_currentIndex);
      setState(() {});
      return;
    }

    if (type == 'number_1_10' || type == 'number_hours' || type == 'number_hours_day') {
      final n = int.tryParse(value);
      if (n != null) {
        if ((type == 'number_1_10' && n >= 1 && n <= 10) ||
            (type == 'number_hours' && n >= 0 && n <= 168) ||
            (type == 'number_hours_day' && n >= 0 && n <= 24)) {
          _answers[_currentIndex] = n;
        }
      }
    } else if (type == 'gpa') {
      final n = double.tryParse(value);
      if (n != null && n >= 0 && n <= 4.0) {
        _answers[_currentIndex] = n;
      }
    }

    setState(() {});
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionnaire completed! 🎉')),
      );
    }
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
          'Questionnaire',
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
                    '${(progress * 100).toStringAsFixed(0)}% Pending...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (q['image'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Image.asset(
                          q['image'],
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        ),
                      ),
                    Text(
                      q['title'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
                      textAlign: TextAlign.center,
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
                    backgroundColor: _isNextEnabled ? Color(0xff000000) : Colors.grey[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: _isNextEnabled ? 3 : 0,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
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

    // ── Frequency Grid (2×2) ───────────────────────────────────────
    if (type == 'frequency_grid') {
      final options = q['options'] as List<String>;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: options.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          final selected = value == opt;
          return GestureDetector(
            onTap: () => _onChoiceSelected(opt),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? Color(0xa3bdbaba) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Color(0xff000000)! : Colors.grey[300]!,
                  width: selected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w600,
                  color:  Colors.black87,
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
      return Column(
        children: (q['options'] as List<String>).map((opt) {
          final selected = value == opt;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onChoiceSelected(opt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected ? Color(0xa3bdbaba) : Colors.grey[100],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 16)),
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
    } else if (type == 'number_hours') {
      hint = '0–168';
      label = 'Hours per week (0–168)';
    } else if (type == 'number_hours_day') {
      hint = '0–24';
      label = 'Hours per day (0–24)';
    } else if (type == 'gpa') {
      hint = '0.0–4.0';
      label = 'GPA (0.0 to 4.0)';
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ];
      maxLen = 4;
    }

    return Column(
      children: [
        SizedBox(
          width: 500,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            key: ValueKey('numeric_input_$_currentIndex'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2.5),
              ),
            ),
            inputFormatters: [
              ...formatters,
              LengthLimitingTextInputFormatter(maxLen),
            ],
            controller: null,
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
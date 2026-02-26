import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhysStress extends StatefulWidget {
  const PhysStress({super.key});

  @override
  State<PhysStress> createState() => _PhysStressState();
}

class _PhysStressState extends State<PhysStress> {
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};

  bool get _isNextEnabled {
    final answer = _answers[_currentIndex];
    final q = _questions[_currentIndex];
    final type = q['type'];

    if (type == 'choice' || type == 'grid_2x2') {
      return answer != null;
    }
    if (type == 'number_minutes_week') {
      return answer is int && answer >= 0 && answer <= 1440; // max 24*60 minutes
    }
    if (type == 'number_hours_week') {
      return answer is int && answer >= 0 && answer <= 168;
    }
    return false;
  }

  final List<Map<String, dynamic>> _questions = [
    // Q1
    {
      'title': 'How many minutes per week do you usually exercise?',
      'image': 'assets/images/question_exercise2.jpg',
      'type': 'number_minutes_week',
    },
    // Q2
    {
      'title': 'How would you rate your overall health?',
      'image': 'assets/images/question_health.png', // Use a health-related image
      'type': 'grid_2x2',
      'options': ['Excellent', 'Good', 'Fair', 'Poor'],
    },
    // Q3
    {
      'title': 'In the past two weeks, how often have you felt emotionally distressed?',
      'image': 'assets/images/question_sadness.jpg',
      'type': 'grid_2x2',
      'options': [
        'Not at all',
        'Several days',
        'Over half the days',
        'Nearly every day',
      ],
    },
    // Q4
    {
      'title': 'When stressed, how often do you try to manage your emotions?',
      'image': 'assets/images/question_emotions.png',
      'type': 'grid_2x2',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
    },
    // Q5
    {
      'title': 'When stressed, how often do you try to solve the problem directly?',
      'image': 'assets/images/question_problem_solving.jpg',
      'type': 'grid_2x2',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
    },
    // Q6
    {
      'title': 'Do you work part-time?',
      'image': 'assets/images/question_parttime.jpeg',
      'type': 'choice',
      'options': ['Yes', 'No'],
    },
    // Q7
    {
      'title': 'How often do you have someone to talk to when you need support?',
      'image': 'assets/images/question_support.png',
      'type': 'grid_2x2',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
    },
    // Q8
    {
      'title': 'How often do you use healthy strategies to cope (exercise, meditation, sleep)?',
      'image': 'assets/images/question_coping.png',
      'type': 'grid_2x2',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
    },
    // Q9
    {
      'title': 'What is the highest education level completed by your parent or guardian?',
      'image': 'assets/images/question_education.jpg',
      'type': 'grid_2x2',
      'options': [
        'Less than high school',
        'High school',
        "Bachelor's",
        'Postgraduate',
      ],
    },
    // Q10
    {
      'title': 'How many hours per week do you work at a job?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours_week',
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

    final n = int.tryParse(value);
    if (n != null) {
      if ((type == 'number_minutes_week' && n >= 0 && n <= 1440) ||
          (type == 'number_hours_week' && n >= 0 && n <= 168)) {
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
            // Progress Bar
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
                    // Illustration Image
                    if (q['image'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Image.asset(
                          q['image'],
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        ),
                      ),

                    // Question Title
                    Text(
                      q['title'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Answer Widget
                    _buildAnswerWidget(q),
                  ],
                ),
              ),
            ),

            // Next / Finish Button
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

    // ── 2x2 Grid (most questions) ───────────────────────────────────
    if (type == 'grid_2x2' || type == 'frequency_grid') {
      final options = q['options'] as List<String>;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2, // taller boxes
        children: options.map((opt) {
          final selected = value == opt;
          return GestureDetector(
            onTap: () => _onChoiceSelected(opt),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? const Color(0xA3BDBABA) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.black : Colors.grey[300]!,
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

    // ── Numeric Input (minutes or hours) ────────────────────────────
    String hint = 'Enter value';
    String label = '';
    int? maxLen = 4;
    List<TextInputFormatter> formatters = [
      FilteringTextInputFormatter.digitsOnly,
    ];

    if (type == 'number_minutes_week') {
      hint = '0–1440';
      label = 'Minutes per week';
    } else if (type == 'number_hours_week') {
      hint = '0–168';
      label = 'Hours per week';
    }

    return Column(
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            key: ValueKey('numeric_input_$_currentIndex'),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
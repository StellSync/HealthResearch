import 'package:flutter/material.dart';
import 'package:health_research/services/StressApiService.dart';

class StressCheckFlow extends StatefulWidget {
  final String userId;

  const StressCheckFlow({
    required this.userId,
    super.key,
  });

  @override
  State<StressCheckFlow> createState() => _StressCheckFlowState();
}

class _StressCheckFlowState extends State<StressCheckFlow> {
  final StressApiService _apiService = StressApiService();

  int _currentStep =
      0; // 0: fetch features, 1: phys stress, 2: stress questionnaire, 3: result
  bool _isLoading = false;
  String? _errorMessage;

  // User features from database
  Map<String, dynamic>? _userFeatures;
  double? _heartRate;
  double? _screenTime;

  // Prediction result
  Map<String, dynamic>? _predictionResult;

  @override
  void initState() {
    super.initState();
    _fetchUserFeatures();
  }

  Future<void> _fetchUserFeatures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final features = await _apiService.getUserFeatures(widget.userId);

      setState(() {
        _userFeatures = features;
        _heartRate = (features['Heart_Rate'] as num?)?.toDouble() ?? 0.0;
        _screenTime = (features['Screen_Time'] as num?)?.toDouble() ?? 0.0;
        _currentStep = 1; // Move to physStress questionnaire
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user features: $e';
        _isLoading = false;
      });
    }
  }

  void _onPhysStressCompleted(Map<int, dynamic> answers) {
    setState(() {
      _currentStep = 2; // Move to stress questionnaire
    });
  }

  Future<void> _onStressQuestionnaireCompleted(
      Map<String, dynamic> answersData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get age from user features
      final age = (_userFeatures?['Age'] as num?)?.toDouble() ?? 0.0;

      // Get Work_Hours from answers data
      final workHours = (answersData['Work_Hours'] as num?)?.toDouble() ?? 0.0;

      // Get Social_Interaction from answers data
      final socialInteraction =
          (answersData['Social_Interaction'] as num?)?.toDouble() ?? 0.0;

      // Get Noise_Exposure from answers data
      final noiseExposure =
          (answersData['Noise_Exposure'] as num?)?.toDouble() ?? 0.0;

      // Build payload for stress prediction
      final payload = {
        'Age': age,
        'Heart_Rate': _heartRate ?? 0.0,
        'Work_Hours': workHours,
        'Screen_Time': _screenTime ?? 0.0,
        'Social_Interaction': socialInteraction,
        'Noise_Exposure': noiseExposure,
      };

      // Call the predict stress endpoint
      final result = await _apiService.predictStress(widget.userId, payload);

      setState(() {
        _predictionResult = result;
        _currentStep = 3; // Move to result screen
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error submitting questionnaire: $e';
        _isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _currentStep = 0;
      _errorMessage = null;
      _userFeatures = null;
      _predictionResult = null;
    });
    _fetchUserFeatures();
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading && _currentStep != 3) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Stress Check'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (_errorMessage != null && _currentStep == 0) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Stress Check'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Step 1: Physical Stress Questionnaire
    if (_currentStep == 1) {
      return _PhysStressWrapper(
        onCompleted: _onPhysStressCompleted,
      );
    }

    // Step 2: Stress Questionnaire
    if (_currentStep == 2) {
      return _StressQuestionnaireWrapper(
        onCompleted: _onStressQuestionnaireCompleted,
      );
    }

    // Step 3: Result Screen
    if (_currentStep == 3) {
      return _ResultScreen(
        result: _predictionResult,
        userFeatures: _userFeatures,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return const SizedBox.shrink();
  }
}

class _PhysStressWrapper extends StatefulWidget {
  final Function(Map<int, dynamic>) onCompleted;

  const _PhysStressWrapper({
    required this.onCompleted,
  });

  @override
  State<_PhysStressWrapper> createState() => _PhysStressWrapperState();
}

class _PhysStressWrapperState extends State<_PhysStressWrapper> {
  @override
  Widget build(BuildContext context) {
    return _PhysStressModified(
      onCompleted: widget.onCompleted,
    );
  }
}

class _StressQuestionnaireWrapper extends StatefulWidget {
  final Function(Map<String, dynamic>) onCompleted;

  const _StressQuestionnaireWrapper({
    required this.onCompleted,
  });

  @override
  State<_StressQuestionnaireWrapper> createState() =>
      _StressQuestionnaireWrapperState();
}

class _StressQuestionnaireWrapperState
    extends State<_StressQuestionnaireWrapper> {
  @override
  Widget build(BuildContext context) {
    return _StressQuestionnaireModified(
      onCompleted: widget.onCompleted,
    );
  }
}

// Modified version of PhysStress that returns answers instead of just finishing
class _PhysStressModified extends StatefulWidget {
  final Function(Map<int, dynamic>) onCompleted;

  const _PhysStressModified({
    required this.onCompleted,
  });

  @override
  State<_PhysStressModified> createState() => _PhysStressModifiedState();
}

class _PhysStressModifiedState extends State<_PhysStressModified> {
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
      return answer is int && answer >= 0 && answer <= 1440;
    }
    if (type == 'number_hours_week') {
      return answer is int && answer >= 0 && answer <= 168;
    }
    if (type == 'number_bmi') {
      return answer is double && answer > 0 && answer < 100;
    }
    return false;
  }

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What is your BMI?',
      'image': 'assets/images/question_health.png',
      'type': 'number_bmi',
      'key': 'bmi',
    },
    {
      'title': 'How many minutes per week do you usually exercise?',
      'image': 'assets/images/question_exercise2.jpg',
      'type': 'number_minutes_week',
      'key': 'physact',
    },
    {
      'title': 'How would you rate your overall health?',
      'image': 'assets/images/question_health.png',
      'type': 'grid_2x2',
      'key': 'health',
      'options': [
        {'text': 'Poor', 'value': 0},
        {'text': 'Fair', 'value': 1},
        {'text': 'Good', 'value': 2},
        {'text': 'Very Good', 'value': 3},
        {'text': 'Excellent', 'value': 4},
      ],
    },
    {
      'title':
          'In the past two weeks, how often have you felt emotionally distressed?',
      'image': 'assets/images/question_sadness.jpg',
      'type': 'grid_2x2',
      'key': 'psyt',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 1},
        {'text': 'Sometimes', 'value': 2},
        {'text': 'Often', 'value': 3},
        {'text': 'Always', 'value': 4},
      ],
    },
    {
      'title': 'When stressed, how often do you try to manage your emotions?',
      'image': 'assets/images/question_emotions.png',
      'type': 'grid_2x2',
      'key': 'cop_e',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 5},
        {'text': 'Sometimes', 'value': 10},
        {'text': 'Often', 'value': 15},
        {'text': 'Always', 'value': 20},
      ],
    },
    {
      'title':
          'When stressed, how often do you try to solve the problem directly?',
      'image': 'assets/images/question_problem_solving.jpg',
      'type': 'grid_2x2',
      'key': 'cop_p',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 5},
        {'text': 'Sometimes', 'value': 10},
        {'text': 'Often', 'value': 15},
        {'text': 'Always', 'value': 20},
      ],
    },
    {
      'title': 'How often do you use healthy strategies to cope?',
      'image': 'assets/images/question_coping.png',
      'type': 'grid_2x2',
      'key': 'cop_h',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 5},
        {'text': 'Sometimes', 'value': 10},
        {'text': 'Often', 'value': 15},
        {'text': 'Always', 'value': 20},
      ],
    },
    {
      'title': 'Do you work part-time?',
      'image': 'assets/images/question_parttime.jpeg',
      'type': 'choice',
      'key': 'part',
      'options': [
        {'text': 'No', 'value': 0},
        {'text': 'Yes', 'value': 1},
      ],
    },
    {
      'title':
          'How often do you have someone to talk to when you need support?',
      'image': 'assets/images/question_support.png',
      'type': 'grid_2x2',
      'key': 'socsup',
      'options': [
        {'text': 'Never', 'value': 0},
        {'text': 'Rarely', 'value': 2},
        {'text': 'Sometimes', 'value': 5},
        {'text': 'Often', 'value': 7},
        {'text': 'Always', 'value': 10},
      ],
    },
    {
      'title':
          'What is the highest education level completed by your parent or guardian?',
      'image': 'assets/images/question_education.jpg',
      'type': 'grid_2x2',
      'key': 'educ_par',
      'options': [
        {'text': 'Less than high school', 'value': 0},
        {'text': 'High school', 'value': 1},
        {'text': 'Diploma', 'value': 2},
        {'text': "Bachelor's", 'value': 3},
        {'text': 'Postgraduate', 'value': 4},
        {'text': "Don't know", 'value': 5},
      ],
    },
    {
      'title': 'How many hours per week do you work at a job?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours_week',
      'key': 'jobhours',
    },
  ];

  void _onChoiceSelected(dynamic value) {
    setState(() {
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

    if (type == 'number_bmi') {
      final n = double.tryParse(value);
      if (n != null && n > 0 && n < 100) {
        _answers[_currentIndex] = n;
      }
    } else if (type == 'number_minutes_week') {
      final n = int.tryParse(value);
      if (n != null && n >= 0 && n <= 1440) {
        _answers[_currentIndex] = n;
      }
    } else if (type == 'number_hours_week') {
      final n = int.tryParse(value);
      if (n != null && n >= 0 && n <= 168) {
        _answers[_currentIndex] = n;
      }
    }

    setState(() {});
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      widget.onCompleted(_answers);
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
          'Physical Stress Assessment',
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
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey),
                        ),
                      ),
                    Text(
                      q['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
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
                    backgroundColor:
                        _isNextEnabled ? Colors.black : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isNextEnabled ? 3 : 0,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next'
                        : 'Continue to Stress Assessment',
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

    if (type == 'grid_2x2') {
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
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Text(
                optText,
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
                  backgroundColor:
                      selected ? const Color(0xa3bdbaba) : Colors.grey[100],
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
                child: Text(optText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (type == 'number_bmi') {
      return Column(
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              key: ValueKey('bmi_input_$_currentIndex'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: 'kg/m²',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.5,
                  ),
                ),
              ),
              onChanged: (v) => _onNumberChanged(v, type),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Body Mass Index',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      );
    }

    String hint = 'Enter value';
    String label = '';

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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.5,
                ),
              ),
            ),
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

// Modified version of StressQuestionnaireScreen that returns answers
class _StressQuestionnaireModified extends StatefulWidget {
  final Function(Map<String, dynamic>) onCompleted;

  const _StressQuestionnaireModified({
    required this.onCompleted,
  });

  @override
  State<_StressQuestionnaireModified> createState() =>
      _StressQuestionnaireModifiedState();
}

class _StressQuestionnaireModifiedState
    extends State<_StressQuestionnaireModified> {
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};

  // Include only the questions needed for the prediction model
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'How noisy is your daily environment?',
      'image': 'assets/images/question_noise.png',
      'type': 'frequency_grid',
      'options': ['Very Quiet', 'Low Noise', 'Medium Noise', 'Very Noisy'],
      'key': 'Noise_Exposure',
    },
    {
      'title': 'On a scale of 1-10, how socially active are you?',
      'image': 'assets/images/question_social.jpg',
      'type': 'number_1_10',
      'key': 'Social_Interaction',
    },
    {
      'title': 'How many hours per day do you work at a job?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours_day',
      'key': 'Work_Hours',
    },
    {
      'title': 'How many hours per day do you exercise?',
      'image': 'assets/images/question_exercise.jpg',
      'type': 'number_hours_day',
      'key': 'Exercise_Hours',
    },
  ];

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
    if (type == 'number_hours_day') {
      return answer is int && answer >= 0 && answer <= 24;
    }
    return false;
  }

  Map<String, dynamic> get _answersData {
    return {
      'Noise_Exposure': _mapFrequencyGridAnswer(_answers[0], 4) ?? 0,
      'Social_Interaction': _answers[1] ?? 0,
      'Work_Hours': _answers[2] ?? 0,
      'Exercise_Hours': _answers[3] ?? 0,
    };
  }

  int? _mapFrequencyGridAnswer(dynamic answer, int maxValue) {
    if (answer == null) return null;
    if (maxValue == 4) {
      const options = ['Very Quiet', 'Low Noise', 'Medium Noise', 'Very Noisy'];
      final index = options.indexOf(answer.toString());
      return index >= 0 ? index : null;
    }
    return null;
  }

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

    if (type == 'number_1_10') {
      final n = int.tryParse(value);
      if (n != null && n >= 1 && n <= 10) {
        _answers[_currentIndex] = n;
      }
    } else if (type == 'number_hours_day') {
      final n = int.tryParse(value);
      if (n != null && n >= 0 && n <= 24) {
        _answers[_currentIndex] = n;
      }
    }

    setState(() {});
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      widget.onCompleted(_answersData);
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
          'Stress Questionnaire',
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
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey),
                        ),
                      ),
                    Text(
                      q['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
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
                    backgroundColor:
                        _isNextEnabled ? Colors.black : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isNextEnabled ? 3 : 0,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next'
                        : 'Get Prediction',
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

    if (type == 'frequency_grid') {
      final options = (q['options'] as List? ?? []);
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: options.map((option) {
          final selected = value == option;

          return GestureDetector(
            onTap: () => _onChoiceSelected(option),
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
                option,
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

    if (type == 'number_1_10' || type == 'number_hours_day') {
      return Column(
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              key: ValueKey('numeric_input_$_currentIndex'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.5,
                  ),
                ),
              ),
              onChanged: (v) => _onNumberChanged(v, type),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            type == 'number_1_10' ? 'Scale: 1-10' : 'Hours: 0-24',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? userFeatures;
  final VoidCallback onClose;

  const _ResultScreen({
    this.result,
    this.userFeatures,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = result?['prediction'] as int? ?? 0;
    final probability = result?['probability'] as double? ?? 0.0;
    final isStressed = prediction == 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Stress Assessment Result'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isStressed ? Colors.red[100] : Colors.green[100],
                  ),
                  child: Center(
                    child: Icon(
                      isStressed ? Icons.warning : Icons.check_circle,
                      size: 60,
                      color: isStressed ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isStressed ? 'You Are Stressed' : 'You Are Not Stressed',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isStressed ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Confidence: ${(probability * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Status',
                        isStressed ? 'Stressed' : 'Not Stressed',
                        isStressed ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Confidence',
                          '${(probability * 100).toStringAsFixed(1)}%'),
                      const SizedBox(height: 12),
                      if (userFeatures != null &&
                          userFeatures!['Heart_Rate'] != null)
                        _buildDetailRow(
                          'Heart Rate',
                          '${(userFeatures!['Heart_Rate'] as num).toStringAsFixed(1)} bpm',
                        ),
                      if (userFeatures != null &&
                          userFeatures!['Sleep_Hours'] != null)
                        _buildDetailRow(
                          'Sleep Hours',
                          '${(userFeatures!['Sleep_Hours'] as num).toStringAsFixed(1)} hrs',
                        ),
                      if (userFeatures != null &&
                          userFeatures!['Screen_Time'] != null)
                        _buildDetailRow(
                          'Screen Time',
                          '${(userFeatures!['Screen_Time'] as num).toStringAsFixed(1)} hrs',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

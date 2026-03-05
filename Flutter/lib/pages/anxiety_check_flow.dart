import 'package:flutter/material.dart';
import 'package:health_research/services/StressApiService.dart';

class AnxietyCheckFlow extends StatefulWidget {
  final String userId;

  const AnxietyCheckFlow({
    required this.userId,
    super.key,
  });

  @override
  State<AnxietyCheckFlow> createState() => _AnxietyCheckFlowState();
}

class _AnxietyCheckFlowState extends State<AnxietyCheckFlow> {
  final StressApiService _apiService = StressApiService();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // User features from database
  Map<String, dynamic>? _userFeatures;
  double? _sleepHours;
  double? _screenTime;
  double? _age;

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
        _sleepHours = (features['Sleep_Hours'] as num?)?.toDouble() ?? 0.0;
        _screenTime = (features['Screen_Time'] as num?)?.toDouble() ?? 0.0;
        _age = (features['Age'] as num?)?.toDouble() ?? 0.0;
        _currentStep = 1; // Move to anxiety questionnaire
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user features: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onAnxietyQuestionnaireCompleted(
      Map<String, dynamic> answersData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract answer values
      final techUsageHours =
          (answersData['Tech_Usage_Hours'] as num?)?.toDouble() ?? 0.0;
      final workHours = (answersData['Work_Hours'] as num?)?.toDouble() ?? 0.0;
      final exerciseHours =
          (answersData['Exercise_Hours'] as num?)?.toDouble() ?? 0.0;
      final socialInteraction =
          (answersData['Social_Interaction'] as num?)?.toDouble() ?? 0.0;
      final noiseExposure =
          (answersData['Noise_Exposure'] as num?)?.toDouble() ?? 0.0;

      // Build payload for anxiety prediction according to API specification
      final payload = {
        'Tech_Usage_Hours': techUsageHours,
        'Sensory_Sensitivity':
            (answersData['Sensory_Sensitivity'] as num?)?.toDouble() ?? 0.0,
        'num_missing': 0.0,
        'Multitasking_Habit':
            (answersData['Multitasking_Habit'] as num?)?.toDouble() ?? 0.0,
        'Sleep_Hours_div_Screen_Time':
            _sleepHours != null && _screenTime != null
                ? _sleepHours! / (_screenTime! + 0.001)
                : 0.0,
        'Social_Interaction': socialInteraction,
        'Irritability_Score':
            (answersData['Irritability_Score'] as num?)?.toDouble() ?? 0.0,
        'Noise_Exposure_div_Exercise_Hours':
            noiseExposure / (exerciseHours + 0.001),
        'Social_Interaction_div_Work_Hours':
            socialInteraction / (workHours + 0.001),
        'Sleep_Hours': _sleepHours ?? 0.0,
        'Age': _age ?? 0.0,
      };

      // Call the predict anxiety endpoint
      final result = await _apiService.predictAnxiety(widget.userId, payload);

      setState(() {
        _predictionResult = result;
        _currentStep = 2; // Move to result screen
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
    if (_isLoading && _currentStep != 2) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Anxiety Check'),
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
          title: const Text('Anxiety Check'),
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

    // Step 1: Anxiety Questionnaire
    if (_currentStep == 1) {
      return _AnxietyQuestionnaireWrapper(
        onCompleted: _onAnxietyQuestionnaireCompleted,
      );
    }

    // Step 2: Result Screen
    if (_currentStep == 2) {
      return _AnxietyResultScreen(
        result: _predictionResult,
        userFeatures: _userFeatures,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AnxietyQuestionnaireWrapper extends StatefulWidget {
  final Function(Map<String, dynamic>) onCompleted;

  const _AnxietyQuestionnaireWrapper({
    required this.onCompleted,
  });

  @override
  State<_AnxietyQuestionnaireWrapper> createState() =>
      _AnxietyQuestionnaireWrapperState();
}

class _AnxietyQuestionnaireWrapperState
    extends State<_AnxietyQuestionnaireWrapper> {
  @override
  Widget build(BuildContext context) {
    return _AnxietyQuestionnaireModified(
      onCompleted: widget.onCompleted,
    );
  }
}

class _AnxietyQuestionnaireModified extends StatefulWidget {
  final Function(Map<String, dynamic>) onCompleted;

  const _AnxietyQuestionnaireModified({
    required this.onCompleted,
  });

  @override
  State<_AnxietyQuestionnaireModified> createState() =>
      _AnxietyQuestionnaireModifiedState();
}

class _AnxietyQuestionnaireModifiedState
    extends State<_AnxietyQuestionnaireModified> {
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'title':
          'How many hours per day do you use technology (phones, computers)?',
      'image': 'assets/images/question_tech.jpg',
      'type': 'number_hours_day',
      'key': 'Tech_Usage_Hours',
    },
    {
      'title':
          'On a scale of 0-10, how sensitive are you to sensory stimuli (lights, sounds, textures)?',
      'image': 'assets/images/question_health.png',
      'type': 'number_0_10',
      'key': 'Sensory_Sensitivity',
    },
    {
      'title': 'Do you typically multitask (do multiple things at once)?',
      'image': 'assets/images/question_work.png',
      'type': 'frequency_grid',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
      'key': 'Multitasking_Habit',
    },
    {
      'title': 'On a scale of 0-10, how irritable have you felt recently?',
      'image': 'assets/images/question_irritability.png',
      'type': 'number_0_10',
      'key': 'Irritability_Score',
    },
    {
      'title': 'How many hours per week do you work at a job?',
      'image': 'assets/images/question_work.png',
      'type': 'number_hours_week',
      'key': 'Work_Hours',
    },
    {
      'title': 'How many hours per week do you exercise?',
      'image': 'assets/images/question_exercise2.jpg',
      'type': 'number_hours_week',
      'key': 'Exercise_Hours',
    },
    {
      'title': 'On a scale of 1-10, how socially active are you?',
      'image': 'assets/images/question_social.jpg',
      'type': 'number_1_10',
      'key': 'Social_Interaction',
    },
    {
      'title': 'How noisy is your daily environment?',
      'image': 'assets/images/question_noise.png',
      'type': 'frequency_grid',
      'options': ['Very Quiet', 'Low Noise', 'Medium Noise', 'Very Noisy'],
      'key': 'Noise_Exposure',
    },
  ];

  bool get _isNextEnabled {
    final answer = _answers[_currentIndex];
    final q = _questions[_currentIndex];
    final type = q['type'];

    if (type == 'frequency_grid') {
      return answer != null;
    }
    if (type == 'number_0_10') {
      return answer is int && answer >= 0 && answer <= 10;
    }
    if (type == 'number_1_10') {
      return answer is int && answer >= 1 && answer <= 10;
    }
    if (type == 'number_hours_day') {
      return answer is int && answer >= 0 && answer <= 24;
    }
    if (type == 'number_hours_week') {
      return answer is int && answer >= 0 && answer <= 168;
    }
    return false;
  }

  Map<String, dynamic> get _answersData {
    return {
      'Tech_Usage_Hours': _answers[0] ?? 0,
      'Sensory_Sensitivity': _answers[1] ?? 0,
      'Multitasking_Habit': _mapGridAnswer(_answers[2], 5) ?? 0,
      'Irritability_Score': _answers[3] ?? 0,
      'Work_Hours': _answers[4] ?? 0,
      'Exercise_Hours': _answers[5] ?? 0,
      'Social_Interaction': _answers[6] ?? 0,
      'Noise_Exposure': _mapGridAnswer(_answers[7], 4) ?? 0,
    };
  }

  int? _mapGridAnswer(dynamic answer, int maxValue) {
    if (answer == null) return null;
    if (maxValue == 5) {
      const options = ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'];
      final index = options.indexOf(answer.toString());
      return index >= 0 ? index : null;
    }
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

    if (type == 'number_0_10' || type == 'number_1_10') {
      final n = int.tryParse(value);
      if (type == 'number_0_10' && n != null && n >= 0 && n <= 10) {
        _answers[_currentIndex] = n;
      } else if (type == 'number_1_10' && n != null && n >= 1 && n <= 10) {
        _answers[_currentIndex] = n;
      }
    } else if (type == 'number_hours_day') {
      final n = int.tryParse(value);
      if (n != null && n >= 0 && n <= 24) {
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
          'Anxiety Assessment',
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

    if (type == 'number_0_10' || type == 'number_1_10') {
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
                hintText: type == 'number_0_10' ? '0–10' : '1–10',
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
            type == 'number_0_10' ? 'Scale: 0-10' : 'Scale: 1-10',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      );
    }

    if (type == 'number_hours_day' || type == 'number_hours_week') {
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
                hintText: type == 'number_hours_day' ? '0–24' : '0–168',
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
            type == 'number_hours_day' ? 'Hours per day' : 'Hours per week',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _AnxietyResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? userFeatures;
  final VoidCallback onClose;

  const _AnxietyResultScreen({
    this.result,
    this.userFeatures,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = result?['prediction'] as int? ?? 0;
    final probability = result?['probability'] as double? ?? 0.0;
    final hasAnxiety = prediction == 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Anxiety Assessment Result'),
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
                    color: hasAnxiety ? Colors.purple[100] : Colors.green[100],
                  ),
                  child: Center(
                    child: Icon(
                      hasAnxiety
                          ? Icons.sentiment_very_dissatisfied
                          : Icons.sentiment_satisfied,
                      size: 60,
                      color: hasAnxiety ? Colors.purple : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  hasAnxiety
                      ? 'Anxiety Symptoms Detected'
                      : 'No Anxiety Detected',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: hasAnxiety ? Colors.purple : Colors.green,
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
                        hasAnxiety ? 'Anxiety Detected' : 'No Anxiety',
                        hasAnxiety ? Colors.purple : Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Confidence',
                          '${(probability * 100).toStringAsFixed(1)}%'),
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

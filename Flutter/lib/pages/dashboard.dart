import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_research/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:health_research/services/ForecastApiService.dart';
import 'package:health_research/config/api_config.dart';
import 'dart:convert';
import 'dart:math';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String firstName = "User";
  String patientId = "";
  int pendingSessions = 0;
  String memberSince = "";
  bool isLoading = false;
  ForecastData? forecastData;
  List<Prediction> selectedPredictions = [];
  bool isForecastLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId') ?? '';
    setState(() {
      firstName = prefs.getString('firstName') ?? 'User';
    });

    if (patientId.isNotEmpty) {
      await _fetchDashboardData();
      await _fetchForecastData();
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/patients/dashboard/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          pendingSessions = jsonResponse['pending_sessions'] ?? 0;
          memberSince = jsonResponse['member_since'] ?? '';
        });
      }
    } catch (e) {
      // Error fetching dashboard data
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchForecastData() async {
    if (patientId.isEmpty) return;

    setState(() => isForecastLoading = true);
    try {
      final studentId = int.tryParse(patientId) ?? 0;
      final forecastService = ForecastApiService();
      final data = await forecastService.fetchForecast(studentId);

      if (data != null && data.predictions.isNotEmpty) {
        final random = Random();
        final maxPredictions = min(3, data.predictions.length);
        final predictions = <Prediction>[];

        // Shuffle and select random predictions
        final shuffled = List<Prediction>.from(data.predictions)
          ..shuffle(random);
        predictions.addAll(shuffled.take(maxPredictions));

        setState(() {
          forecastData = data;
          selectedPredictions = predictions;
        });
      }
    } catch (e) {
      // Error fetching forecast data
    }
    setState(() => isForecastLoading = false);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  String _formatMemberSince() {
    if (memberSince.isEmpty) return "Recently";
    try {
      final dateTime = DateTime.parse(memberSince);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return "Recently";
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(date),
              const SizedBox(height: 16),
              _statusCards(),
              const SizedBox(height: 20),
              const Text(
                "Your Mental Health Insights",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _mentalHealthInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(String date) {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage("assets/images/sunshine.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Spacer(),
          Text(
            _getGreeting(),
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            firstName,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _statusCards() {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            title: "Member Since",
            child: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(
                    _formatMemberSince(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            title: "Sessions Pending",
            child: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pendingSessions.toString(),
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Remaining this month",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _mentalHealthInsightsSection() {
    if (isForecastLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (selectedPredictions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text(
            "No predictions available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text("Insights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: selectedPredictions
                .map((prediction) => _predictionCard(prediction))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _predictionCard(Prediction prediction) {
    Color stressColor;
    Color mentalColor;
    IconData stressIcon;
    IconData mentalIcon;

    // Determine stress level colors and icons
    if (prediction.stressPredLabel == "High") {
      stressColor = Colors.red;
      stressIcon = Icons.trending_up;
    } else if (prediction.stressPredLabel == "Medium") {
      stressColor = Colors.orange;
      stressIcon = Icons.trending_flat;
    } else {
      stressColor = Colors.green;
      stressIcon = Icons.trending_down;
    }

    // Determine mental state colors and icons
    if (prediction.mentalPredLabel == "Depression") {
      mentalColor = Colors.purple;
      mentalIcon = Icons.sentiment_very_dissatisfied;
    } else if (prediction.mentalPredLabel == "Moderate Stress") {
      mentalColor = Colors.orange;
      mentalIcon = Icons.sentiment_dissatisfied;
    } else {
      mentalColor = Colors.green;
      mentalIcon = Icons.sentiment_satisfied;
    }

    // Parse date
    DateTime predictionDate;
    try {
      predictionDate = DateTime.parse(prediction.date);
    } catch (e) {
      predictionDate = DateTime.now();
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM dd').format(predictionDate),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(stressIcon, color: stressColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Stress",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      prediction.stressPredLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: stressColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(mentalIcon, color: mentalColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mental State",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      prediction.mentalPredLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mentalColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_research/pages/schedule_session.dart';
import 'package:health_research/pages/therapy_video_call.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_research/pages/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_research/config/api_config.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String firstName = "User";
  String patientId = "";
  int pendingSessions = 0;
  String memberSince = "";
  bool isLoading = false;

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
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      print("featch data, patientId: $patientId");
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
      print('Error fetching dashboard data: $e');
    }
    setState(() => isLoading = false);
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
                "Try following activities to lift your mood",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _activitiesSection(),
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

  Widget _activitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text("Activities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _activityCard(
                  "Read a book", "30 mins - 2 hrs", "assets/images/book.png"),
              _activityCard(
                  "Play a game", "1 hr - 2 hrs", "assets/images/game.jpg"),
              _activityCard(
                  "Listen music", "30 mins", "assets/images/music.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityCard(String title, String time, String image) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

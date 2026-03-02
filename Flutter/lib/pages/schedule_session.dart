import 'package:flutter/material.dart';
import 'package:health_research/pages/therapy_video_call.dart';
import '../services/agora_api.dart';

class ScheduleSessionPage extends StatelessWidget {
  const ScheduleSessionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Schedule a Session",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Schedule a session with a professional to lift your mood",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16)
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Section
              _sectionTitle("Up Coming"),
              const SizedBox(height: 12),
              _upcomingCard(context),

              const SizedBox(height: 24),

              // Past Section
              _sectionTitle("Past Sessions"),
              const SizedBox(height: 12),
              _pastCard(
                  date: "1st December 2025",
                  sessionId: "S202511",
                  time: "6.30pm"),
              const SizedBox(height: 12),
              _pastCard(
                  date: "21st November 2025",
                  sessionId: "S202507",
                  time: "6.30pm"),
            ],
          ),
        ),
      ),
    );
  }

  // Section title
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios, size: 16)
      ],
    );
  }

  // Upcoming card
  Widget _upcomingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade300,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("25th December 2025",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Session ID: S202523   Time : 8.30pm",
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Dr. Jagath Perera",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("Counseling psychologists",
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text("Kindly join 5 minutes in advance",
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = await AgoraApi.getToken(
                      sessionId: "S202523",
                      role: "patient",
                      uid: 1002, // Patient UID - must match Flutter patient app
                    );

                    // ─── ADD THESE PRINTS ────────────────────────────────────────
                    print("╔════════════════════════════════════════════╗");
                    print("║          TOKEN RESPONSE FROM BACKEND       ║");
                    print("╚════════════════════════════════════════════╝");
                    print("Full response: $data");
                    print("token length: ${data['token']?.length ?? 'null'}");
                    print("uid: ${data['uid']}");
                    print(
                        "channel (if any): ${data['channel'] ?? 'not returned'}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainScreen(
                          sessionId: "S202523",
                          token: data['token'],
                          uid: data['uid'] ?? 1002,
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Token fetch error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to get token: $e")),
                    );
                  }
                },
                child: const Text("Join Now"),
              )
            ],
          )
        ],
      ),
    );
  }

  // Past card
  Widget _pastCard({
    required String date,
    required String sessionId,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade300,
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Session ID: $sessionId   Time : $time",
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                const Text("Dr. Jagath Perera",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Bottom navigation
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ""),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_research/pages/schedule_session.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(date),
              const SizedBox(height: 16),
              _statusCards(context),
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

  // ---------------- HEADER ----------------
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
          const Text(
            "Good Morning",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Vinuja",
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------- STATUS CARDS ----------------
  Widget _statusCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            title: "You are in a\nHappy Mood",
            child: const Icon(Icons.sentiment_satisfied,
                size: 60, color: Colors.orange),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScheduleSessionPage(),
                ),
              );
            },
            child: _infoCard(
              title: "Sessions Pending",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("1",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  Text("Remaining this month",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                ],
              ),
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

  // ---------------- ACTIVITIES ----------------
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

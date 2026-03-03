import 'package:flutter/material.dart';
import 'package:health_research/pages/physStress.dart';
import 'package:health_research/pages/stressQuestionnaireScreen.dart';

class BurnOutHome extends StatelessWidget {
  const BurnOutHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Burnout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🖼️ Illustration Image
              Image.asset(
                'assets/images/burnout.jpg',
                height: 270,
              ),

              const SizedBox(height: 20),

              // 📄 Description Text
              Text(
                "Burnout is a state of emotional, mental, and physical exhaustion caused by prolonged stress, often related to school, work, or personal responsibilities. It can make you feel drained, unmotivated, irritable, and disconnected from things you usually care about. Taking burnout seriously is important for mental health because ignoring it can lead to anxiety, depression, and ongoing stress. Prioritizing rest, setting boundaries, and making time for activities you enjoy helps protect your well-being and keeps your mind healthier and more balanced over time.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Try the quest to check you’s",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhysStress(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xfff2f2f2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/file_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Burnout Quest ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Check for signs of emotional and physical exhaustion to find out if you may be experiencing burnout.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

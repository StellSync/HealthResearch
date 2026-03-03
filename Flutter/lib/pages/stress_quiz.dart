import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StressQuiz extends StatefulWidget {
  const StressQuiz({super.key});

  @override
  State<StressQuiz> createState() => _StressQuizState();
}

class _StressQuizState extends State<StressQuiz> {
  List<Map<String, String>> history = [
    {"date": "25 December 2025", "time": "12:53:48", "status": "Stressed"},
    {"date": "25 December 2025", "time": "12:53:48", "status": "Not Stressed"}
  ];

  void checkStress() {
    setState(() {
      history.insert(0, {
        "date": DateFormat("dd MMMM yyyy").format(DateTime.now()),
        "time": DateFormat("HH:mm:ss").format(DateTime.now()),
        "status": "Not Stressed"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Daily Stress Quest"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage("assets/images/stress.png"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: checkStress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Check Now"),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Stress Records History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, index) {
                  var item = history[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["date"]!),
                            Text(item["time"]!,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(
                          item["status"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item["status"] == "Stressed"
                                ? Colors.red
                                : Colors.green,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

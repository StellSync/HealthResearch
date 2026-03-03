import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DepressionQuiz extends StatefulWidget {
  const DepressionQuiz({super.key});

  @override
  State<DepressionQuiz> createState() => _DepressionQuizState();
}

class _DepressionQuizState extends State<DepressionQuiz> {
  List<Map<String, String>> history = [
    {"date": "23 December 2025", "time": "14:11:44", "status": "Depressed"},
    {"date": "22 December 2025", "time": "16:44:21", "status": "Stable"}
  ];

  void checkDepression() {
    String result = DateTime.now().second % 2 == 0 ? "Stable" : "Depressed";

    setState(() {
      history.insert(0, {
        "date": DateFormat("dd MMMM yyyy").format(DateTime.now()),
        "time": DateFormat("HH:mm:ss").format(DateTime.now()),
        "status": result
      });
    });
  }

  Color getColor(String status) {
    if (status == "Depressed") return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Daily Depression Quest"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/images/depression.png"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkDepression,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Check Now",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Depression Records History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  var item = history[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["date"]!,
                            ),
                            Text(
                              item["time"]!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Text(
                          item["status"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getColor(item["status"]!),
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

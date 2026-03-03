import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnxietyQuiz extends StatefulWidget {
  const AnxietyQuiz({super.key});

  @override
  State<AnxietyQuiz> createState() => _AnxietyQuizState();
}

class _AnxietyQuizState extends State<AnxietyQuiz> {
  List<Map<String, String>> history = [
    {"date": "25 December 2025", "time": "10:22:11", "status": "High Anxiety"},
    {"date": "24 December 2025", "time": "09:15:02", "status": "Normal"}
  ];

  void checkAnxiety() {
    String result = DateTime.now().second % 2 == 0 ? "Normal" : "High Anxiety";

    setState(() {
      history.insert(0, {
        "date": DateFormat("dd MMMM yyyy").format(DateTime.now()),
        "time": DateFormat("HH:mm:ss").format(DateTime.now()),
        "status": result
      });
    });
  }

  Color getColor(String status) {
    if (status == "High Anxiety") return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Daily Anxiety Quest"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// IMAGE
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
                backgroundImage: AssetImage("assets/images/anxiety.png"),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            ElevatedButton(
              onPressed: checkAnxiety,
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
                "Anxiety Records History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// HISTORY LIST
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
                              style: const TextStyle(fontSize: 15),
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

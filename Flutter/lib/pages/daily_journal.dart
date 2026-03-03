import 'package:flutter/material.dart';

class DailyJournal extends StatefulWidget {
  const DailyJournal({super.key});

  @override
  State<DailyJournal> createState() => _DailyJournalState();
}

class _DailyJournalState extends State<DailyJournal> {
  TextEditingController controller = TextEditingController();

  void saveJournal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Journal Saved"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Daily Journal"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage("assets/images/academic-quiz.png"),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Write your journal here",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Write here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveJournal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}

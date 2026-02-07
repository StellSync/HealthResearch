import 'package:flutter/material.dart';

class AcademicHome extends StatelessWidget {
  const AcademicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Academic Home Page!'),
      ),
    );
  }
}
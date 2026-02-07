import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wareble Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Wareble Home Page!'),
      ),
    );
  }
}
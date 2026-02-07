import 'package:flutter/material.dart';

class WarebleHome extends StatelessWidget {
  const WarebleHome({super.key});

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
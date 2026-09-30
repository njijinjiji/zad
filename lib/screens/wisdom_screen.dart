import 'package:flutter/material.dart';

class WisdomScreen extends StatelessWidget {
  const WisdomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' روائع الكتب'),
      ),
      body: const Center(
        child: Text(
          'روائع الكتب',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
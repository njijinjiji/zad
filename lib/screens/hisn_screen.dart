import 'package:flutter/material.dart';

class HisnScreen extends StatelessWidget {
  const HisnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن المسلم'),
      ),
      body: const Center(
        child: Text(
          'حصن المسلم',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
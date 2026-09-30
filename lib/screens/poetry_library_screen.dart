import 'package:flutter/material.dart';

class PoetryLibraryScreen extends StatelessWidget {
  const PoetryLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الديوان الأدبي'),
      ),
      body: const Center(
        child: Text(
          'الديوان الأدبي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
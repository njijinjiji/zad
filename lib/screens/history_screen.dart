import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل'),
      ),
      body: const Center(
        child: Text(
          'لا يوجد سجل حاليًا',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
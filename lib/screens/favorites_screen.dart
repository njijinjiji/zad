import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلات'),
      ),
      body: const Center(
        child: Text(
          'لا توجد عناصر مفضلة حاليًا',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
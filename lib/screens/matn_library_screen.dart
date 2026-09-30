import 'package:flutter/material.dart';

import '../models/matn_model.dart';
import '../services/matn_service.dart';

class MatnLibraryScreen extends StatelessWidget {
  const MatnLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خزانة المتون'),
      ),

      body: FutureBuilder<List<Matn>>(
        future: MatnService.loadMatn(),

        builder: (context, snapshot) {
          // أثناء تحميل البيانات
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // إذا حدث خطأ
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل المتون:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // إذا لم توجد بيانات
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('لا توجد متون حاليًا'),
            );
          }

          // البيانات وصلت بنجاح
          final matnList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matnList.length,

            itemBuilder: (context, index) {
              final matn = matnList[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),

                child: _buildMatnCard(
                  context,
                  matn: matn,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMatnCard(
    BuildContext context, {
    required Matn matn,
  }) {
    return InkWell(
      onTap: () {
        // سنضيف فتح المتن في الخطوة القادمة
      },

      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: const Color(0xFF2A2A2A),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,

              decoration: BoxDecoration(
                color: const Color(0xFF2D5D3F),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    matn.title,

                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    matn.author,

                    style: const TextStyle(
                      color: Color(0xFFB8B8B8),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    matn.description,

                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
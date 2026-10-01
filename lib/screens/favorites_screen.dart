import 'package:flutter/material.dart';
import '../models/matn_model.dart';
import '../services/favorites_service.dart';
import 'matn_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const FavoritesScreen({super.key, this.onBackToHome});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void _removeFavorite(Matn matn) {
    setState(() {
      FavoritesService.toggleFavorite(matn);Future<void> _removeFavorite(Matn matn) async {
    await FavoritesService.toggleFavorite(matn);
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إزالة "${matn.title}" من المفضلة'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إزالة "${matn.title}" من المفضلة'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // جلب العناصر المحفوظة فوراً عند كل إعادة بناء
    final favorites = FavoritesService.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلات'),
        centerTitle: true,
        // زر الرجوع إلى الصفحة الرئيسية
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'الرجوع للرئيسية',
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد عناصر مفضلة حاليًا',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final matn = favorites[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.bookmark),
                    ),
                    title: Text(
                      matn.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'المؤلف: ${matn.author}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'حذف من المفضلة',
                      onPressed: () => _removeFavorite(matn),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatnDetailScreen(matn: matn),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
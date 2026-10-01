import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'matn_library_screen.dart';
import 'poetry_library_screen.dart';
import 'benefits_screen.dart';
import 'wisdom_screen.dart';
import 'hisn_screen.dart';
import '../services/matn_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

 
}

class _HomeScreenState extends State<HomeScreen> {
 
 @override
  void initState() {
    super.initState();
    _initPersistentData();
  }

  Future<void> _initPersistentData() async {
    final mutoon = await MatnService.loadMutoon();
    await FavoritesService.loadFavorites(mutoon);
    await HistoryService.loadHistory(mutoon);
    if (mounted) {
      setState(() {});
    }
  }
 
  // 0: الرئيسية, 1: المفضلات, 2: السجل
  int currentIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      // index 0 في الشريط = المفضلات (القيمة 1)
      // index 1 في الشريط = السجل (القيمة 2)
      currentIndex = index + 1;
    });
  }

  void _backToHome() {
    setState(() {
      currentIndex = 0;
    });
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الآية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF5C4A3D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'وَاتَّزَوَّدُوا فَإِنَّ خَيْرَ الزَّادِ التَّقْوَىٰ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4A574),
                  fontSize: 20,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // عنوان الأقسام
            const Text(
              'الأقسام الرئيسية',
              style: TextStyle(
                color: Color(0xFFA89968),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // شبكة الأقسام
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MatnLibraryScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    title: 'خزانة المتون',
                    description: 'مكتبة منظمة تضم أهم المتون العلمية',
                    icon: Icons.menu_book,
                    iconColor: Color(0xFF2D5D3F),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PoetryLibraryScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    title: 'الديوان الأدبي',
                    description: 'قصائد مختارة من عيون الشعر العربي',
                    icon: Icons.edit,
                    iconColor: Color(0xFF5C4A3D),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BenefitsScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    title: 'جنى الفوائد',
                    description: 'كنوز منتقاة من بطون الكتب',
                    icon: Icons.star,
                    iconColor: Color(0xFFC97A3A),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WisdomScreen(),
                      ),
                    );
                  },
                  child: const CategoryCard(
                    title: 'روائع الكتب',
                    description: 'مكتبة شاملة لأمهات الكتب',
                    icon: Icons.auto_awesome,
                    iconColor: Color(0xFF6B5845),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // بطاقة حصن المسلم
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HisnScreen(),
                  ),
                );
              },
              child: const CategoryCard(
                title: 'حصن المسلم',
                description: 'الأذكار اليومية مع تنبيهات ذكية',
                icon: Icons.volunteer_activism,
                iconColor: Color(0xFF3D5C52),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الشاشة المعروضة حالياً
    Widget activeBody;
    if (currentIndex == 1) {
      activeBody = FavoritesScreen(onBackToHome: _backToHome);
    } else if (currentIndex == 2) {
      activeBody = HistoryScreen(onBackToHome: _backToHome);
    } else {
      activeBody = _buildHomeContent();
    }

    return Scaffold(
      // عرض شريط زاد الطالب فقط عندما نكون في الصفحة الرئيسية
      appBar: currentIndex == 0
          ? AppBar(
              title: const Text('زاد الطالب'),
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'مشاركة',
                  onPressed: () {
                    Share.share(
                      'جرّب تطبيق زاد الطالب 📚\nرفيقك في رحلة العلم والذكر.',
                    );
                  },
                ),
              ],
            )
          : null,

      // استخدام الشاشة المباشرة بدلاً من IndexedStack حتى تتجدد البيانات فور الدخول
      body: activeBody,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex == 0 ? 0 : currentIndex - 1,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'السجل',
          ),
        ],
      ),
    );
  }
}
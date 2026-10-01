import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zikr_model.dart';

class HisnScreen extends StatefulWidget {
  const HisnScreen({super.key});

  @override
  State<HisnScreen> createState() => _HisnScreenState();
}

class _HisnScreenState extends State<HisnScreen> {
  List<ZikrCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAzkarData();
  }

  // تحميل الأذكار من ملف JSON واسترجاع تقدم العدادات المخزن محلياً
  Future<void> _loadAzkarData() async {
    try {
      final jsonString = await rootBundle.loadString('lib/data/adhkar.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final categories = jsonData.map((e) => ZikrCategory.fromJson(e)).toList();

      final prefs = await SharedPreferences.getInstance();

      // فحص اليوم للتصفير التلقائي مع بداية كل يوم جديد
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString('hisn_last_active_date');

      if (lastDate != null && lastDate != todayStr) {
        // إذا كان يوم جديد: نحذف العدادات السابقة لتبدأ من الصفر
        for (final cat in categories) {
          for (final item in cat.items) {
            await prefs.remove('zikr_count_${item.id}');
          }
        }
      }
      await prefs.setString('hisn_last_active_date', todayStr);

      // استرجاع القيمة الحالية لكل ذكر من SharedPreferences
      for (final cat in categories) {
        for (final item in cat.items) {
          item.currentCount = prefs.getInt('zikr_count_${item.id}') ?? 0;
        }
      }

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل adhkar.json: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // زيادة العداد وحفظه محلياً فوراً
  Future<void> _increment(ZikrItem item) async {
    if (item.currentCount < item.targetCount) {
      setState(() {
        item.currentCount++;
      });
      HapticFeedback.lightImpact();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('zikr_count_${item.id}', item.currentCount);
    }
  }

  // تصفير ذكر محدد وحفظ التغيير
  Future<void> _resetSingle(ZikrItem item) async {
    setState(() {
      item.currentCount = 0;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('zikr_count_${item.id}');
  }

  // تصفير قسم كامل وحفظ التغيير
  Future<void> _resetCategory(ZikrCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var it in category.items) {
        it.currentCount = 0;
      }
    });

    for (var it in category.items) {
      await prefs.remove('zikr_count_${it.id}');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إعادة ضبط عدادات ${category.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('حصن المسلم'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('حصن المسلم'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('تعذر تحميل الأذكار، يرجى التحقق من ملف adhkar.json'),
        ),
      );
    }

    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حصن المسلم'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            indicatorColor: const Color(0xFFD4A574),
            labelColor: const Color(0xFFD4A574),
            unselectedLabelColor: Colors.grey,
            tabs: _categories.map((c) => Tab(text: c.title)).toList(),
          ),
        ),
        body: TabBarView(
          children: _categories.map((category) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عدد الأذكار: ${category.items.length}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('إعادة الضبط'),
                        onPressed: () => _resetCategory(category),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: category.items.length,
                    itemBuilder: (context, index) {
                      final item = category.items[index];
                      final isDone = item.isCompleted;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDone ? Colors.green.shade400 : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _increment(item),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SelectableText(
                                  item.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    height: 1.9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (item.description.isNotEmpty) ...[
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay, size: 18),
                                      tooltip: 'تصفير هذا الذكر',
                                      color: Colors.grey,
                                      onPressed: () => _resetSingle(item),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? Colors.green.shade600
                                            : const Color(0xFF5C4A3D),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isDone
                                            ? 'اكتمل ✓'
                                            : '${item.currentCount} / ${item.targetCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/matn_model.dart';

class MatnService {
  // دالة لقراءة المتون من ملف mutoon.json وتحويلها إلى قائمة من كائنات Matn
  static Future<List<Matn>> loadMutoon() async {
    try {
      // 1. قراءة الملف كنص خام
      final String jsonString = await rootBundle.loadString('lib/data/mutoon.json');

      // 2. فك ترميز النص إلى JSON (List ديناميكية)
      final List<dynamic> jsonList = json.decode(jsonString);

      // 3. تحويل كل عنصر في القائمة إلى كائن Matn
      return jsonList.map((item) => Matn.fromJson(item)).toList();
    } catch (e) {
      // طباعة الخطأ في وحدة التحكم للمساعدة في تصحيحه إن وجد
      print('خطأ أثناء تحميل المتون: $e');
      return [];
    }
  }
}
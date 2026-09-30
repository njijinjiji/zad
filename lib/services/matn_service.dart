import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/matn_model.dart';

class MatnService {
  static Future<List<Matn>> loadMatn() async {
    final jsonString =
        await rootBundle.loadString('lib/data/mutoon.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData
        .map((item) => Matn.fromJson(item))
        .toList();
  }
}
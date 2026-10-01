class ZikrItem {
  final String id;
  final String text;
  final String description;
  final int targetCount;
  int currentCount;

  ZikrItem({
    required this.id,
    required this.text,
    this.description = '',
    required this.targetCount,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= targetCount;

  factory ZikrItem.fromJson(Map<String, dynamic> json) {
    return ZikrItem(
      id: json['id'] as String,
      text: json['text'] as String,
      description: (json['description'] as String?) ?? '',
      targetCount: (json['targetCount'] as int?) ?? 1,
      currentCount: 0,
    );
  }
}

class ZikrCategory {
  final String title;
  final List<ZikrItem> items;

  ZikrCategory({
    required this.title,
    required this.items,
  });

  factory ZikrCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ZikrCategory(
      title: json['category'] as String,
      items: rawItems.map((e) => ZikrItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
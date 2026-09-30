class Matn {
  final String id;
  final String title;
  final String author;
  final String description;
  final String content;

  Matn({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.content,
  });

  factory Matn.fromJson(Map<String, dynamic> json) {
    return Matn(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'content': content,
    };
  }
}
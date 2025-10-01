
class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF, // Default to white
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      color: map['color'] ?? 0xFFFFFFFF,
    );
  }
}

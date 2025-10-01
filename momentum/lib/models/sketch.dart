import 'dart:ui';

class Sketch {
  final int? id;
  final String title;
  final List<Offset> points;
  final DateTime creationDate;

  Sketch({
    this.id,
    required this.title,
    required this.points,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'creationDate': creationDate.toIso8601String(),
    };
  }

  factory Sketch.fromMap(Map<String, dynamic> map) {
    return Sketch(
      id: map['id'],
      title: map['title'],
      points: (map['points'] as List)
          .map((p) => Offset(p['dx'], p['dy']))
          .toList(),
      creationDate: DateTime.parse(map['creationDate']),
    );
  }
}

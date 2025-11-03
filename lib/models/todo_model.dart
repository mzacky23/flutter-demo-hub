import 'package:hive/hive.dart';

part 'todo_model.g.dart'; // ← Untuk generated adapter

@HiveType(typeId: 1) // ← TypeId berbeda dari Bookmark (0)
class Todo {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final bool isCompleted;

  Todo({required this.id, required this.title, required this.isCompleted});

  Todo copyWith({String? id, String? title, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isCompleted.hashCode;
}
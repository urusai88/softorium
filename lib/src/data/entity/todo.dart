import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

part 'todo.g.dart';

@Collection()
class Todo {
  Todo({
    this.id = Isar.autoIncrement,
    required this.description,
    required this.completed,
    required this.createdTime,
  });

  factory Todo.create({
    required String description,
    bool completed = false,
  }) =>
      Todo(
        description: description,
        completed: completed,
        createdTime: DateTime.now(),
      );

  Id id;

  String description;

  bool completed;

  DateTime createdTime;

  @Index()
  String get createdDate => DateFormat('yyyy-MM-dd').format(createdTime);
}

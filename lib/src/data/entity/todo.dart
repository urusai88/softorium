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
    DateTime? createdTime,
  }) =>
      Todo(
        description: description,
        completed: completed,
        createdTime: createdTime ?? DateTime.now(),
      );

  static final dateFormat = DateFormat('dd.MM.yyyy');

  Id id;

  String description;

  bool completed;

  DateTime createdTime;

  @Index()
  String get createdDate => dateFormat.format(createdTime);
}

extension TodoQueryWhereMy on QueryBuilder<Todo, Todo, QWhereClause> {
  QueryBuilder<Todo, Todo, QAfterWhereClause> createdDateEqualToDateTime(
    DateTime dateTime,
  ) =>
      createdDateEqualTo(Todo.dateFormat.format(dateTime));
}

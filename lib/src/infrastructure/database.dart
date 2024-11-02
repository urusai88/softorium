import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart';

import '../../main.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get description => text().withLength(min: 1, max: 20)();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdTime => dateTime().clientDefault(DateTime.now)();
}

@DriftDatabase(tables: [TodoItems])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  factory MyDatabase.of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<MyApp>()!.database;

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'my');

  Future<List<TodoItem>> todosInDay(DateTime dateTime) {
    return (select(todoItems)
          ..where((t) => t.createdTime.date
              .equals(DateFormat('yyyy-MM-dd').format(dateTime))))
        .get();
  }

  Future<TodoItem> addTodo(String description) =>
      managers.todoItems.createReturning((c) => c(description: description));

  Future<void> deleteTodo(TodoItem todo) =>
      managers.todoItems.filter((f) => f.id.equals(todo.id)).delete();

  Future<void> updateTodo(TodoItem todo) {
    return managers.todoItems
        .filter((f) => f.id.equals(todo.id))
        .update((c) => todo.toCompanion(true));
  }
}

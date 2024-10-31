import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart' show BuildContext;

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

  static MyDatabase of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<MyApp>()!.database;

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'my');

  Future<List<TodoItem>> todosInDay(DateTime dateTime) {
    return (select(todoItems)
          ..where(
            (t) =>
                t.createdTime.year.equals(dateTime.year) &
                t.createdTime.month.equals(dateTime.month) &
                t.createdTime.day.equals(dateTime.day),
          ))
        .get();
  }

  Future<TodoItem> addTodo(String description) =>
      managers.todoItems.createReturning(
        (c) => c(
          description: description,
          completed: const Value(false),
          createdTime: Value(DateTime.now()),
        ),
      );

  Future<void> deleteTodo(TodoItem todo) {
    return managers.todoItems.filter((f) => f.id.equals(todo.id)).delete();
  }

  Future<void> updateTodo(TodoItem todo) {
    return managers.todoItems
        .filter((f) => f.id.equals(todo.id))
        .update((c) => todo.toCompanion(true));
  }
}

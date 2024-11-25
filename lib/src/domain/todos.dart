import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../data.dart';
import '../services.dart';

typedef TodosProvider
    = AsyncNotifierFamilyProvider<TodosNotifier, List<Todo>, String>;

typedef TodosState = AsyncValue<List<Todo>>;

final todosProvider =
    AsyncNotifierProviderFamily<TodosNotifier, List<Todo>, String>(
  TodosNotifier.new,
);

class TodosNotifier extends FamilyAsyncNotifier<List<Todo>, String> {
  Isar get _isar => ref.read(isarProvider);

  IsarCollection<Todo> get _todos => ref.read(isarProvider).todos;

  @override
  Future<List<Todo>> build(String arg) async {
    assert(Todo.dateFormat.tryParse(arg) != null);
    final subscription = _todos
        .where()
        .createdDateEqualTo(arg)
        .watch()
        .listen((todos) => state = AsyncValue.data(todos));
    ref.onDispose(subscription.cancel);
    return _todos.where().createdDateEqualTo(arg).findAll();
  }

  Future<void> createTodo(String description) async {
    description = description.trim();
    if (description.isEmpty) {
      return;
    }
    final todo = Todo.create(
      description: description,
      createdTime: Todo.dateFormat.parse(arg),
    );
    await _isar.writeTxn(() => _todos.put(todo));
  }

  Future<Todo?> updateTodo(int id, {bool? completed}) async {
    final todo = await _todos.where().idEqualTo(id).findFirst();
    if (todo == null) {
      return null;
    }
    todo.completed = completed ?? todo.completed;
    await _isar.writeTxn(() => _todos.put(todo));
    return todo;
  }

  Future<void> deleteTodo(int id) async =>
      _isar.writeTxn(() => _todos.delete(id));
}

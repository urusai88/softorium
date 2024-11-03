import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'data.dart';
import 'domain/todos.dart';

final isarProvider = Provider<Isar>((_) => throw UnimplementedError());

final todosProvider =
    AsyncNotifierProviderFamily<TodosNotifier, List<Todo>, String>(
  TodosNotifier.new,
);

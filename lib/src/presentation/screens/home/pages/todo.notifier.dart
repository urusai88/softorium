part of 'todo.dart';

class TodosPageNotifier
    extends FamilyAsyncNotifier<List<TodoPageTodo>, String> {
  @override
  Future<List<TodoPageTodo>> build(String arg) async {
    final data = await ref.watch(todosProvider(arg).future);
    return data.map((e) => TodoPageTodo(todo: e)).toList();
  }

  Future<void> deleteTodo(int id) async {
    if (state case AsyncData(value: final value)) {
      final index = value.indexWhere((e) => e.todo.id == id);
      if (index == -1) {
        return;
      }
      final next = List.of(value);
      next[index] = value[index].withRemoving();
      state = AsyncData(next);
    }
  }
}

final todosPageProvider =
    AsyncNotifierProviderFamily<TodosPageNotifier, List<TodoPageTodo>, String>(
  TodosPageNotifier.new,
);

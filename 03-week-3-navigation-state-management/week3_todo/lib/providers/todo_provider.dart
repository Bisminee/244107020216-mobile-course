import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(Todo todo) {
    state = [
      for (final t in state)
        if (identical(t, todo)) t.copyWith(done: !t.done) else t,
    ];
  }

  void remove(Todo todo) {
    state = state.where((t) => !identical(t, todo)).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

enum TodoFilter { all, pending, done }

class FilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<FilterNotifier, TodoFilter>(FilterNotifier.new);

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  switch (filter) {
    case TodoFilter.all:
      return todos;
    case TodoFilter.pending:
      return todos.where((t) => !t.done).toList();
    case TodoFilter.done:
      return todos.where((t) => t.done).toList();
  }
});

class ProductsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2));
    return ['Keyboard', 'Mouse', 'Monitor'];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['Keyboard', 'Mouse', 'Monitor', 'Headset'];
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<String>>(
  ProductsNotifier.new,
);
import '../../models/todo_model.dart';

class TodoState {
  final List<Todo> todos;
  final bool isLoading;

  const TodoState({
    required this.todos,
    required this.isLoading,
  });

  // Initial state
  factory TodoState.initial() {
    return const TodoState(
      todos: [],
      isLoading: false,
    );
  }

  // Copy with method untuk immutable updates
  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
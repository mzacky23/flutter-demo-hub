import 'package:belajar_flutter/models/todo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final Box<Todo> todoBox;
  final Logger _logger = Logger();

  TodoCubit({required this.todoBox}) : super(TodoState.initial()) {
    _loadTodos(); // Load todos saat cubit dibuat
  }

  // Load todos dari Hive
  void _loadTodos() {
    try {
      final todos = todoBox.values.toList();
      emit(state.copyWith(todos: todos));
    } catch (e) {
      _logger.e('Error loading todos: $e');
      emit(state.copyWith(todos: []));
    }
  }

  // Tambah todo baru
  void addTodo(String title) {
    if (title.trim().isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      isCompleted: false,
    );

    // Simpan ke Hive
    todoBox.put(newTodo.id, newTodo);
    
    // Update state
    final newTodos = todoBox.values.toList();
    emit(state.copyWith(todos: newTodos));
  }

  // Hapus todo
  void removeTodo(String id) {
    // Hapus dari Hive
    todoBox.delete(id);
    
    // Update state
    final newTodos = todoBox.values.toList();
    emit(state.copyWith(todos: newTodos));
  }

  // Toggle complete/uncomplete
  void toggleTodo(String id) {
    final todo = todoBox.get(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      
      // Update di Hive
      todoBox.put(id, updatedTodo);
      
      // Update state
      final newTodos = todoBox.values.toList();
      emit(state.copyWith(todos: newTodos));
    }
  }

  // Clear semua completed todos
  void clearCompleted() {
    final completedTodos = todoBox.values
        .where((todo) => todo.isCompleted)
        .toList();
    
    // Hapus dari Hive
    for (final todo in completedTodos) {
      todoBox.delete(todo.id);
    }
    
    // Update state
    final newTodos = todoBox.values.toList();
    emit(state.copyWith(todos: newTodos));
  }

  // Edit todo
  void editTodo(String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;

    final todo = todoBox.get(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(title: newTitle.trim());
      
      // Update di Hive
      todoBox.put(id, updatedTodo);
      
      // Update state
      final newTodos = todoBox.values.toList();
      emit(state.copyWith(todos: newTodos));
    }
  }
}
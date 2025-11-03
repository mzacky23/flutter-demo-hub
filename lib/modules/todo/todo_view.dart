import 'package:belajar_flutter/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/todo/todo_cubit.dart';
import '../../blocs/todo/todo_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../models/theme_model.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDark;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo List with BLoC'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                onPressed: () => _showClearCompletedDialog(context, isDarkMode),
                tooltip: 'Clear Completed',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                      ]
                    : [
                        Colors.deepPurple.shade50,
                        Colors.deepPurple.shade100,
                      ],
              ),
            ),
            child: Column(
              children: [
                // Input section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildTodoInput(context, isDarkMode),
                ),
                
                // List section
                Expanded(child: _buildTodoList(isDarkMode)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodoInput(BuildContext context, bool isDarkMode) {
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Apa yang ingin dilakukan?',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<TodoCubit>().addTodo(value);
                  controller.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 24),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<TodoCubit>().addTodo(controller.text);
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(bool isDarkMode) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist,
                  size: 80,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada todo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yuk tambah todo pertama kamu!',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.todos.length,
          itemBuilder: (context, index) {
            final todo = state.todos[index];
            return _buildTodoItem(todo, context, isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo, BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Dismissible(
          key: Key(todo.id),
          background: _buildSwipeBackground(Colors.blue, Icons.edit, 'Edit'),
          secondaryBackground: _buildSwipeBackground(Colors.red, Icons.delete, 'Hapus'),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await _showDeleteConfirmation(context, isDarkMode);
            } else if (direction == DismissDirection.startToEnd) {
              _showEditDialog(context, todo, isDarkMode);
              return false;
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              context.read<TodoCubit>().removeTodo(todo.id);
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: todo.isCompleted 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => context.read<TodoCubit>().toggleTodo(todo.id),
                fillColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.deepPurple;
                    }
                    return null;
                  },
                ),
                shape: const CircleBorder(),
              ),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted 
                    ? (isDarkMode ? Colors.grey[500] : Colors.grey)
                    : (isDarkMode ? Colors.white : Colors.black87),
                fontSize: 16,
                fontWeight: todo.isCompleted ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            // HAPUS TOMBOL EDIT & DELETE DI TRAILING
            onTap: () => _showEditDialog(context, todo, isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Clear Completed',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Hapus semua todo yang sudah selesai?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoCubit>().clearCompleted();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, bool isDarkMode) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(
            'Hapus Todo?',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus todo ini?',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showEditDialog(BuildContext context, Todo todo, bool isDarkMode) {
    final TextEditingController controller = TextEditingController();
    controller.text = todo.title;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Todo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Edit todo...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[50],
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  autofocus: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            context.read<TodoCubit>().editTodo(todo.id, controller.text);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
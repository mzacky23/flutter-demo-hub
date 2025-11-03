import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/counter/counter_cubit.dart';
import '../../blocs/counter/counter_state.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with BLoC'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: Center(
          child: BlocBuilder<CounterCubit, CounterState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Counter Display
                  GestureDetector(
                    onTap: () => _showSetValueDialog(context, state.count),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.deepPurple.shade100,
                          width: 4,
                        ),
                      ),
                      child: Text(
                        '${state.count}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Label
                  Text(
                    'Current Count',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Status text
                  Text(
                    _getCountStatus(state.count),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons - BERJALAR DI TENGAH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset Button
                      _buildActionButton(
                        context,
                        Icons.refresh,
                        'Reset',
                        () => _showResetDialog(context),
                        Colors.grey,
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Decrement Button
                      _buildActionButton(
                        context,
                        Icons.remove,
                        'Decrease',
                        () => context.read<CounterCubit>().decrement(),
                        Colors.red,
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Increment Button
                      _buildActionButton(
                        context,
                        Icons.add,
                        'Increase',
                        () => context.read<CounterCubit>().increment(),
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.deepPurple.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Counter'),
        content: const Text('Reset counter to zero?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset menggunakan decrement/increment yang sudah ada
              final currentCount = context.read<CounterCubit>().state.count;
              if (currentCount > 0) {
                for (int i = 0; i < currentCount; i++) {
                  context.read<CounterCubit>().decrement();
                }
              } else if (currentCount < 0) {
                for (int i = 0; i > currentCount; i--) {
                  context.read<CounterCubit>().increment();
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSetValueDialog(BuildContext context, int currentValue) {
    final TextEditingController controller = TextEditingController();
    controller.text = currentValue.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Counter Value'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter value',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                // Set value menggunakan increment/decrement yang sudah ada
                final currentCount = context.read<CounterCubit>().state.count;
                final difference = value - currentCount;
                
                if (difference > 0) {
                  for (int i = 0; i < difference; i++) {
                    context.read<CounterCubit>().increment();
                  }
                } else if (difference < 0) {
                  for (int i = 0; i < difference.abs(); i++) {
                    context.read<CounterCubit>().decrement();
                  }
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Set', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getCountStatus(int count) {
    if (count == 0) return 'Tap circle to set value\nTap buttons to adjust';
    if (count > 0 && count < 10) return 'Going up! ↗';
    if (count >= 10 && count < 20) return 'Getting higher! 📈';
    if (count >= 20) return 'Wow, that\'s a big number! 🚀';
    if (count < 0 && count > -10) return 'Going down! ↘';
    return 'Negative territory! 📉';
  }
}
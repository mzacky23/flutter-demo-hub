import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_state.dart';  // ← IMPORT STATE FILE

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    emit(state.copyWith(count: state.count - 1));
  }
}
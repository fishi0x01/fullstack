part of 'counter_bloc.dart';

@immutable
abstract class CounterState extends Equatable {
  final List<Object> properties;
  CounterState(this.properties);

  @override
  List<Object> get props => this.properties;
}

class CounterInstance extends CounterState {
  final Counter counter;
  CounterInstance({@required this.counter}) : super([counter.id, counter.val, counter.name]);
}

class CounterListLoading extends CounterState {
  CounterListLoading() : super([]);
}

class CounterError extends CounterState {
  CounterError() : super([]);
}
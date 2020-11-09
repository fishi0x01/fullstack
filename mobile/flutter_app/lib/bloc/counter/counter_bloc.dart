import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_app/model/counter.dart';
import 'package:meta/meta.dart';
import 'package:flutter_app/repository/counter_repository.dart';

part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc(CounterState initialState) : super(initialState);
  final CounterRepository repo = CounterRepository.instance();
  List<Counter> counters = [];
  int idx = 0;

  void _boxIdx() {
    if(counters.length == 0) {
      idx = 0;
      return;
    }

    if(idx < 0) {
      idx = counters.length - 1;
    }
    idx = idx % counters.length;
  }

  @override
  Stream<CounterState> mapEventToState(
    CounterEvent event,
  ) async* {
    if (event is CounterIncrement && state is CounterInstance) {
      counters[idx].val += 1;
      repo.updateCounter(counters[idx]);
      yield CounterInstance(counter: counters[idx]);
    } else if (event is CounterDecrement && state is CounterInstance) {
      counters[idx].val -= 1;
      repo.updateCounter(counters[idx]);
      yield CounterInstance(counter: counters[idx]);
    } else if (event is RefreshCounterList) {
      yield CounterListLoading();
      counters = await repo.allCounters();
      _boxIdx();
      yield CounterInstance(counter: counters[idx]);
    } else if (event is CounterNext) {
      idx += 1;
      _boxIdx();
      yield CounterInstance(counter: counters[idx]);
    } else if (event is CounterPrevious) {
      idx -= 1;
      _boxIdx();
      yield CounterInstance(counter: counters[idx]);
    }
  }
}

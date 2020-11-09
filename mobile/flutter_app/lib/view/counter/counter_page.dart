import 'package:flutter/material.dart';
import 'package:flutter_app/keys/counter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/bloc/counter/counter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CounterBloc(CounterListLoading())..add(RefreshCounterList()),
      child: CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: BlocBuilder<CounterBloc, CounterState>(
          builder: (_, state) {
            String val = "Error";
            String name = "Error";
            if (state is CounterInstance) {
              val = '${state.counter.val}';
              name = '${state.counter.name}';
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(name, style: textTheme.headline2),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        key: const Key(keyCounterDecrement),
                        child: const Icon(Icons.remove),
                        onPressed: () => BlocProvider.of<CounterBloc>(context)
                            .add(CounterDecrement()),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(val,
                          key: const Key(keyCounterValue),
                          style: textTheme.headline2),
                      const SizedBox(
                        width: 8,
                      ),
                      FloatingActionButton(
                        key: const Key(keyCounterIncrement),
                        child: const Icon(Icons.add),
                        onPressed: () => BlocProvider.of<CounterBloc>(context)
                            .add(CounterIncrement()),
                      ),
                    ]),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            key: const Key('counterView_previous_floatingActionButton'),
            child: const Icon(Icons.arrow_left_rounded),
            onPressed: () =>
                BlocProvider.of<CounterBloc>(context).add(CounterPrevious()),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            key: const Key('counterView_next_floatingActionButton'),
            child: const Icon(Icons.arrow_right_rounded),
            onPressed: () =>
                BlocProvider.of<CounterBloc>(context).add(CounterNext()),
          ),
        ],
      ),
    );
  }
}

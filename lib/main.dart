import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final currentDate = Provider<DateTime>(((ref) => DateTime.now()));

class Counter extends StateNotifier<int> {
  Counter(super.state);
  void increment() => state++;
}

class NewCounter extends StateNotifier<int> {
  NewCounter(super.state);
  void increment() {
    debugPrint('date time increment');
    state++;
  }
}

final dateProvider = StateNotifierProvider<NewCounter, int>(((ref) {
  return NewCounter(1);
}));

final counterProvider = StateNotifierProvider<Counter, int>(((ref) {
  return Counter(0);
}));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build');
    return Scaffold(
      appBar: AppBar(title: Consumer(builder: (context, ref, child) {
        final date = ref.watch(dateProvider);
        return Text(date.toString());
      })),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(counterProvider);
                return Text(
                  'You have pushed the button this many times: $count',
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          ref.read(counterProvider.notifier).increment();
          ref.read(dateProvider.notifier).increment();
        }),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

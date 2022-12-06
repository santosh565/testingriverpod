import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

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

enum City {
  kathmandu,
  bhairahawa,
  pokhara,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 2),
      () => {
            City.bhairahawa: '🥵',
            City.kathmandu: '🆒',
            City.pokhara: '🌬️'
          }[city]!);
}

final currentCityProvider = StateProvider<City?>(
  (ref) {
    return null;
  },
);

final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    }
    return 'Unknown weather';
  },
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    debugPrint('build');
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final city = City.values[index];
              final isSelected = city == ref.watch(currentCityProvider);
              return ListTile(
                title: Text(city.name.toUpperCase()),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(currentCityProvider.notifier).state = city;
                },
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          currentWeather.when(
            data: (data) => Text(
              data,
              style: const TextStyle(fontSize: 50),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (Object error, StackTrace stackTrace) {
              return Text(error.toString());
            },
          ),
        ],
      ),
    );
  }
}

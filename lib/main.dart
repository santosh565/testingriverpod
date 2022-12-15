import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  EquatableConfig.stringify = true;
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
      appBar: AppBar(
        title: const Text('Films'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              debugPrint('build films widget');
              final filter = ref.watch(favouriteStatusProvider);
              switch (filter) {
                case FavouriteStatus.all:
                  return FilmsWidget(allfilmsProvider);
                case FavouriteStatus.favorite:
                  return FilmsWidget(favouriteFilmsProvider);
                case FavouriteStatus.notFavourite:
                  return FilmsWidget(notfavouriteFilmsProvider);
              }
            },
          )
        ],
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton<FavouriteStatus?>(
          value: ref.watch(favouriteStatusProvider),
          items: FavouriteStatus.values
              .map(
                (e) => DropdownMenuItem<FavouriteStatus?>(
                  value: e,
                  child: Text(e.name),
                ),
              )
              .toList(),
          onChanged: (FavouriteStatus? selectedStatus) {
            ref.read(favouriteStatusProvider.notifier).state = selectedStatus!;
          },
        );
      },
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget(this.provider, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favouriteIcon = film.isFavourite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: favouriteIcon,
            onTap: () {
              final isFavourite = !film.isFavourite;
              ref.read(allfilmsProvider.notifier).update(film, isFavourite);
            },
          );
        },
      ),
    );
  }
}

// @immutable
class Film extends Equatable {
  final String id, title, description;
  final bool isFavourite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavourite,
  });

  Film copyWith({required bool isFavourite}) => Film(
        id: id,
        title: title,
        description: description,
        isFavourite: isFavourite,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isFavourite,
      ];
}

const allFilms = [
  Film(
    id: '1',
    title: 'Title A',
    description: 'Description A',
    isFavourite: false,
  ),
  Film(
    id: '2',
    title: 'Title B',
    description: 'Description B',
    isFavourite: false,
  ),
  Film(
    id: '3',
    title: 'Title C',
    description: 'Description C',
    isFavourite: false,
  ),
  Film(
    id: '4',
    title: 'Title D',
    description: 'Description D',
    isFavourite: false,
  )
];

typedef Films = List<Film>;

class FilmsNotifier extends StateNotifier<Films> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavourite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copyWith(isFavourite: isFavourite)
            : thisFilm)
        .toList();
  }
}

enum FavouriteStatus {
  all,
  favorite,
  notFavourite,
}

final favouriteStatusProvider = StateProvider<FavouriteStatus>(
  (_) => FavouriteStatus.all,
);

final allfilmsProvider = StateNotifierProvider<FilmsNotifier, Films>(
  (_) => FilmsNotifier(),
);

final favouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allfilmsProvider).where((film) => film.isFavourite),
);

final notfavouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allfilmsProvider).where((film) => !film.isFavourite),
);

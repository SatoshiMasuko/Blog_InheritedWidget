import 'dart:js';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulWidget1(
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class _InheritedState extends InheritedWidget {
  const _InheritedState({
    required this.data,
    required super.child,
  });

  final MyHomePageState data;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class StatefulWidget1 extends StatefulWidget {

  const StatefulWidget1({
    super.key,
    required this.child,
  });

  final Widget child;

  static MyHomePageState of(BuildContext context, {bool rebuild = true}) {
    return rebuild
        ? context.dependOnInheritedWidgetOfExactType<_InheritedState>()!.data
        : (context
        .getElementForInheritedWidgetOfExactType<_InheritedState>()!
        .widget as _InheritedState)
        .data;
  }
  @override
  State<StatefulWidget1> createState() => MyHomePageState();
}


class MyHomePageState extends State<StatefulWidget1> {
  var selectedIndex = 0;
  var current = WordPair.random();

  void getNext()  => setState(() {
    current = WordPair.random();
  });
  var favorites = <WordPair>[];
  void toggleFavorite() => setState(() {
    if(favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
  });
  void changePage(int value) => setState(() {
    selectedIndex = value;
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _InheritedState(data: this, child: widget.child);
  }

}



class MyHomePage extends StatelessWidget {
  // const MyHomePage({
  //   super.key,
  //   required this.child,
  // });
  // final Widget child;

  // static MyHomePageState of(BuildContext context, {bool rebuild = true}) {
  //   return rebuild
  //       ? context.dependOnInheritedWidgetOfExactType<_InheritedState>()!.data
  //       : (context
  //       .getElementForInheritedWidgetOfExactType<_InheritedState>()!
  //       .widget as _InheritedState)
  //       .data;
  // }
  // @override
  // State<StatefulWidget1> createState() => MyHomePageState();

  @override
  Widget build(BuildContext context) {
    var selectedIndex = 0;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  StatefulWidget1.of(context).changePage(value);
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }

}



class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var pair = StatefulWidget1.of(context).current;

    IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }
    if(StatefulWidget1.of(context).favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  StatefulWidget1.of(context).toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  StatefulWidget1.of(context).getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    if (StatefulWidget1.of(context).favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${StatefulWidget1.of(context).favorites.length} favorites:'),
        ),
        for (var pair in StatefulWidget1.of(context).favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
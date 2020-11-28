import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app_bloc.dart';
import 'pages/main.dart';

class App extends StatelessWidget {
  final Jikan jikan;

  const App({Key key, @required this.jikan})
      : assert(jikan != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: BlocProvider(
          create: (context) => AppBloc(jikan: jikan)..add(AppStartFetch()),
          child: MainView()),
    );
  }
}

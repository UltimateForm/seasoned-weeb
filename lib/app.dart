import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';

import 'bloc/app/app_bloc.dart';
import 'bloc/config/config_bloc.dart';
import 'pages/main.dart';
// import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
// import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
// import 'pages/main.dart';

ThemeMode configThemeToAppThemeMode(ConfigState state) {
  if (state is ConfigLoading || state is ConfigError) {
    return ThemeMode.system;
  } else if (state is ConfigReady) {
    int themeVal = state.config[ConfigKeys.theme] ?? 0;
    return ThemeMode.values[themeVal];
  } else {
    return ThemeMode.system;
  }
}

var darkTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue[800],

  // Define the default font family.
  fontFamily: 'Georgia',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600]),
);

int initialKey = 0;

class App extends StatelessWidget {
  final Jikan jikan;

  const App({Key? key, required this.jikan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
        lazy: false,
        create: (context) =>
            AppBloc(BlocProvider.of<ConfigBloc>(context), jikan: jikan)
              ..add(AppLoad())
              ..add(AppStartFetch()),
        child: BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.deepOrange,
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Colors.deepOrangeAccent,
                    brightness: Brightness.light)),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.deepOrange,
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Colors.deepOrangeAccent,
                    brightness: Brightness.dark)
                /* dark theme settings */
                ),
            themeMode: configThemeToAppThemeMode(state),
            home: state is ConfigDataClearing
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const MainView(),
          );
        }));
  }
}

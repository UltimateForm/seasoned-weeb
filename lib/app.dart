import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import 'pages/main.dart';

ThemeMode configThemeToAppThemeMode(ConfigState state) {
  if (state is ConfigLoading || state is ConfigError) {
    return ThemeMode.system;
  } else if (state is ConfigReady) {
    int themeVal = state.config[ConfigKeys.theme] ?? 0;
    return ThemeMode.values[themeVal];
  } else
    return ThemeMode.system;
}

var darkTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue[800],
  accentColor: Colors.cyan[600],

  // Define the default font family.
  fontFamily: 'Georgia',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);

int initialKey = 0;

class App extends StatelessWidget {
  final Jikan jikan;

  const App({Key key, @required this.jikan})
      : assert(jikan != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
        create: (context) =>
            AppBloc(BlocProvider.of<ConfigBloc>(context), jikan: jikan)
              ..add(AppLoad())
              ..add(AppStartFetch()),
        child: BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.deepOrange,
                accentColor: Colors.deepOrangeAccent),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.deepOrange,
                accentColor: Colors.deepOrangeAccent
                /* dark theme settings */
                ),
            themeMode: configThemeToAppThemeMode(state),
            home: state is ConfigDataClearing
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : MainView(),
          );
        }));
  }
}

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
    print(state.config);
    int themeVal = state.config[ConfigKeys.theme] ?? 0;
    return ThemeMode.values[themeVal];
  }
}

class App extends StatelessWidget {
  final Jikan jikan;

  const App({Key key, @required this.jikan})
      : assert(jikan != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
              create: (context) => AppBloc(jikan: jikan)..add(AppStartFetch())),
          BlocProvider<ConfigBloc>(
            create: (context) => ConfigBloc(ConfigInitialState({
              ConfigKeys.adultContent: 0,
              ConfigKeys.scoreThreshold: 0,
              ConfigKeys.showScores: 0,
              ConfigKeys.theme: 0
            }))
              ..add(LoadConfig()),
          )
        ],
        child: BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, state) => MaterialApp(
                  theme: ThemeData(
                    brightness: Brightness.light,
                    /* light theme settings */
                  ),
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    /* dark theme settings */
                  ),
                  themeMode: configThemeToAppThemeMode(state),
                  home: MainView(),
                )));
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

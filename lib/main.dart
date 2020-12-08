import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'app.dart';
import './bloc/config/config_bloc.dart';
import 'bloc/simple_bloc_observer.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  Jikan jikan = Jikan();

  runApp(BlocProvider<ConfigBloc>(
      create: (context) => ConfigBloc(ConfigInitialState({
            ConfigKeys.adultContent: 0,
            ConfigKeys.scoreThreshold: 0,
            ConfigKeys.showScores: 0,
            ConfigKeys.theme: 0
          }))
            ..add(LoadConfig()),
      child: App(jikan: jikan)));
  //runApp(App(jikan: jikan));
}

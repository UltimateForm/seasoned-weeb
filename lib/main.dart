import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'app.dart';
import 'bloc/simple_bloc_observer.dart';


void main() {
  Bloc.observer = SimpleBlocObserver();
  Jikan jikan = Jikan();
  runApp(App(jikan:jikan));
}

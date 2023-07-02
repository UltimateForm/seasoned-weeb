import "package:bloc/bloc.dart";
import "package:flutter/foundation.dart";

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    if (kDebugMode) {
      print("onEvent $event");
    }
    super.onEvent(bloc, event);
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    if (kDebugMode) {
      print("onTransition $transition");
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print("onError $error");
    }
    super.onError(bloc, error, stackTrace);
  }
}

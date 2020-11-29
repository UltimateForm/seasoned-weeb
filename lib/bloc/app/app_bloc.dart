import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import "package:jikan_api/jikan_api.dart";

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState>{
  final Jikan jikan;
  AppBloc({@required this.jikan}) : assert(jikan!=null), super(AppInitialState());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if(event is AppStartFetch){
      yield AppFetching();
      try {
        final season = await jikan.getSeason(year: event.year, season: event.seasonType);
        yield AppFetchCompleted(season: season);
      } catch (e) {
        yield AppFetchFailed(failureReason: e.toString());
      }
    }
  }

}
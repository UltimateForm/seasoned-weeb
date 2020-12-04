import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import "package:jikan_api/jikan_api.dart";
import 'package:shared_preferences/shared_preferences.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final Jikan jikan;
  SharedPreferences prefs;
  AppBloc({@required this.jikan})
      : assert(jikan != null),
        super(AppInitialState());
  Iterable<AnimeItem> seasonAnime = [];
  List<int> dismissed = [];
  List<int> bookmarked = [];
  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppStartFetch) {
      yield AppFetching();
      try {
        final season =
            await jikan.getSeason(year: event.year, season: event.seasonType);
        seasonAnime = season.anime.where((a) => !a.continuing);
        yield AppFetchCompleted(bookmarked, dismissed, season: season);
      } catch (e) {
        yield AppFetchFailed(failureReason: e.toString());
      }
    }
  }
}

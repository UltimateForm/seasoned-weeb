import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import "package:jikan_api/jikan_api.dart";
import 'package:shared_preferences/shared_preferences.dart';

part 'app_event.dart';
part 'app_state.dart';

const String dismissedPrefKey = "dismissed";
const String bookmarkedPrefKey = "bookmarked";

class AppBloc extends Bloc<AppEvent, AppState> {
  final Jikan jikan;
  SharedPreferences prefs;
  AppBloc({@required this.jikan})
      : assert(jikan != null),
        super(AppInitialState());
  Iterable<AnimeItem> seasonAnime = [];
  Season season;
  List<int> dismissed = [];
  List<int> bookmarked = [];
  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (state is AppFailedToLoadData && event != AppLoad()) {
      yield AppFailedToLoadData(
          failureReason:
              "App failed to load data previously, blocking any other events that aren't AppLoad until this is fixed");
    } else if (event is AppLoad) {
      yield AppLoading();
      try {
        prefs = await SharedPreferences.getInstance();
        var rawDimissedList = prefs.getStringList(dismissedPrefKey);
        dismissed = rawDimissedList == null
            ? []
            : rawDimissedList
                .map((e) {
                  return int.tryParse(e);
                })
                .where((n) => n != null)
                .toList();
        var rawBookmarksList = prefs.getStringList(bookmarkedPrefKey);
        bookmarked = rawBookmarksList == null
            ? []
            : rawBookmarksList
                .map((e) {
                  return int.tryParse(e);
                })
                .where((n) => n != null)
                .toList();
        yield AppReady(bookmarked, dismissed, animes: null);
      } catch (e) {
        print(e.toString());
        yield AppFailedToLoadData(failureReason: e.toString());
      }
    } else if (event is AppStartFetch) {
      yield AppFetching();
      try {
        season =
            await jikan.getSeason(year: event.year, season: event.seasonType);
        seasonAnime = season.anime.where((a) => !a.continuing);
        yield AppFetchCompleted(bookmarked, dismissed, animes: seasonAnime);
      } catch (e) {
        yield AppFetchFailed(failureReason: e.toString());
      }
    } else if (event is AppBookmarkAnime) {
      bookmarked.add(event.animeId);
      yield AppSyncing(bookmarked, dismissed, animes: seasonAnime);
      await prefs.setStringList(
          bookmarkedPrefKey, bookmarked.map((e) => e.toString()).toList());
      yield AppReady(bookmarked, dismissed, animes: seasonAnime);
    } else if (event is AppDimissAnime) {
      dismissed.add(event.animeId);
      yield AppSyncing(bookmarked, dismissed, animes: seasonAnime);
      await prefs.setStringList(
          dismissedPrefKey, dismissed.map((e) => e.toString()).toList());
      yield AppReady(bookmarked, dismissed, animes: seasonAnime);
    }
  }
}

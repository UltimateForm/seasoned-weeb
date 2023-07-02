import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import "package:jikan_api/jikan_api.dart";
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config_bloc.dart';
import '../utils/constants.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final Jikan jikan;
  late SharedPreferences prefs;
  late BuiltList<Anime> season;
  List<int> dismissed = [];
  List<int> bookmarked = [];
  Map<int, Map<Type, Object>> jikanCache = <int, Map<Type, Object>>{};
  late StreamSubscription configListener;
  AppBloc(ConfigBloc configBloc, {required this.jikan})
      : super(AppInitialState()) {
    configListener = configBloc.stream.listen((ConfigState state) {
      if (state is ConfigDataCleared) {
        if (state.sectionCleared != ConfigDataSection.preferences) {
          add(AppLoad());
        }
      }
    });
    on<AppEvent>(mapEventToState, transformer: sequential());
  }

  Future<T> getCachedAnimeResponse<T>(
      Future<T> Function(int animeId) request, animeId) async {
    if (jikanCache.containsKey(animeId) &&
        jikanCache[animeId]!.containsKey(T)) {
      if (kDebugMode) {
        print("Returning cached jikan response of type $T for anime $animeId");
      }
      return jikanCache[animeId]![T] as T;
    }
    T response = await request(animeId);
    if (!jikanCache.containsKey(animeId)) {
      jikanCache[animeId] = <Type, Object>{};
    }
    jikanCache[animeId]![T] = response as Object;
    return response;
  }

  @override
  Future<void> close() async {
    await configListener.cancel();
    return super.close();
  }

  FutureOr<void> mapEventToState(AppEvent event, Emitter<AppState> emit) async {
    if (state is AppFailedToLoadData && event != AppLoad()) {
      emit(AppFailedToLoadData(
          failureReason:
              "App failed to load data previously, blocking any other events that aren't AppLoad until this is fixed"));
    } else if (event is AppLoad) {
      emit(AppLoading());
      try {
        prefs = await SharedPreferences.getInstance();
        var rawDimissedList = prefs.getStringList(dismissedPrefKey);
        dismissed = rawDimissedList == null
            ? []
            : rawDimissedList
                .map((e) {
                  return int.tryParse(e);
                })
                .whereType<int>()
                .toList();
        var rawBookmarksList = prefs.getStringList(bookmarkedPrefKey);
        bookmarked = rawBookmarksList == null
            ? []
            : rawBookmarksList
                .map((e) {
                  return int.tryParse(e);
                })
                .whereType<int>()
                .toList();
        emit(AppReady(bookmarked, dismissed, animes: const []));
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        emit(AppFailedToLoadData(failureReason: e.toString()));
      }
    } else if (event is AppStartFetch) {
      emit(AppFetching());
      try {
        season = await jikan.getSeason();
        // seasonAnime = season.where((a) => !a.continuing);
        emit(AppFetchCompleted(bookmarked, dismissed, animes: season));
      } catch (e) {
        emit(AppFetchFailed(failureReason: e.toString()));
      }
    } else if (event is AppBookmarkAnime) {
      dismissed.remove(event
          .animeId); // because we might be bookmarking from Boookmarks page chief (as Dimiss undo)
      bookmarked.add(event.animeId);
      emit(AppSyncing(bookmarked, dismissed, animes: season));
      await prefs.setStringList(
          bookmarkedPrefKey, bookmarked.map((e) => e.toString()).toList());
      emit(AppReady(bookmarked, dismissed, animes: season));
    } else if (event is AppDimissAnime) {
      bookmarked.remove(event
          .animeId); // because we might be dimissing from Boookmarks page chief
      dismissed.add(event.animeId);
      emit(AppSyncing(bookmarked, dismissed, animes: season));
      await prefs.setStringList(
          dismissedPrefKey, dismissed.map((e) => e.toString()).toList());
      emit(AppReady(bookmarked, dismissed, animes: season));
    }
  }
}

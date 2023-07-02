import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

part 'config_event.dart';
part 'config_state.dart';

enum ConfigKeys { theme, adultContent, showScores, scoreThreshold, movies }

enum ConfigDataSection { all, preferences, dimissedSeries, bookmarkedSeries }

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  Map<ConfigKeys, int> config;
  late SharedPreferences prefs;

  ConfigBloc(ConfigInitialState initialState)
      : config = Map.of(initialState.config),
        super(initialState) {
    on<ConfigEvent>(mapEventToState, transformer: sequential());
  }

  FutureOr<void> mapEventToState(
      ConfigEvent event, Emitter<ConfigState> emit) async {
    if (event is SetConfig) {
      emit(ConfigSyncing(config));
      try {
        await prefs.setInt(
            EnumToString.convertToString(event.key), event.value);
        config[event.key] = event.value;
        emit(ConfigReady(config));
      } catch (e) {
        emit(ConfigError(e.toString()));
      }
    }
    if (event is LoadConfig) {
      emit(ConfigLoading());
      try {
        prefs = await SharedPreferences.getInstance();
        for (var key in ConfigKeys.values) {
          try {
            config[key] = prefs.getInt(EnumToString.convertToString(key)) ?? 0;
          } catch (e) {
            if (kDebugMode) {
              print("Failed to apply config value for $key");
            }
          }
        }
        emit(ConfigReady(config));
      } catch (e) {
        emit(ConfigError(e.toString()));
      }
    }
    if (event is ResetPreferences) {
      emit(ConfigDataClearing(config, sectionCleared: event.sectionToReset));
      switch (event.sectionToReset) {
        case ConfigDataSection.bookmarkedSeries:
          await prefs.remove(bookmarkedPrefKey);
          break;
        case ConfigDataSection.dimissedSeries:
          await prefs.remove(dismissedPrefKey);
          break;
        case ConfigDataSection.preferences:
          for (var key in ConfigKeys.values) {
            await prefs.remove(EnumToString.convertToString(key));
          }
          break;
        default:
          await prefs.clear();
      }
      emit(ConfigDataCleared(config, sectionCleared: event.sectionToReset));
    }
  }
}

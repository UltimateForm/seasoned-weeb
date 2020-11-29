import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enum_to_string/enum_to_string.dart';

part 'config_event.dart';
part 'config_state.dart';

class Config {
  int theme;
  bool adultContent;
  bool showScores;
  int scoreThreshold;
}

enum ConfigKeys { theme, adultContent, showScores, scoreThreshold }

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  Map<ConfigKeys, int> config;
  SharedPreferences prefs;

  ConfigBloc(ConfigInitialState initialState) : super(initialState) {
    config = initialState.config;
  }

  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) async* {
    if (event is SetConfig) {
      yield ConfigSyncing(config);
      try {
        await prefs.setInt(
            EnumToString.convertToString(event.key), event.value);
        config[event.key] = event.value;
        yield ConfigReady(config);
      } catch (e) {
        yield ConfigError(e.toString());
      }
    }
    if (event is LoadConfig) {
      yield ConfigLoading();
      try {
        prefs = await SharedPreferences.getInstance();
        for (var key in ConfigKeys.values) {
          try {
            config[key] = prefs.getInt(EnumToString.convertToString(key));
          } catch (e) {
            print("Failed to apply config value for $key");
          }
        }
        yield ConfigReady(config);
      } catch (e) {
        yield ConfigError(e.toString());
      }
    }
  }
}

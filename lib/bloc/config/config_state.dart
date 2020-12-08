part of "config_bloc.dart";

@immutable
abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object> get props => [];
}

class ConfigLoading extends ConfigState {}

class ConfigReady extends ConfigState {
  final Map<ConfigKeys, int> config;

  ConfigReady(this.config);
  @override
  List<Object> get props => [config];
}

class ConfigSyncing extends ConfigReady {
  ConfigSyncing(Map<ConfigKeys, int> config) : super(config);

  @override
  List<Object> get props => [];
}

class ConfigInitialState extends ConfigReady {
  ConfigInitialState(Map<ConfigKeys, int> config) : super(config);
  @override
  List<Object> get props => [];
}

class ConfigError extends ConfigState {
  final String error;

  ConfigError(this.error);

  @override
  List<Object> get props => [error];
}

class ConfigDataClearing extends ConfigSyncing {
  final ConfigDataSection sectionCleared;
  ConfigDataClearing(Map<ConfigKeys, int> config,
      {@required this.sectionCleared})
      : super(config);

  @override
  List<Object> get props => [sectionCleared, config];
}

class ConfigDataCleared extends ConfigReady {
  final ConfigDataSection sectionCleared;
  ConfigDataCleared(Map<ConfigKeys, int> config,
      {@required this.sectionCleared})
      : super(config);

  @override
  List<Object> get props => [sectionCleared, config];
}

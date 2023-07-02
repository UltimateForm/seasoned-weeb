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

  const ConfigReady(this.config);
  @override
  List<Object> get props => [config];
}

class ConfigSyncing extends ConfigReady {
  const ConfigSyncing(Map<ConfigKeys, int> config) : super(config);

  @override
  List<Object> get props => [];
}

class ConfigInitialState extends ConfigReady {
  const ConfigInitialState(Map<ConfigKeys, int> config) : super(config);
  @override
  List<Object> get props => [];
}

class ConfigError extends ConfigState {
  final String error;

  const ConfigError(this.error);

  @override
  List<Object> get props => [error];
}

class ConfigDataClearing extends ConfigSyncing {
  final ConfigDataSection sectionCleared;
  const ConfigDataClearing(Map<ConfigKeys, int> config,
      {required this.sectionCleared})
      : super(config);

  @override
  List<Object> get props => [sectionCleared, config];
}

class ConfigDataCleared extends ConfigReady {
  final ConfigDataSection sectionCleared;
  const ConfigDataCleared(Map<ConfigKeys, int> config,
      {required this.sectionCleared})
      : super(config);

  @override
  List<Object> get props => [sectionCleared, config];
}

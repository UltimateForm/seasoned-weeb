part of "config_bloc.dart";

@immutable
abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object> get props => [];
}


class LoadConfig extends ConfigEvent {}

class SetConfig extends ConfigEvent {
  final ConfigKeys key;
  final int value;

  SetConfig(this.key, this.value);

  @override
  List<Object> get props => [key, value];
}
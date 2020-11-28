part of 'app_bloc.dart';

@immutable
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitialState extends AppState {}

class AppFetching extends AppState {}

class AppFetchCompleted extends AppState {
  final Season season;
  const AppFetchCompleted({@required this.season}) : assert(season != null);

  @override
  List<Object> get props => [season];
}

class AppFetchFailed extends AppState {
  final String failureReason;

  AppFetchFailed({@required this.failureReason})
      : assert(failureReason != null && failureReason.isNotEmpty);

  @override
  List<Object> get props => [failureReason];
}

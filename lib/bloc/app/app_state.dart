part of 'app_bloc.dart';

@immutable
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitialState extends AppState {}

class AppFetching extends AppState {}

class AppReady extends AppState {
  final Season season;
  final Iterable<int> bookmarks;
  final Iterable<int> dismissed;
  const AppReady(this.bookmarks, this.dismissed, {@required this.season})
      : assert(season != null);

  @override
  List<Object> get props => [season];
}

class AppSyncing extends AppState {}

class AppFetchCompleted extends AppReady {
  const AppFetchCompleted(Iterable<int> bookmarks, Iterable<int> dismissed,
      {@required Season season})
      : assert(season != null),
        super(bookmarks, dismissed, season: season);
}

class AppFetchFailed extends AppState {
  final String failureReason;

  AppFetchFailed({@required this.failureReason})
      : assert(failureReason != null && failureReason.isNotEmpty);

  @override
  List<Object> get props => [failureReason];
}

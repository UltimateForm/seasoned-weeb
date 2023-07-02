part of 'app_bloc.dart';

@immutable
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitialState extends AppState {}

class AppFetching extends AppState {}

class AppLoading extends AppState {}

class AppReady extends AppState {
  final Iterable<Anime> animes;
  final Iterable<int> bookmarks;
  final Iterable<int> dismissed;
  const AppReady(this.bookmarks, this.dismissed, {required this.animes});

  @override
  List<Object> get props => [bookmarks, dismissed, animes];
}

class AppSyncing extends AppReady {
  const AppSyncing(Iterable<int> bookmarks, Iterable<int> dismissed,
      {required Iterable<Anime> animes})
      : super(bookmarks, dismissed, animes: animes);
}

class AppFetchCompleted extends AppReady {
  const AppFetchCompleted(Iterable<int> bookmarks, Iterable<int> dismissed,
      {required Iterable<Anime> animes})
      : super(bookmarks, dismissed, animes: animes);
}

class AppFailure extends AppState {
  final String failureReason;

  AppFailure({required this.failureReason}) : assert(failureReason.isNotEmpty);

  @override
  List<Object> get props => [failureReason];
}

class AppFetchFailed extends AppFailure {
  AppFetchFailed({required String failureReason})
      : super(failureReason: failureReason);
}

class AppFailedToLoadData extends AppFailure {
  AppFailedToLoadData({required String failureReason})
      : super(failureReason: failureReason);
}

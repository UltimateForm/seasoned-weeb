part of 'app_bloc.dart';

@immutable
abstract class AppEvent extends Equatable {
  const AppEvent();
}

class AppStartFetch extends AppEvent {
  final int year;
  final SeasonType seasonType;

  AppStartFetch([this.year, this.seasonType]);

  @override
  List<Object> get props => [year, seasonType];
}

class AppBookmarkAnime extends AppEvent {
  final Anime anime;

  AppBookmarkAnime({@required this.anime}) : assert(anime != null);

  @override
  List<Object> get props => [anime];
}

class AppUnbookmarkAnime extends AppEvent {
  final Anime anime;

  AppUnbookmarkAnime({@required this.anime}) : assert(anime != null);

  @override
  List<Object> get props => [anime];
}

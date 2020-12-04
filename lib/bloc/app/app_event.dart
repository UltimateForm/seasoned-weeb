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
  final int animeId;

  AppBookmarkAnime({@required this.animeId}) : assert(animeId != null);

  @override
  List<Object> get props => [animeId];
}

class AppUnbookmarkAnime extends AppEvent {
  final Anime animeId;

  AppUnbookmarkAnime({@required this.animeId}) : assert(animeId != null);

  @override
  List<Object> get props => [animeId];
}

class AppDimissAnime extends AppEvent {
  final Anime animeId;

  AppDimissAnime({@required this.animeId}) : assert(animeId != null);

  @override
  List<Object> get props => [animeId];
}
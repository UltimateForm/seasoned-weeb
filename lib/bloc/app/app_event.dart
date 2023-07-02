part of 'app_bloc.dart';

@immutable
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStartFetch extends AppEvent {}

class AppBookmarkAnime extends AppEvent {
  final int animeId;

  const AppBookmarkAnime({required this.animeId});

  @override
  List<Object> get props => [animeId];
}

class AppUnbookmarkAnime extends AppEvent {
  final int animeId;

  const AppUnbookmarkAnime({required this.animeId});

  @override
  List<Object> get props => [animeId];
}

class AppDimissAnime extends AppEvent {
  final int animeId;

  const AppDimissAnime({required this.animeId});

  @override
  List<Object> get props => [animeId];
}

class AppLoad extends AppEvent {}

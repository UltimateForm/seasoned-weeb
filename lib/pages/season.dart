import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:tcard/tcard.dart';

import '../bloc/app/app_bloc.dart';
import '../bloc/config/config_bloc.dart';
import '../components/series_card.dart';

// ignore: must_be_immutable
class SeasonPage extends StatelessWidget {
  final TCardController _controller = TCardController();
  List<Anime> _seasonAnimes = [];
  SeasonPage({super.key});

  List<Widget> _buildList(Iterable<Anime> animes, Iterable<int> bookmarkedAnime,
      Iterable<int> dismissedAnime, BuildContext context) {
    _seasonAnimes = animes.toList();
    // ignore: close_sinks
    ConfigBloc config = BlocProvider.of<ConfigBloc>(context);
    // filter adult content
    if (config.config[ConfigKeys.adultContent] == 1) {
      //@TODO: fix this, inspect
      _seasonAnimes = _seasonAnimes.where((a) => a.rating != "r18").toList();
    }
    // filter score thresshold
    if (config.config[ConfigKeys.scoreThreshold] != null) {
      _seasonAnimes = _seasonAnimes
          .where((a) =>
              a.score == null ||
              a.score! >= (config.config[ConfigKeys.scoreThreshold] ?? 0) + 1)
          .toList();
    }

    // filter movies
    if (config.config[ConfigKeys.movies] != null &&
        config.config[ConfigKeys.movies] == 1) {
      _seasonAnimes = _seasonAnimes.where((a) => a.type != "Movie").toList();
    }

    // filter dismissed and bookmarked
    List<int> skippedIds = [...bookmarkedAnime, ...dismissedAnime];
    _seasonAnimes =
        _seasonAnimes.where((a) => !skippedIds.contains(a.malId)).toList();
    return List.generate(_seasonAnimes.length, (index) {
      return SeriesCard(
        key: Key(_seasonAnimes[index].malId.toString()),
        anime: _seasonAnimes[index],
        parentController: _controller,
        index: index,
      );
    });
  }

  _onSwiped(int index, SwipInfo swipeInfo, BuildContext context) {
    // ignore: close_sinks
    var bloc = BlocProvider.of<AppBloc>(context);
    var swipedAnime = _seasonAnimes[
        0]; //always 0 because this screen is refreshed everytime you swipe, and _buildList gives us new updated list without the dimissed/bookmarked ones ;O
    if (kDebugMode) {
      print(
          "Swiped ${swipedAnime.title} to ${swipeInfo.direction}, swipeInfo card index:${swipeInfo.cardIndex}, method index:$index");
    }
    if (swipeInfo.direction == SwipDirection.Left) {
      bloc.add(AppDimissAnime(animeId: swipedAnime.malId));
    }
    if (swipeInfo.direction == SwipDirection.Right) {
      // i know i can ternary magic here, just let me be readable for now
      bloc.add(AppBookmarkAnime(animeId: swipedAnime.malId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppInitialState) {
          return const AlertDialog(
              title: Text(
                  "Something went wrong that prevented app to initialize :("));
        }
        if (state is AppFetching || state is AppLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AppReady) {
          var animeCards = _buildList(
              state.animes, state.bookmarks, state.dismissed, context);
          return SafeArea(
            child: animeCards.isNotEmpty
                ? TCard(
                    controller: _controller,
                    onForward: (index, info) => _onSwiped(index, info, context),
                    size: const Size(400, 600),
                    cards: animeCards)
                : const Center(child: Text("Nothing to Show")),
          );
        }
        if (state is AppFetchFailed) {
          return AlertDialog(
              title: Text(
                  "It seems like the app failed to download necessary data over the internet, make sure you're connected to the internet",
                  style: Theme.of(context).textTheme.bodyLarge));
        }
        if (state is AppFailedToLoadData) {
          return AlertDialog(
              title: Text(
                  "It seems like the app failed to load saved data :/\nTry restarting the application",
                  style: Theme.of(context).textTheme.bodyLarge));
        } else {
          return AlertDialog(
              title: Text("Uh oh, something went wrong...",
                  style: Theme.of(context).textTheme.bodyLarge));
        }
      },
    );
  }
}

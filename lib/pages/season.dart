import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import 'package:seasonal_weeb/components/series_card.dart';
import 'package:tcard/tcard.dart';

// ignore: must_be_immutable
class SeasonPage extends StatelessWidget {
  final TCardController _controller = TCardController();
  List<AnimeItem> _seasonAnimes = [];
  SeasonPage() : super();

  List<Widget> _buildList(Iterable<AnimeItem> animes, List<int> bookmarkedAnime,
      List<int> dismissedAnime, BuildContext context) {
    _seasonAnimes = animes.toList();
    // ignore: close_sinks
    ConfigBloc config = BlocProvider.of<ConfigBloc>(context);
    // filter adult content
    if (config.config[ConfigKeys.adultContent] == 1) {
      _seasonAnimes = _seasonAnimes.where((a) => !a.r18).toList();
    }
    // filter score thresshold
    if (config.config[ConfigKeys.scoreThreshold] != null) {
      _seasonAnimes = _seasonAnimes
          .where((a) =>
              a.score == null ||
              a.score >= config.config[ConfigKeys.scoreThreshold] + 1)
          .toList();
    }

    // filter dismissed and bookmarked
    List<int> skippedIds = bookmarkedAnime + dismissedAnime;
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
    var swipedAnime = _seasonAnimes[swipeInfo.cardIndex];
    print("Swiped ${swipedAnime.title} to ${swipeInfo.direction}");
    if (swipeInfo.direction == SwipDirection.Left) {
      bloc.add(AppDimissAnime(animeId: swipedAnime.malId));
    }
    if (swipeInfo.direction == SwipDirection.Right) {
      // i know i can ternary magic here, just let me be readable for now
      bloc.add(AppBookmarkAnime(animeId: swipedAnime.malId));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppInitialState) {
          return AlertDialog(
              title: Text(
                  "Something went wrong that prevented app to initialize :("));
        }
        if (state is AppFetching || state is AppLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AppReady) {
          return SafeArea(
                      child: TCard(
                controller: _controller,
                onForward: (index, info) => _onSwiped(index, info, buildContext),
                size: Size(400, 600),
                cards: _buildList(
                    state.animes, state.bookmarks, state.dismissed, context)),
          );
        }
        if (state is AppFetchFailed) {
          return AlertDialog(
              title: Text(
                  "It seems like the app failed to download necessary data over the internet, make sure you're connected to the internet",
                  style: Theme.of(context).textTheme.bodyText1));
        }
        if (state is AppFailedToLoadData) {
          return AlertDialog(
              title: Text(
                  "It seems like the app failed to load saved data :/\nTry restarting the application",
                  style: Theme.of(context).textTheme.bodyText1));
        } else
          return AlertDialog(
              title: Text("Uh oh, something went wrong...",
                  style: Theme.of(context).textTheme.bodyText1));
      },
    );
  }
}

import 'dart:async';
import 'package:equatable/equatable.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import './bookmark_detail.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

@immutable
class CompletionData extends Equatable {
  final int airedEpisodes;
  final int totalEpisodes;
  final bool airing;

  CompletionData(this.airedEpisodes, this.totalEpisodes, this.airing);

  double getFraction() {
    return airedEpisodes / totalEpisodes;
  }

  @override
  List<Object> get props => [airedEpisodes, totalEpisodes, airing];
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Anime> loadedAnimes = [];
  StreamSubscription _animeStreamSubscription;
  Map<int, CompletionData> animeCompletionData = {};

  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    Iterable<int> ids = bloc.seasonAnime.take(10).map((e) => e.malId);
    _animeStreamSubscription = _animeStream(ids).listen((event) {
      if (this.mounted)
        setState(() {
          loadedAnimes.add(event);
        });
      _getCompletionDataForAnime(event).then((value) {
        if (this.mounted)
          setState(() {
            animeCompletionData[event.malId] = value;
          });
      });
    });
  }

  @override
  void dispose() {
    _animeStreamSubscription?.cancel();
    super.dispose();
  }

  pushToDetails(Anime item, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                  body: BookmarkDetail(
                anime: item,
                airedEpisodesCount:
                    animeCompletionData[item.malId].airedEpisodes,
              ))),
    );
  }

  Future<CompletionData> _getCompletionDataForAnime(Anime anime) async {
    // ignore: close_sinks
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    var episodes = await bloc.jikan.getAnimeEpisodes(anime.malId);
    return CompletionData(episodes.length, anime.episodes, anime.airing);
  }

  Stream<Anime> _animeStream(Iterable<int> animeIds) async* {
    // ignore: close_sinks
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    for (var id in animeIds) {
      Anime actualAnime = await bloc.jikan.getAnimeInfo(id);
      yield actualAnime;
    }
  }

  Widget _getCompletionIndicator(Anime anime) {
    ThemeData theme = Theme.of(context);
    CompletionData data = animeCompletionData[anime.malId];
    if (data == null) return CircularProgressIndicator();
    String percentageTxt = "?";
    int percentage = 0;
    try {
      percentage = (data.getFraction() * 100).round();
      percentageTxt = "${anime.airing ? percentage.toString() : "100"}%";
    } catch (e) {}
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          child: Text(
            percentageTxt,
            style: theme.textTheme.caption,
          ),
          backgroundColor: theme.canvasColor,
        ),
        CircularProgressIndicator(value: percentage / 100),
      ],
    );
  }

  Widget _buildList(Iterable<AnimeItem> items, BuildContext context) {
    // ignore: close_sinks
    return ListView.separated(
      itemCount: 10,
      itemBuilder: (ctnxt, index) {
        if (index >= loadedAnimes.length)
          return SizedBox(
            child: ListTile(trailing: CircularProgressIndicator()),
            height: 70,
            width: double.infinity,
          );
        Anime e = loadedAnimes[index];
        return Stack(
          key: Key(e.malId.toString()),
          children: [
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: Hero(
                  child: Image.network(
                    e.imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                  tag: e.malId,
                ),
              ),
            ),
            ListTile(
                dense: true,
                onTap: () => pushToDetails(
                    loadedAnimes
                        .firstWhere((element) => element.malId == e.malId),
                    context),
                title: Text(e.title),
                subtitle: e.genres.length > 0 ? Text(e.genres[0].name) : null,
                trailing: _getCompletionIndicator(e))
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
        indent: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      if (state is AppInitialState) {
        return AlertDialog(
            title: Text(
                "Something went wrong that prevented app to initialize :("));
      }
      if (state is AppFetching) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state is AppReady) {
        return _buildList(state.season.anime.take(10), buildContext);
      }
      if (state is AppFetchFailed) {
        return Text(state.failureReason, style: TextStyle(color: Colors.red));
      } else
        return AlertDialog(
            title: Text("Uh oh, something went wrong...",
                style: Theme.of(context).textTheme.bodyText1));
    });
  }
}

import 'dart:async';
import 'dart:ffi';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import '../bloc/app/app_bloc.dart';
import 'bookmark_detail.dart';

// #TODO: refactor this whole mess wtf, the way I'm handling the swipe-2-dismiss here is not pretty, and probably not optimal and don't even get me started on the undo
// fix this

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  BookmarksPageState createState() => BookmarksPageState();
}

@immutable
class CompletionData extends Equatable {
  final int airedEpisodes;
  final int totalEpisodes;
  final bool airing;

  const CompletionData(this.airedEpisodes, this.totalEpisodes, this.airing);

  double getFraction() {
    return airedEpisodes / totalEpisodes;
  }

  @override
  List<Object> get props => [airedEpisodes, totalEpisodes, airing];
}

class BookmarksPageState extends State<BookmarksPage> {
  List<Anime> loadedAnimes = [];
  StreamSubscription? _animeStreamSubscription;
  Map<int, CompletionData> animeCompletionData = {};
  // ignore: close_sinks
  late AppBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AppBloc>(context);
    Iterable<int> ids = bloc.bookmarked;
    _refreshListener(ids);
  }

  void _refreshListener(Iterable<int> ids) {
    _animeStreamSubscription?.cancel();
    _animeStreamSubscription = _animeStream(ids).listen((event) {
      if (mounted) {
        setState(() {
          loadedAnimes.add(event);
        });
      }
      _getCompletionDataForAnime(event).then((value) {
        if (mounted) {
          setState(() {
            animeCompletionData[event.malId] = value;
          });
        }
      });
      if (loadedAnimes.length >= ids.length) {
        _animeStreamSubscription?.cancel();
        _animeStreamSubscription = null;
      }
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
                    animeCompletionData[item.malId]?.airedEpisodes ?? 0,
              ))),
    );
  }

  Future<CompletionData> _getCompletionDataForAnime(Anime anime) async {
    // ignore: close_sinks
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    var episodes = await bloc.getCachedAnimeResponse(
        bloc.jikan.getAnimeEpisodes, anime.malId);
    return CompletionData(episodes.length, anime.episodes ?? 0, anime.airing);
  }

  Stream<Anime> _animeStream(Iterable<int> animeIds) async* {
    // ignore: close_sinks
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    for (var id in animeIds.where(
        (element) => !loadedAnimes.any((anime) => anime.malId == element))) {
      Anime actualAnime =
          await bloc.getCachedAnimeResponse(bloc.jikan.getAnime, id);
      yield actualAnime;
    }
  }

  Widget _getCompletionIndicator(Anime anime) {
    ThemeData theme = Theme.of(context);
    CompletionData? data = animeCompletionData[anime.malId];
    if (data == null) return const CircularProgressIndicator();
    String percentageTxt = "?";
    int percentage = 0;
    bool probablyNotYetAired = anime.status?.toLowerCase() == "not yet aired" ||
        anime.episodes == null;
    if (!anime.airing && !probablyNotYetAired) {
      percentage = 100;
      percentageTxt = "100%";
    } else if (data.airedEpisodes > 0) {
      try {
        percentage = (data.getFraction() * 100).round();
        percentageTxt = "${percentage.toString()}%";
      } catch (e) {
        if (kDebugMode) {
          print('Error occured while trying to get completion indicator:\n $e');
        }
      }
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: theme.canvasColor,
          child: Text(
            percentageTxt,
            style: theme.textTheme.bodySmall,
          ),
        ),
        CircularProgressIndicator(value: percentage / 100),
      ],
    );
  }

  String _getThatStringWeTalkedAboutTheFamilarCaptionOnTheBottomOfTheList(
      int bookmarksLength) {
    if (bookmarksLength < 3) return "well maybe this season just ain't it...";
    if (bookmarksLength < 5) return "hmm yes, this is a gourmet selection";
    if (bookmarksLength < 10) return "that's a lot of weeb";
    if (bookmarksLength < 20) return "i mean...it's your time...";
    return "you weeb";
  }

  Widget _buildList(Iterable<int> bookmarks, BuildContext context) {
    ThemeData theme = Theme.of(context);
    // ignore: close_sinks
    return ListView.separated(
      itemCount: bookmarks.length +
          1, //no worries, always has something if it gets to this point
      itemBuilder: (ctnxt, index) {
        if (index == bookmarks.length) {
          return SizedBox(
            height: 70,
            width: double.infinity,
            child: ListTile(
                title: Text(
              _getThatStringWeTalkedAboutTheFamilarCaptionOnTheBottomOfTheList(
                  bookmarks.length),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            )),
          );
        }
        if (index >= loadedAnimes.length) {
          return const SizedBox(
            height: 70,
            width: double.infinity,
            child: ListTile(trailing: CircularProgressIndicator()),
          );
        }

        Anime e = loadedAnimes[index];
        return Dismissible(
            onDismissed: (direction) {
              if (kDebugMode) {
                print("Dismissing ${e.malId}");
              }
              bloc.add(AppDimissAnime(animeId: e.malId));
              loadedAnimes.removeAt(index);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("${e.title} dismissed"),
                  action: SnackBarAction(
                      label: "Undo",
                      onPressed: () =>
                          bloc.add(AppBookmarkAnime(animeId: e.malId)))));
            },
            key: Key("${e.malId}-dismissible"),
            child: Stack(
              key: Key(e.malId.toString()),
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: Hero(
                      tag: e.malId,
                      child: Image.network(
                        e.imageUrl,
                        fit: BoxFit.fitWidth,
                      ),
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
                    subtitle: e.genres.isNotEmpty
                        ? Text(
                            "${e.genres[0].name}${e.genres.length > 1 ? ", ${e.genres[1].name}" : ""}")
                        : null,
                    trailing: _getCompletionIndicator(e))
              ],
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
          indent: 0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(buildWhen: (previous, current) {
      if (previous is AppReady && current is AppSyncing) {
        return false;
      }
      if (current is AppReady) {
        if (kDebugMode) {
          print("bookmarks ${current.bookmarks.join(";")}");
        }
      }
      return true;
    }, builder: (context, state) {
      if (state is AppInitialState) {
        return const AlertDialog(
            title: Text(
                "Something went wrong that prevented app to initialize :("));
      }
      if (state is AppFetching) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state is AppReady) {
        if (state.bookmarks.isEmpty) {
          return const Center(
            child: Icon(
              Icons.turned_in_not_outlined,
              size: 70,
            ),
          );
        }
        if (_animeStreamSubscription == null &&
            state.bookmarks.length > loadedAnimes.length) {
          if (kDebugMode) {
            print(
                "state.bookmarks.length > loadedAnimes.length so we're restarting anime stream");
          } // k
          _refreshListener(state.bookmarks);
        }
        return _buildList(state.bookmarks, context);
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
    });
  }
}

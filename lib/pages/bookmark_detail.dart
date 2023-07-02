import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';

import '../bloc/app/app_bloc.dart';
import '../bloc/config/config_bloc.dart';
import '../components/genres_chips.dart';

class BookmarkDetail extends StatefulWidget {
  final Anime anime;
  final int airedEpisodesCount;

  const BookmarkDetail(
      {super.key, required this.anime, required this.airedEpisodesCount});

  @override
  BookmarkDetailState createState() => BookmarkDetailState();
}

class BookmarkDetailState extends State<BookmarkDetail> {
  List<ImageProvider> images = [];
  int currentImage = 0;
  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    var bloc = BlocProvider.of<AppBloc>(context);
    bloc
        .getCachedAnimeResponse(bloc.jikan.getAnimePictures, widget.anime.malId)
        .then((value) async {
      final networkImages = value.reversed
          .map((p) => p.largeImageUrl)
          .whereType<String>()
          .toSet()
          .map((url) => NetworkImage(url))
          .toList();
      for (var i = 0; i < networkImages.length; i++) {
        if (i == 0) {
          await precacheImage(networkImages[i], context);
        } else {
          precacheImage(networkImages[i], context);
        }
      }
      if (mounted) {
        setState(() {
          images = networkImages;
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  void _settingModalBottomSheet(context) {
    ThemeData theme = Theme.of(context);
    // ignore: close_sinks
    ConfigBloc config = BlocProvider.of<ConfigBloc>(context);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.anime.title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.anime.episodes != null)
                      Column(
                        children: [
                          Text(
                            "${widget.anime.episodes} episodes",
                            style: theme.textTheme.titleLarge,
                          ),
                          if (widget.airedEpisodesCount > 0)
                            Text(
                                "${widget.anime.airing ? widget.airedEpisodesCount.toString() : "All"} aired",
                                style: theme.textTheme.titleMedium)
                        ],
                      ),
                    GenresChips(genres: widget.anime.genres)
                  ],
                ),
              ),
              if (config.config[ConfigKeys.showScores] == null ||
                  config.config[ConfigKeys.showScores] == 0)
                Align(
                  alignment: Alignment.topRight,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        child: Text(
                            (widget.anime.score?.toInt() ?? "?").toString(),
                            style: theme.textTheme.bodyMedium)),
                  ),
                )
            ],
          );
        });
  }

  _setNextPicture() {
    if (images.isEmpty) return;
    setState(() {
      currentImage = currentImage + 1 >= images.length ? 0 : currentImage + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: InkWell(
        onLongPress: () => _settingModalBottomSheet(context),
        onTap: () => _setNextPicture(),
        child: Hero(
          tag: widget.anime.malId,
          child: images.isNotEmpty
              ? Image(
                  image: images[currentImage],
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.center,
                )
              : Image.network(
                  widget.anime.imageUrl,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.center,
                ),
        ),
      ),
    );
  }
}

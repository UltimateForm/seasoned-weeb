import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:tcard/tcard.dart';

import '../bloc/app/app_bloc.dart';
import '../bloc/config/config_bloc.dart';
import 'genres_chips.dart';

class SeriesCard extends StatefulWidget {
  final Anime anime;
  final int index;
  final TCardController parentController;

  const SeriesCard(
      {super.key,
      required this.anime,
      required this.parentController,
      required this.index});

  @override
  State<StatefulWidget> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  int activePicture = 0;
  List<ImageProvider> images = [];
  bool showInfo = false;
  late ThemeData theme;
  //ignore: close_sinks
  late ConfigBloc config;
  @override
  void initState() {
    super.initState();
    if (widget.index == widget.parentController.index) {
      //ignore: close_sinks
      var bloc = BlocProvider.of<AppBloc>(context);
      bloc
          .getCachedAnimeResponse(
              bloc.jikan.getAnimePictures, widget.anime.malId)
          .then((value) async {
        final networkImages = value.reversed
            .map((p) => p.largeImageUrl)
            .toSet()
            .whereType<String>()
            .map((url) => NetworkImage(url))
            .toList();
        for (var i = 0; i < networkImages.length; i++) {
          if (i == 0) {
            await precacheImage(networkImages[i], context);
          } else {
            precacheImage(networkImages[i], context);
          }
        }
        setState(() {
          images = networkImages;
        });
      }).catchError((error) {
        if (kDebugMode) {
          print(error);
        }
        setState(() {
          images = [];
        });
      });
    }
    config = BlocProvider.of<ConfigBloc>(context);
  }

  List<Widget> _createGalleryIndicators(int length) {
    ThemeData theme = Theme.of(context);
    return [
      for (var i = 0; i < length; i++)
        Expanded(
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: SizedBox.fromSize(
                  size: const Size(double.infinity, 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                        color: activePicture == i
                            ? theme.primaryColor.withAlpha(100)
                            : theme.colorScheme.background.withAlpha(100),
                        borderRadius: BorderRadius.circular(16)),
                  ))),
        )
    ];
  }

  _nextPicture() {
    setState(() {
      activePicture =
          activePicture >= images.length - 1 ? 0 : activePicture + 1;
    });
  }

  _toggleInfo() {
    setState(() {
      showInfo = !showInfo;
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    theme = Theme.of(context);
    return GestureDetector(
        onLongPressStart: (s) => _toggleInfo(),
        onLongPressEnd: (s) => _toggleInfo(),
        child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: _nextPicture,
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: images.isNotEmpty
                            ? images[activePicture]
                            : NetworkImage(widget.anime.imageUrl),
                        fit: BoxFit.cover),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 23,
                          offset: Offset(0, 11),
                          spreadRadius: -13.0,
                          color: Colors.black54)
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _createGalleryIndicators(
                              images.length == 1 ? 0 : images.length)),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: showInfo ? 1 : 0,
                        child: Container(
                            color: theme.colorScheme.background.withAlpha(130),
                            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.anime.title,
                                  style: theme.textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(),
                                if (config.config[ConfigKeys.showScores] ==
                                        null ||
                                    config.config[ConfigKeys.showScores] == 0)
                                  Stack(
                                    fit: StackFit.loose,
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 100,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      Text(
                                        widget.anime.score == null
                                            ? "?"
                                            : widget.anime.score.toString(),
                                        style: theme.textTheme.bodyMedium,
                                      )
                                    ],
                                  ),
                                const Divider(),
                                GenresChips(genres: widget.anime.genres),
                              ],
                            )),
                      ),
                      Container(
                        color: Colors.red,
                        child:
                            Text(widget.anime.episodes?.toString() ?? "NO EPS"),
                      )
                    ],
                  ),
                ))));
  }
}

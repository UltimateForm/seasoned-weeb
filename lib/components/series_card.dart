import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import 'package:tcard/tcard.dart';

class SeriesCard extends StatefulWidget {
  const SeriesCard({Key key, this.anime, this.parentController, this.index})
      : super(key: key);

  final AnimeItem anime;
  final int index;
  final TCardController parentController;

  @override
  State<StatefulWidget> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  int activePicture = 0;
  List<ImageProvider> images;
  bool showInfo = false;
  ThemeData theme;
  //ignore: close_sinks
  ConfigBloc config;
  @override
  void initState() {
    super.initState();
    if (widget.index == widget.parentController.index) {
      BlocProvider.of<AppBloc>(context)
          .jikan
          .getAnimePictures(widget.anime.malId)
          .then((value) async {
        final networkImages =
            value.reversed.map((p) => p.large).toSet().map((url) {
          final img = NetworkImage(url);
          return img;
        }).toList();
        for (var i = 0; i < networkImages.length; i++) {
          if (i == 0)
            await precacheImage(networkImages[i], context);
          else
            precacheImage(networkImages[i], context);
        }
        setState(() {
          images = networkImages;
        });
      }).catchError((error) => print(error));
    }
    config = BlocProvider.of<ConfigBloc>(context);
  }

  List<Widget> _createGalleryIndicators(int length) {
    ThemeData theme = Theme.of(context);
    return [
      for (var i = 0; i < length; i++)
        Expanded(
          child: Padding(
              padding: EdgeInsets.all(5),
              child: SizedBox.fromSize(
                  size: Size(double.infinity, 10),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                        color: activePicture == i
                            ? theme.primaryColor.withAlpha(100)
                            : theme.backgroundColor.withAlpha(100),
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
    theme = Theme.of(this.context);
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
                        image: images != null && images.length > 0
                            ? images[activePicture]
                            : NetworkImage(widget.anime.imageUrl),
                        fit: BoxFit.cover),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
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
                              images == null || images.length == 1
                                  ? 0
                                  : images.length)),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: showInfo ? 1 : 0,
                        child: Container(
                            color: theme.backgroundColor.withAlpha(130),
                            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.anime.title,
                                  style: theme.textTheme.headline4,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Divider(),
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
                                        color: theme.accentColor,
                                      ),
                                      Text(
                                        widget.anime.score.toString(),
                                        style: theme.textTheme.bodyText2,
                                      )
                                    ],
                                  ),
                                Divider(),
                                Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    runSpacing: 5,
                                    spacing: 5,
                                    children: widget.anime.genres
                                        .map(
                                          (genre) => Chip(
                                              label: Text(
                                                genre.name,
                                                style:
                                                    theme.textTheme.bodyText1,
                                              ),
                                              avatar: genre.imageUrl != null
                                                  ? Image.network(
                                                      genre.imageUrl)
                                                  : null,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap),
                                        )
                                        .toList())
                              ],
                            )),
                      )
                    ],
                  ),
                ))));
  }
}

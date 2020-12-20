import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import 'package:seasonal_weeb/components/genres_chips.dart';

class BookmarkDetail extends StatefulWidget {
  final Anime anime;
  final int airedEpisodesCount;

  const BookmarkDetail({Key key, @required this.anime, this.airedEpisodesCount})
      : super(key: key);

  @override
  _BookmarkDetailState createState() => _BookmarkDetailState();
}

class _BookmarkDetailState extends State<BookmarkDetail> {
  List<ImageProvider> images = [];
  int currentImage = 0;
  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
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
      if (this.mounted)
        setState(() {
          images = networkImages;
        });
    }).catchError((error) => print(error));
  }

  void _settingModalBottomSheet(context) {
    ThemeData theme = Theme.of(context);
    // ignore: close_sinks
    ConfigBloc config = BlocProvider.of<ConfigBloc>(context);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Stack(
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
                        style: theme.textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.anime.episodes != null)
                        Column(
                          children: [
                            Text(
                              "${widget.anime.episodes} episodes",
                              style: theme.textTheme.headline6,
                            ),
                            if (widget.airedEpisodesCount != null && widget.airedEpisodesCount>0)
                              Text(
                                  "${widget.anime.airing ? widget.airedEpisodesCount.toString() : "All"} aired",
                                  style: theme.textTheme.subtitle1)
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
                      translation: Offset(-0.5, -0.5),
                      child: CircleAvatar(
                          child: Text(
                              (widget.anime.score?.toInt() ?? "?").toString(),
                              style: theme.textTheme.bodyText2),
                          backgroundColor: theme.accentColor),
                    ),
                  )
              ],
            ),
          );
        });
  }

  _setNextPicture() {
    if (images.length == 0) return;
    setState(() {
      currentImage = currentImage + 1 >= images.length ? 0 : currentImage + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: InkWell(
        onLongPress: () => _settingModalBottomSheet(context),
        onTap: () => _setNextPicture(),
        child: Hero(
          child: images.length > 0
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
          tag: widget.anime.malId,
        ),
      ),
    );
  }
}

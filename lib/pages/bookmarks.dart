import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/components/genres_chips.dart';

class BookmarkDetail extends StatefulWidget {
  final AnimeItem anime;

  const BookmarkDetail({Key key, @required this.anime}) : super(key: key);

  @override
  _BookmarkDetailState createState() => _BookmarkDetailState();
}

class _BookmarkDetailState extends State<BookmarkDetail> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(fit: StackFit.expand, children: [
        Hero(
          child: Image.network(
            widget.anime.imageUrl,
            fit: BoxFit.fitWidth,
          ),
          tag: widget.anime.malId,
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 500),
          top: MediaQuery.of(context).size.height * 0.9,
          bottom: 0,
          width: MediaQuery.of(context).size.width,
          child: SizedBox.shrink(
            child: Container(
              color: theme.backgroundColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        widget.anime.title,
                        style: theme.textTheme.headline5,
                      ),
                      if (widget.anime.episodes != null)
                        Text(
                          "${widget.anime.episodes} episodes",
                          style: theme.textTheme.headline6,
                        ),
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
                                      style: theme.textTheme.bodyText1,
                                    ),
                                    avatar: genre.imageUrl != null
                                        ? Image.network(genre.imageUrl)
                                        : null,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                              )
                              .toList())
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: FractionalTranslation(
                      translation: Offset(-0.5, -0.5),
                      child: CircleAvatar(
                          child: Text(
                            widget.anime.score.toInt().toString(),
                          ),
                          backgroundColor: theme.canvasColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class BookmarksPage extends StatelessWidget {
  pushToDetails(AnimeItem item, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(body: BookmarkDetail(anime: item))),
    );
  }

  Widget _buildList(Iterable<AnimeItem> items, BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListView(
      children: ListTile.divideTiles(
              tiles: items.map((e) => Stack(
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
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
                            child: Image.network(
                              e.imageUrl,
                              fit: BoxFit.fitWidth,
                            ),
                            tag: e.malId,
                          ),
                        ),
                      ),
                      ListTile(
                          onTap: () => pushToDetails(e, context),
                          title: Text(e.title),
                          subtitle: e.genres.length > 0
                              ? Text(e.genres[0].name)
                              : null,
                          trailing: e.episodes != null
                              ? CircleAvatar(
                                  child: Text(
                                    e.episodes.toString(),
                                  ),
                                  backgroundColor: theme.canvasColor)
                              : null)
                    ],
                  )),
              color: theme.dividerColor)
          .toList(),
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
      if (state is AppFetchCompleted) {
        return _buildList(state.season.anime, buildContext);
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

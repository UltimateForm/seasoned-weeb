import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class GenresChips extends StatelessWidget {
  final Iterable<GenericInfo> genres;

  const GenresChips({Key key, @required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    throw Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        runSpacing: 5,
        spacing: 5,
        children: genres
            .map(
              (genre) => Chip(
                  label: Text(
                    genre.name,
                    style: theme.textTheme.bodyText1,
                  ),
                  avatar: genre.imageUrl != null
                      ? Image.network(genre.imageUrl)
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            )
            .toList());
  }
}

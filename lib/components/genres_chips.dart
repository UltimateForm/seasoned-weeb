import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';

class GenresChips extends StatelessWidget {
  final Iterable<Meta> genres;

  const GenresChips({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        runSpacing: 5,
        spacing: 5,
        children: genres
            .map(
              (genre) => Chip(
                  label: Text(
                    genre.name,
                    style: theme.textTheme.bodyLarge,
                  ),
                  // @TODO: do generes have images??? this was here in older version
                  // avatar: genre.imageUrl != null
                  //     ? Image.network(genre.imageUrl)
                  //     : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            )
            .toList());
  }
}

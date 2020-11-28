import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app_bloc.dart';
import 'package:seasonal_weeb/components/series_card.dart';
import 'package:tcard/tcard.dart';

class SeasonPage extends StatelessWidget {
  final TCardController _controller = TCardController();
  SeasonPage() : super();

  List<Widget> _buildList(Season season) {
    return List.generate(season.anime.length, (index) {
      return SeriesCard(
        key: Key(season.anime[index].malId.toString()),
        anime: season.anime[index],
        parentController: _controller,
        index: index,
      );
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppInitialState) {
          return Center(child: Text("Not loaded"));
        }
        if (state is AppFetching) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AppFetchCompleted) {
          return TCard(
              controller: _controller,
              size: Size(400, 600),
              cards: _buildList(state.season));
        }
        if (state is AppFetchFailed) {
          return Text(state.failureReason, style: TextStyle(color: Colors.red));
        } else
          return Text("Uh oh, something went wrong...",
              style: TextStyle(color: Colors.red));
      },
    );
  }
}

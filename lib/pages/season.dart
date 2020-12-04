import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:seasonal_weeb/bloc/app/app_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import 'package:seasonal_weeb/components/series_card.dart';
import 'package:tcard/tcard.dart';

class SeasonPage extends StatelessWidget {
  final TCardController _controller = TCardController();
  SeasonPage() : super();

  List<Widget> _buildList(Season season, BuildContext context) {
    List<AnimeItem> seasonAnimes = season.anime.where((a) => !a.continuing).toList();
    // ignore: close_sinks
    ConfigBloc config = BlocProvider.of<ConfigBloc>(context);
    if(config.config[ConfigKeys.adultContent]==1){
      seasonAnimes = seasonAnimes.where((a)=>!a.r18).toList();
    }
    seasonAnimes = seasonAnimes.where((a) => a.score==null || a.score>=config.config[ConfigKeys.scoreThreshold]+1).toList();
    return List.generate(seasonAnimes.length, (index) {
      return SeriesCard(
        key: Key(seasonAnimes[index].malId.toString()),
        anime: seasonAnimes[index],
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
          return TCard(
              controller: _controller,
              size: Size(400, 600),
              cards: _buildList(state.season,context));
        }
        if (state is AppFetchFailed) {
          return Text(state.failureReason, style: TextStyle(color: Colors.red));
        } else
          return AlertDialog(
              title: Text("Uh oh, something went wrong...",
                  style: Theme.of(context).textTheme.bodyText1));
      },
    );
  }
}

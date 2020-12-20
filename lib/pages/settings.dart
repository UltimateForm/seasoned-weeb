import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seasonal_weeb/bloc/config/config_bloc.dart';
import '../components/setting_tile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      if (state is ConfigLoading ||
          state is ConfigDataClearing ||
          state is ConfigInitialState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is ConfigReady || state is ConfigSyncing) {
        return ListView(
          children: ListTile.divideTiles(context: buildContext, tiles: [
            ListTile(),
            SettingTile(
              title: "Theme",
              choices: ["System", "Light", "Dark"],
              icon: Icon(Icons.format_paint),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.theme] ?? 0,
              onChange: (value) => buildContext
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.theme, value)),
            ),
            SettingTile(
              title: "Adult Content",
              choices: ["Show", "Hide"],
              icon: Icon(Icons.local_fire_department),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.adultContent] ?? 0,
              onChange: (value) => buildContext
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.adultContent, value)),
            ),
            SettingTile(
              title: "Movies",
              choices: ["Show", "Hide"],
              icon: Icon(Icons.theaters),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.movies] ?? 0,
              onChange: (value) => buildContext
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.movies, value)),
            ),
            SettingTile(
              title: "Scores",
              choices: ["Show", "Hide"],
              icon: Icon(Icons.star),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.showScores] ?? 0,
              onChange: (value) => buildContext
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.showScores, value)),
            ),
            ListTile(
              tileColor: Theme.of(buildContext).dividerColor,
            ),
            SettingTile(
              title: "Score Threshold",
              choices:
                  List<String>.generate(10, (index) => (index + 1).toString()),
              icon: Icon(Icons.filter_alt),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.scoreThreshold] ?? 0,
              onChange: (value) => buildContext
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.scoreThreshold, value)),
            ),
            ListTile(
              tileColor: Theme.of(buildContext).dividerColor,
            ),
            SettingTile(
              title: "Reset App Data",
              choices: [
                // NOTE: THIS NEEDS TO BE THE SAME ORDER AS ConfigDataSection.values
                "All",
                "Preferences",
                "Dismissed Series",
                "Bookmarked Series"
              ],
              icon: Icon(Icons.delete_sweep),
              hideCurrentlySelected: true,
              onChange: (value) {
                var target = ConfigDataSection.values[value];
                // ignore: close_sinks
                var configBloc = buildContext.read<ConfigBloc>();
                configBloc.add(ResetPreferences(sectionToReset: target));
                configBloc.add(LoadConfig());
              },
            ),
          ]).toList(),
        );
      } else if (state is ConfigError) {
        return AlertDialog(
            title: Text(state.error,
                style: Theme.of(context).textTheme.bodyText1));
      } else
        return Center(
          child: CircularProgressIndicator(),
        );
    });
  }
}

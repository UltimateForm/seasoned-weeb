import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../components/setting_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      if (state is ConfigLoading ||
          state is ConfigDataClearing ||
          state is ConfigInitialState) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is ConfigReady || state is ConfigSyncing) {
        return ListView(
          children: ListTile.divideTiles(context: context, tiles: [
            const ListTile(),
            SettingTile(
              title: "Theme",
              choices: const ["System", "Light", "Dark"],
              icon: const Icon(Icons.format_paint),
              initialValue:
                  (state as ConfigReady).config[ConfigKeys.theme] ?? 0,
              onChange: (value) => context
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.theme, value)),
            ),
            SettingTile(
              title: "Adult Content",
              choices: const ["Show", "Hide"],
              icon: const Icon(Icons.local_fire_department),
              initialValue: (state).config[ConfigKeys.adultContent] ?? 0,
              onChange: (value) => context
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.adultContent, value)),
            ),
            SettingTile(
              title: "Movies",
              choices: const ["Show", "Hide"],
              icon: const Icon(Icons.theaters),
              initialValue: (state).config[ConfigKeys.movies] ?? 0,
              onChange: (value) => context
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.movies, value)),
            ),
            SettingTile(
              title: "Scores",
              choices: const ["Show", "Hide"],
              icon: const Icon(Icons.star),
              initialValue: (state).config[ConfigKeys.showScores] ?? 0,
              onChange: (value) => context
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.showScores, value)),
            ),
            ListTile(
              tileColor: Theme.of(context).dividerColor,
            ),
            SettingTile(
              title: "Score Threshold",
              choices:
                  List<String>.generate(10, (index) => (index + 1).toString()),
              icon: const Icon(Icons.filter_alt),
              initialValue: (state).config[ConfigKeys.scoreThreshold] ?? 0,
              onChange: (value) => context
                  .read<ConfigBloc>()
                  .add(SetConfig(ConfigKeys.scoreThreshold, value)),
            ),
            ListTile(
              tileColor: Theme.of(context).dividerColor,
            ),
            SettingTile(
              title: "Reset App Data",
              choices: const [
                // NOTE: THIS NEEDS TO BE THE SAME ORDER AS ConfigDataSection.values
                "All",
                "Preferences",
                "Dismissed Series",
                "Bookmarked Series"
              ],
              icon: const Icon(Icons.delete_sweep),
              hideCurrentlySelected: true,
              onChange: (value) {
                var target = ConfigDataSection.values[value];
                // ignore: close_sinks
                var configBloc = context.read<ConfigBloc>();
                configBloc.add(ResetPreferences(sectionToReset: target));
                configBloc.add(LoadConfig());
              },
            ),
          ]).toList(),
        );
      } else if (state is ConfigError) {
        return AlertDialog(
            title: Text(state.error,
                style: Theme.of(context).textTheme.bodyLarge));
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}

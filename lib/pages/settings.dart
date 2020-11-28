import "package:flutter/material.dart";
import '../components/setting_tile.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage() : super();

  @override
  Widget build(BuildContext buildContext) {
    return ListView(
      children: ListTile.divideTiles(context: buildContext, tiles: [
        ListTile(),
        SettingTile(
          title: "Theme",
          choices: ["System", "Light", "Dark"],
          icon: Icon(Icons.format_paint),
        ),
        SettingTile(
          title: "Adult Content",
          choices: ["Show", "Hide"],
          icon: Icon(Icons.local_fire_department),
        ),
        SettingTile(
          title: "Scores",
          choices: ["Show", "Hide"],
          icon: Icon(Icons.star),
        ),
        ListTile(
          tileColor: Theme.of(buildContext).dividerColor,
        ),
        SettingTile(
          title: "Score Threshold",
          choices: List<String>.generate(10, (index) => (index + 1).toString()),
          icon: Icon(Icons.filter_alt),
        ),
      ]).toList(),
    );
  }
}

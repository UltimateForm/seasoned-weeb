import "package:flutter/material.dart";

class SettingTile extends StatefulWidget {
  final String title;
  final List<String> choices;
  final String initialValue;
  final Widget icon;

  SettingTile(
      {@required this.title,
      @required this.choices,
      this.initialValue,
      this.icon})
      : super();

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  String _currentChoice;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey("${widget.title}-$_currentChoice"),
      title: Text(widget.title),
      subtitle:
          Text(_currentChoice ?? widget.initialValue ?? widget.choices[0]),
      leading: widget.icon ?? Icon(Icons.settings),
      children: widget.choices
          .map((e) => ListTile(
                title: Align(
                  alignment: Alignment.centerRight,
                  child: Text(e),
                ),
                onTap: () => setState(() => _currentChoice = e),
              ))
          .toList(),
    );
  }
}

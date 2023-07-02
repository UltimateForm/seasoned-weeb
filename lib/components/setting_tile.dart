import "package:flutter/material.dart";

typedef SettingTileOnChange = void Function(int value);

class SettingTile extends StatefulWidget {
  final String title;
  final List<String> choices;
  final int initialValue;
  final Widget icon;
  final SettingTileOnChange onChange;
  final bool hideCurrentlySelected;
  const SettingTile(
      {super.key,
      required this.title,
      required this.choices,
      this.initialValue = 0,
      required this.icon,
      required this.onChange,
      this.hideCurrentlySelected = false});

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  late int _currentChoice;
  @override
  void initState() {
    super.initState();
    _currentChoice = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _currentChoice != widget.initialValue) {
      setState(() {
        _currentChoice = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey("${widget.title}-${_currentChoice.toString()}"),
      title: Text(
        widget.title,
      ),
      subtitle: widget.hideCurrentlySelected
          ? null
          : Text(widget.choices[_currentChoice]),
      leading: widget.icon,
      children: widget.choices
          .map((e) => ListTile(
                title: Align(
                  alignment: Alignment.centerRight,
                  child: Text(e),
                ),
                onTap: () {
                  int value = widget.choices.indexOf(e);
                  setState(() {
                    _currentChoice = value;
                  });
                  widget.onChange(value);
                },
              ))
          .toList(),
    );
  }
}

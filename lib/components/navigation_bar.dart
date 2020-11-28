import "package:flutter/material.dart";

class NavigationBar extends StatelessWidget {
  NavigationBar() : super();

  Widget build(BuildContext buildContext) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: "Settings"),
        BottomNavigationBarItem(
            icon: Icon(Icons.view_array_outlined), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline), label: "Bookmarks")
      ],
    );
  }
}

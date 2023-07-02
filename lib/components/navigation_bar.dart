import "package:flutter/material.dart";

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
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

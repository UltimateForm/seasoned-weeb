import "package:flutter/material.dart";

import "bookmarks.dart";
import "season.dart";
import "settings.dart";

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  int _selectedIndex = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTap,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), label: "Settings"),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_array_outlined), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline), label: "Bookmarks")
          ],
        ),
        body: SizedBox.expand(
            child: WillPopScope(
          onWillPop: () async {
            if (_selectedIndex != 1) {
              await _pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut);
            }
            return false;
          },
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [
              const SettingsPage(),
              SeasonPage(),
              const BookmarksPage()
            ],
          ),
        )));
  }
}

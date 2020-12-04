import "package:flutter/material.dart";
import 'package:seasonal_weeb/pages/bookmarks.dart';
import 'package:seasonal_weeb/pages/season.dart';
import 'package:seasonal_weeb/pages/settings.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 1;
  PageController _pageController;

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
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTap,
          items: [
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
            if (_selectedIndex != 1)
              await _pageController.animateToPage(1,
                  duration: Duration(milliseconds: 500), curve: Curves.easeOut);
            return false;
          },
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [SettingsPage(), SeasonPage(), BookmarksPage()],
          ),
        )));
  }
}

import "package:flutter/material.dart";

class BookmarksPage extends StatelessWidget {

  Widget _buildList(){
    return ListView(children: [
      ListTile(title: Text("One"),),
      ListTile(title: Text("Two"),),
      ListTile(title: Text("Three"),)
    ],);
  }

  @override
  Widget build(BuildContext buildContext){
    return _buildList();
  }
}
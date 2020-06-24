import 'package:flutter/material.dart';
import 'player_provider.dart';
import 'package:provider/provider.dart';

class Music extends StatelessWidget {
  final String musicUrl;
  final String name;
  Music({this.musicUrl,this.name});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () => Provider.of<PlayerProvider>(context, listen: false)
          .startNewSong(musicUrl,name),
    );
  }
}

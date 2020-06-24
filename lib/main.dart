import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';
import 'music.dart';
import './player_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'music_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicProvider(),
      child: ChangeNotifierProvider(
        create: (_) => PlayerProvider(),
        child: MaterialApp(
          title: 'Firebase Media',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Provider.of<MusicProvider>(context, listen: false).loginAnonymous();
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Media'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MusicList(),
          ),
          Flexible(
            flex: 1,
            child: Player(context),
          ),
        ],
      ),
    );
  }
}

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final MusicProvider musProvider =
        Provider.of<MusicProvider>(context, listen: false);
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: musProvider.musicStream(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Center(child: Text('An error occurred'));
                } else {
                  List<Widget> list = snapshot.data.documents
                      .map((item) => Music(
                            musicUrl: item['url'],
                            name: item['name'],
                          ))
                      .toList();
                  return Expanded(
                    child: ListView.separated(
                        separatorBuilder: (_, __) => Divider(),
                        itemCount: list.length,
                        itemBuilder: (ctx, index) => list[index]),
                  );
                }
              }),
          FlatButton(
            child: Text('Upload Image'),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await musProvider.addAudio();
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
    );
  }
}

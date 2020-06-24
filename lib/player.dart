import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'player_provider.dart';

class Player extends StatefulWidget {
  final BuildContext context;
  Player(this.context);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  dispose() {
    Provider.of<PlayerProvider>(context, listen: false).disposePlayer();
    super.dispose();
  }

  String parse(int milliSecondsVal) {
    String minString;
    String secString;
    final totalSecVal = milliSecondsVal / 1000;
    int minVal = (totalSecVal.round() / 60).floor();
    final int secVal = totalSecVal.round() % 60;
    if (minVal < 10) {
      minString = '0$minVal';
    } else {
      minString = minVal.toString();
    }
    if (secVal < 10) {
      secString = '0$secVal';
    } else {
      secString = secVal.toString();
    }
    if (minVal < 60) {
      return '$minString:$secString';
    } else {
      int hourVal = (minVal / 60).floor();
      minVal = minVal % 60;
      if (minVal < 10) {
        minString = '0$minVal';
      } else {
        minString = minVal.toString();
      }
      String hourString = hourVal.toString();
      if (hourVal < 10) {
        hourString = '0$hourVal';
      }
      return '$hourString:$minString:$secVal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mus = Provider.of<PlayerProvider>(context);
    var playPauseButton = StreamBuilder<AudioPlayerState>(
      stream: mus.playerStateStream(),
      builder: (ctx, snapshot) => IconButton(
        onPressed: () async {
          await mus.playPause();
        },
        icon: Icon(
          snapshot.data != AudioPlayerState.PLAYING || !snapshot.hasData
              ? Icons.play_arrow
              : Icons.pause,
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(mus.playingName ?? ''),
            StreamBuilder<Duration>(
              stream: mus.durationStream(),
              builder: (ctx, snapshot) => FutureBuilder<int>(
                future: mus.audioPlayer.getDuration(),
                builder: (ctx, sn) => Row(
                  children: <Widget>[
                    Text(parse((snapshot.data ?? Duration(milliseconds: 0))
                        .inMilliseconds)),
                    Expanded(
                      child: Slider(
                        onChanged: (value) async {
                          await mus.seekTo(value);
                        },
                        value: (snapshot.data ?? Duration(milliseconds: 0))
                                    .inMilliseconds <
                                (sn.data ?? 0)
                            ? (snapshot.data ?? Duration(milliseconds: 0))
                                .inMilliseconds
                                .roundToDouble()
                            : 0.0,
                        min: 0.0,
                        max: (sn.data ?? 0).toDouble(),
                      ),
                    ),
                    Text(parse(sn.data ?? 0))
                    //two
                  ],
                ),
              ),
            ),
            playPauseButton
          ],
        ),
      ),
    );
  }
}

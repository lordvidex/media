import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerProvider with ChangeNotifier {
  String playingUrl;
  String playingName;
  int duration;
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'lordvidex');

  Future<void> disposePlayer() async {
    await audioPlayer.release();
    await audioPlayer.dispose();
  }

  Stream<Duration> durationStream() {
    return audioPlayer.onAudioPositionChanged;
  }
  Future<int> getDuration(){
    return audioPlayer.getDuration();
  }
  Stream<AudioPlayerState> playerStateStream() {
    return audioPlayer.onPlayerStateChanged;
  }

  Future<void> startNewSong(String url, String name) async {
    if (playingUrl != null) {
      await stopSong();
      notifyListeners();
    }
    await audioPlayer.play(url, isLocal: false);
    playingUrl = url;
    playingName = name;
    
    notifyListeners();
  }

  Future<void> seekTo(double milliSec) async {
    await audioPlayer.seek(Duration(milliseconds: milliSec.round()));
  }

  Future<void> stopSong() async {
    await audioPlayer.stop();
    notifyListeners();
  }

  Future<void> playPause() async {
    if (playingUrl == null) {
      return;
    }
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }
}

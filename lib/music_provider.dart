import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusicProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = Firestore.instance;
  final _store = FirebaseStorage.instance;
  String _url;
  String _name;
  FirebaseUser _user;

  Stream<QuerySnapshot> musicStream() {
    return _db.collection('music').snapshots();
  }
  String get url{
    return _url;
  }
  String get name{
    return _name;
  }
  void loginAnonymous() async {
    _user = await _auth.currentUser();
    if (_user == null) {
      _user = (await _auth.signInAnonymously()).user;
    }
    notifyListeners();
  }

  //to add an audio file
  Future<void> addAudio() async {
    File _uploadedFile;
    _uploadedFile = await FilePicker.getFile(type: FileType.AUDIO);
    
    StorageReference storageReference =
        _store.ref().child('audio/${basename(_uploadedFile.path)}');
    StorageUploadTask storageUploadTask =
        storageReference.putFile(_uploadedFile);
    await storageUploadTask.onComplete;
    final url = await storageReference.getDownloadURL();
    final metadata = await storageReference.getMetadata();
    _db.collection('music').add({'url': url.toString(), 'name': metadata.name});
    print('Image Uploaded');
    notifyListeners();
  }
  Future<void> playMusic(String url,String name)async {
    _url = url;
    _name = name;
    notifyListeners();
  }
}

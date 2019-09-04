import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'menu.dart';
import '../models/user.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../app_state_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firestore_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/speech_recognition.dart';
import 'package:flutter_youtube_extractor/flutter_youtube_extractor.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

class testVideoScreen extends StatefulWidget {
  @override
  _testVideoScreenState createState() => new _testVideoScreenState();
}

class _testVideoScreenState extends State<testVideoScreen> {
  SpeechRecognition _speech;

  final formkey = new GlobalKey<FormState>();
  var db = new FirestoreHelper();

  User _user;

  File _image;

  final controller = PageController(initialPage: 1);

  String _youtubeMediaLink = 'Unknown';
  String _youtubeWebLink;
var extractor = YouTubeExtractor();

  bool isLoading = true;

  Future<void> initPlatformState() async {
var videoInfo = await extractor.getMediaStreamsAsync('0LHxvxdRnYc');
  print('Video URL: ${videoInfo.video.first.url}');
  setState(() {
              _youtubeMediaLink = videoInfo.video.first.url;

              isLoading = false;
            });
    // _youtubeMediaLink="https://www.youtube.com/watch?v=0LHxvxdRnYc";
    /*
print("hi4");
    try {
      FlutterYoutubeExtractor.getYoutubeMediaLink(
          youtubeLink: _youtubeMediaLink,
          onReceive: (link) {
            print("init2");
            print(link);
print("hi5");
            if (!mounted) return;

            setState(() {
              _youtubeMediaLink = link;

print("hi6");
              isLoading = false;
            });
          });
    } on PlatformException {
      _youtubeMediaLink = 'Failed to get Youtube Media link.';
    }
    */
  }

  @override
  initState() {
    print("testing");
    super.initState();
    _speech = new SpeechRecognition();
  }

void refreshTimer()
{
  Navigator.of(context).pop();
}
  void getVideo(BuildContext context) =>
      _speech.showVideo(text: _youtubeMediaLink).then((result) {});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

print("hi");
    _user = AppStateContainer.of(context).user;

    if (!isLoading) {
      if (_youtubeMediaLink == "unknown") {
        Fluttertoast.showToast(msg: "Invalid Video URL");
        Navigator.of(context).pop();
      }

      if (AppStateContainer.of(context).device == Device.watch) {
        getVideo(context);
      } else {
        FlutterYoutube.playYoutubeVideoByUrl(
            apiKey: "AIzaSyAVOGJcirzHWbzY4pR6XlC0E5Xq-6JfuQs",
            videoUrl: _youtubeWebLink,
            autoPlay: true, //default falase
            fullScreen: true //default false
            );
      }
      
    var _duration = new Duration(seconds: 2);
     new Timer(_duration, refreshTimer);
        
    } else {
     
        initPlatformState();
print("hi3");
    }
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Center(
            child: isLoading
                ? new CircularProgressIndicator(backgroundColor: Colors.white)
                : new Text("play")));
  }
}

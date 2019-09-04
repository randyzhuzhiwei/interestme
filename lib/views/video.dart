import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user.dart';
import '../app_state_container.dart';
import '../models/speech_recognition.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

/*
import 'package:flutter_youtube_extractor/flutter_youtube_extractor.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firestore_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'menu.dart';
*/
class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => new _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  SpeechRecognition _speech;

  var extractor = YouTubeExtractor();

  String youtubeURL = "https://www.youtube.com/watch?v=";
  String youtubeURL2 = "https://youtu.be/";

  User _user;

  String _youtubeMediaLink = 'Unknown';
  String _youtubeWebLink;

  bool isLoading = true;

  Future<void> initPlatformState() async {
    String videoID;

    videoID = _youtubeMediaLink.replaceAll(youtubeURL, "");
    videoID = videoID.replaceAll(youtubeURL2, "");
    
    var videoInfo = await extractor.getMediaStreamsAsync(videoID);
    print('Video URL: ${videoInfo.video.first.url}');
    setState(() {
      _youtubeMediaLink = videoInfo.video.first.url;

      isLoading = false;
    });
    // _youtubeMediaLink="https://www.youtube.com/watch?v=0LHxvxdRnYc";
/*print("hi4");
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
    super.initState();
    _speech = new SpeechRecognition();
  }

  void refreshTimer() {
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
      if (_user.action != null &&
          _user.action.containsKey("Action") &&
          _user.action["Action"] == "PlayVideo") {
        _youtubeMediaLink = _user.action["YoutubeLink"];
        _youtubeWebLink = _user.action["YoutubeLink"];
        // _youtubeMediaLink = _youtubeMediaLink.toLowerCase();

        print("hi2");
        initPlatformState();
        print("hi3");
      } else {
        Fluttertoast.showToast(msg: "Invalid Action");
        Navigator.of(context).pop();
      }
    }
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Center(
            child: isLoading
                ? new CircularProgressIndicator(backgroundColor: Colors.white)
                : new Text("play")));
  }
}

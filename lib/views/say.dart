import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';
import '../models/speech_recognition.dart';
import '../data/fcm_helper.dart';
import 'package:http/http.dart' as http;
import '../data/string_helper.dart';
import 'audio_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

double _appBarHeight;

enum ConfirmAction { Cancel, Confirm }

class SayScreen extends StatefulWidget {
  @override
  _SayScreenState createState() => new _SayScreenState();
}

class _SayScreenState extends State<SayScreen> with TickerProviderStateMixin {
  SpeechRecognition _speech;

  Recording _recording = new Recording();
  bool _isRecording = false;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _hasStarted = false;
  bool _getTags = false;
  bool _privateChat = false;
  bool _privateGroupChat = false;

  String _transcription = 'testing';

  String _currentLocale = 'en_US';

  BuildContext _scaffoldContext;

  AnimationController _controller;

  final controller = PageController(initialPage: 1);

  User _user;

  Color bgColor;

  var txt = new TextEditingController();

  bool sending;

  Map<dynamic, dynamic> groupList;

  List<String> groupListing = new List<String>();

  List<dynamic> keywordsFilter = new List<dynamic>();
  List<bool> keywordsFilterTapped = new List<bool>();

  ScrollController _scrollController = new ScrollController();
  List<String> keywords;

  Timer timer;
  /*
  Map<dynamic> groupList = [
    "All - Just saying",
    "Grp - SMB",
    "Grp - IT Club",
    "Grp - Adolescents",
    "Grp - Switch",
  ];
  */
  List<bool> groupListTapped = new List<bool>();

  File _image;
  String downloadUrl = null;
  String downloadAudioUrl = null;
  String _audioRecording = null;

  static String url =
      'https://codingwithjoe.com/wp-content/uploads/2018/03/applause.mp3';
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioProvider audioProvider = new AudioProvider(url);

  @override
  initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    activateSpeechRecognizer();
    txt.text = "";

    sending = false;
    txt.addListener(_getHashTag);
    var _duration = new Duration(seconds: 1);
    timer = new Timer(_duration, scrollBottom);
  }

  scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - 50.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  ///watch only
  ///
  ///
  Widget _buildPage({String menu, IconButton icon, Color color, void f()}) {
    return new Material(
        color: color,
        child: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              InkWell(
                  onTap: () {
                    f();
                  },
                  child: Container(
                      child: Column(children: <Widget>[
                    icon,
                    Text(
                      menu,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ])))
            ])));
  }

  Widget _buildOptionPage() {
    return Material(
        color: Colors.blueGrey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(height: MediaQuery.of(context).size.height / 3),
              Container(
                  padding: EdgeInsets.only(
                    left: 50.0,
                  ),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(children: <Widget>[
                        Container(
                          height: 50.0,
                          child: IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child:
                                new Icon(FontAwesomeIcons.backward, size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0, top: 12.0),
                            height: 50.0,
                            child: Text(
                              "Close",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18.0),
                            )),
                      ]))),
              Container(height: MediaQuery.of(context).size.height / 3),
            ]));
  }

  Widget _buildPageView() {
    /*
    if (_privateChat) {
      return PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          _buildOptionPage(),
          _buildAudioButton(),
          _buildAudioRecordingButton(),
          _buildTextInput(),
          _buildGroups(context),
          _buildPage(
            menu: "Say!",
            color: bgColor,
            icon: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(Icons.chat, size: 40.0),
              ),
              onPressed: () {
                _shoutout();
              },
            ),
            f: _shoutout,
          ),
          //_buildCloseButton()
        ],
      );
    }
    */
    if (sending) {
      return Center(child: CircularProgressIndicator());
    }
    if (_audioRecording == null) {
      return PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          _buildOptionPage(),
          _buildAudioButton(),
          _buildAudioRecordingButton(),
          _buildTextInput(),
          _buildGroups(context),
          _buildkeywords(context),
          _buildPage(
            menu: "Say!",
            color: bgColor,
            icon: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(Icons.chat, size: 40.0),
              ),
              onPressed: () {
                _shoutout();
              },
            ),
            f: _shoutout,
          ),
          _buildOptionPage(),
        ],
      );
    } else {
      return PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          _buildOptionPage(),
          _buildAudioButton(),
          _buildAudioRecordingButton(),
          _buildAudioPlayButton(),
          _buildTextInput(),
          _buildGroups(context),
          _buildkeywords(context),
          _buildPage(
            menu: "Say!",
            color: bgColor,
            icon: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(Icons.chat, size: 40.0),
              ),
              onPressed: () {
                _shoutout();
              },
            ),
            f: _shoutout,
          ),
          _buildOptionPage(),
        ],
      );
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    print(_speechRecognitionAvailable);
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setKeyboardResultHandler(onKeyboardResult);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.activate().then((res) => setState(() {
          _speechRecognitionAvailable = res;
          if (_scaffoldContext != null) {
//final snackBar = SnackBar(content: Text('Speech: ${res}'));
            //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
          } else {
            print('Speech: $res');
          }
        }));
  }

  void onSpeechAvailability(bool result) => setState(() {
        _speechRecognitionAvailable = result;

        if (_hasStarted) {
          _speechRecognitionAvailable = true;
        }

        //   final snackBar = SnackBar(content: Text('Speech Available: ${result}'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      });

  void onCurrentLocale(String locale) => setState(() {
        _currentLocale = locale;
        //  final snackBar = SnackBar(content: Text('Speech locale: ${locale}'));
        //  Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      });

  void onRecognitionStarted() => setState(() {
        _hasStarted = true;
        _isListening = true;
        print("Recongition Started setstate");
      });

  void onKeyboardResult(String text) => setState(() {
        //    final snackBar = SnackBar(content: Text('Results:${_transcription}'));
        //    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        txt.text = text;
      });

  void onRecognitionResult(String text) => setState(() {
        _transcription = text;
        //    final snackBar = SnackBar(content: Text('Results:${_transcription}'));
        //    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        txt.text = _transcription;
        _isListening = true;
      });

  void onRecognitionComplete() => setState(() {
        _isListening = false;
        _hasStarted = true;
        if (AppStateContainer.of(context).device == Device.watch) {
          controller.jumpToPage(3);
        }
        // final snackBar = SnackBar(content: Text('Speech listening complete. Results:${_transcription}'));
        //  Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      });

  Widget _buildTextInput() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: bgColor,
          child: Container(
              margin: EdgeInsets.only(
                  left: 20.0, right: 10.0, top: 50.0, bottom: 10.0),
              /* child: TextFormField(
                textInputAction: TextInputAction.done,
                controller: txt,
                keyboardType: TextInputType.text,
                maxLines: 3,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15.0),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What do you want to say?'),
              )*/

              child: new GestureDetector(
                onTap: () {
                  getKeyboard(context);
                },
                child: new Text(
                  "Your Message:\n" + txt.text,
                  maxLines: 8,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15.0),
                ),
              )));
    } else {
      return new TextFormField(
        controller: txt,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        style: new TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      );
    }
  }

  Widget _buildCloseButton() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: bgColor,
          child: Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
              child: new IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(FontAwesomeIcons.backward, size: 50.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })));
    } else {
      return Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: new IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(FontAwesomeIcons.timesCircle, size: 30.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })));
    }
  }

  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget _buildPictureButton() {
    return new Container(
        padding: EdgeInsets.only(top: 10.0, right: 10.0),
        child: Material(
            elevation: 1.0,
            shape: CircleBorder(),
            color: Colors.transparent,
            child: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(Icons.add_a_photo, size: 30.0),
              ),
              onPressed: chooseSource,
            )));
  }

  Widget _buildAudioPlayButton() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: bgColor,
          child: Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 45.0, bottom: 10.0),
              child: Column(children: <Widget>[
                IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.red),
                    child: new Icon(FontAwesomeIcons.play, size: 30.0),
                  ),
                  onPressed: play,
                ),
                Text(
                  "Play Recording",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
              ])));
    } else {
      return new Container(
          padding: EdgeInsets.only(top: 10.0, right: 10.0),
          child: Material(
              elevation: 1.0,
              shape: CircleBorder(),
              color: Colors.transparent,
              child: IconButton(
                icon: new IconTheme(
                  data: new IconThemeData(color: Colors.white),
                  child: new Icon(FontAwesomeIcons.play, size: 30.0),
                ),
                onPressed: play,
              )));
    }
  }

  Widget _buildAudioRecordingButton() {
    if (AppStateContainer.of(context).device == Device.watch) {
      if (_isRecording) {
        return new Material(
            color: Colors.greenAccent,
            child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 45.0, bottom: 10.0),
                child: Column(children: <Widget>[
                  IconButton(
                    icon: new IconTheme(
                      data: new IconThemeData(color: Colors.red),
                      child: new Icon(FontAwesomeIcons.stopCircle, size: 30.0),
                    ),
                    onPressed: _stopRecording,
                  ),
                  Text(
                    "Press to stop recording...",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                ])));
      } else {
        return new Material(
            color: bgColor,
            child: InkWell(
                // When the user taps the button, show a snackbar
                onTap: _startRecording,
                child: Container(
                    margin: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 55.0, bottom: 10.0),
                    child: Column(children: <Widget>[
                      IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child:
                            new Icon(FontAwesomeIcons.microphone, size: 40.0),
                      ),
                      Text(
                        "Voice Recording",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                    ]))));
      }
    } else {
      if (_isRecording) {
        return new Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            child: Material(
                elevation: 1.0,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.red),
                    child: new Icon(FontAwesomeIcons.stopCircle, size: 30.0),
                  ),
                  onPressed: _stopRecording,
                )));
      } else {
        return new Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            child: Material(
                elevation: 1.0,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(FontAwesomeIcons.microphone, size: 30.0),
                  ),
                  onPressed: _startRecording,
                )));
      }
    }
  }

  Widget _buildAudioRecordingStopButton() {
    return new Container(
        padding: EdgeInsets.only(top: 10.0, right: 10.0),
        child: Material(
            elevation: 1.0,
            shape: CircleBorder(),
            color: Colors.transparent,
            child: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.red),
                child: new Icon(FontAwesomeIcons.stopCircle, size: 60.0),
              ),
              onPressed: _stopRecording,
            )));
  }

  _startRecording() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start();
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording =
              new Recording(duration: new Duration(), path: "imRecord");

          _isRecording = isRecording;
        });
      } else {
        Fluttertoast.showToast(msg: "You must allow audio permissions");
      }
    } catch (e) {
      print(e);
    }
  }

  _stopRecording() async {
    bool status = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir.absolute.path + "/imRecord.m4a";

    setState(() {
      _isRecording = isRecording;
      _audioRecording = appDocPath;
    });
  }

  Future<Null> chooseSource() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "camera");
                },
                child: const Text('Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "gallery");
                },
                child: const Text('Gallery'),
              ),
            ],
          );
        })) {
      case "camera":
        getImage(0);
        break;
      case "gallery":
        getImage(1);
        break;
    }
  }

  Future<Null> chooseSourceBg() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "camera");
                },
                child: const Text('Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "gallery");
                },
                child: const Text('Gallery'),
              ),
            ],
          );
        })) {
      case "camera":
        getImageBg(0);
        break;
      case "gallery":
        getImageBg(1);
        break;
    }
  }
  Future getImageBg(int i) async {
    var imageBg;

    if (i == 0) {
      imageBg = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      imageBg = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    if(imageBg!=null)
      _asyncConfirmDialog(context,imageBg);
  }

  Future<bool> uploadBgPictureFile(File _image) async {
    String photoUrl;
    String name;
    
    name = _user.username+"sayBg"+new DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg";

    if (_image != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dl = await (await task.onComplete).ref.getDownloadURL();
        photoUrl = dl.toString();
      Firestore.instance.collection("users").document(_user.id).updateData({
        'say_pic': photoUrl,
      }).catchError((e) {
       exit(0);
        print(e);
      });
      AppStateContainer.of(context).user.sayPic = photoUrl;
      setState(() {
        
      });
    }
  }
  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context,  File _image) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Wallpaper'),
        content: const Text(
            'Change wallpaper?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.Cancel);
            },
          ),
          FlatButton(
            child: const Text('Confirm'),
            onPressed: () {
              uploadBgPictureFile(_image);
              Navigator.of(context).pop(ConfirmAction.Confirm);
            },
          )
        ],
      );
    },
  );
}
  Future getImage(int i) async {
    var image;

    if (i == 0) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _image = image;
    });
  }

  Widget _buildAudioButton() {
    VoidCallback onPressed;

    print("_speechRecognitionAvailable = $_speechRecognitionAvailable");
    print("_isListening = $_isListening");
    if (AppStateContainer.of(context).device == Device.watch) {
      if (_speechRecognitionAvailable && !_isListening) {
        onPressed = () => start(context);
        return new Material(
            color: bgColor,
            child: InkWell(
                // When the user taps the button, show a snackbar
                onTap: onPressed,
                child: Container(
                    margin: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 55.0, bottom: 10.0),
                    child: Column(children: <Widget>[
                      IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child: new Icon(Icons.text_fields, size: 40.0),
                      ),
                      Text(
                        "Press to speak",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                    ]))));
      }
      if (_isListening) {
        onPressed = () => stop();
        _controller.forward().orCancel;
        return new Material(
            color: Colors.greenAccent,
            child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 45.0, bottom: 10.0),
                child: Column(children: <Widget>[
                  IconButton(
                    icon: new IconTheme(
                      data: new IconThemeData(color: Colors.red),
                      child: new Icon(Icons.text_fields, size: 30.0),
                    ),
                    onPressed: onPressed,
                  ),
                  Text(
                    "Listening...",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                ])));
      }
      // final snackBar = SnackBar(content: Text('Speech recongizer not available'));
      // Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      // _isListening=false;
      //setstate to wait again
      return new Material(
          color: bgColor,
          child: Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 45.0, bottom: 10.0),
              child: Column(children: <Widget>[
                IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(Icons.text_fields, size: 30.0),
                  ),
                  onPressed: onPressed,
                ),
                Text(
                  "Voice function not available",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
              ])));
    } else {
      if (_speechRecognitionAvailable && !_isListening) {
        onPressed = () => start(context);
        return new Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            child: Material(
                elevation: 1.0,
                shape: CircleBorder(),
                color: Colors.transparent,
                child: IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(Icons.text_fields, size: 30.0),
                  ),
                  onPressed: onPressed,
                )));
      }
      if (_isListening) {
        onPressed = () => stop();
        _controller.forward().orCancel;
        return new Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            child: Material(
                elevation: 4.0,
                shape: CircleBorder(),
                color: Colors.white,
                child: FadeTransition(
                    opacity: _controller,
                    child: IconButton(
                      icon: new IconTheme(
                        data: new IconThemeData(color: Colors.red),
                        child: new Icon(Icons.text_fields, size: 30.0),
                      ),
                      onPressed: onPressed,
                    ))));
      }
      // final snackBar = SnackBar(content: Text('Speech recongizer not available'));
      // Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

      return new Container(
          padding: EdgeInsets.only(top: 10.0, right: 10.0),
          child: Material(
              elevation: 4.0,
              shape: CircleBorder(),
              color: Colors.white,
              child: IconButton(
                icon: new IconTheme(
                  data: new IconThemeData(color: Colors.grey),
                  child: new Icon(Icons.text_fields, size: 30.0),
                ),
                onPressed: null,
              )));
    }
  }

  void start(BuildContext context) =>
      _speech.listen(locale: _currentLocale).then((result) {
        //       final snackBar = SnackBar(content: Text('_MyAppState.start => result ${result}'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        //print('_MyAppState.start => result ${result}');
      });

  void getKeyboard(BuildContext context) =>
      _speech.getKeyboard(text: txt.text).then((result) {
        //       final snackBar = SnackBar(content: Text('_MyAppState.start => result ${result}'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        //print('_MyAppState.start => result ${result}');
      });

  void cancel() => _speech.cancel().then((result) => setState(() {
        print("cancel");
        _isListening = result;
      }));

  void stop() => _speech.stop().then((result) => setState(() {
        print("stop");
        _isListening = result;
      }));

  void _getHashTag() {
    if (AppStateContainer.of(context).device == Device.mobile) {
      String upper = txt.text.toUpperCase();

      if (upper.length == 0) {
        return;
      }

      keywordsFilter.clear();
      keywordsFilterTapped.clear();
      String b = upper.replaceAll(new RegExp(r'([.,!?\\-])'), '');
      keywords = b.split(" ");

      keywords.forEach((f) {
        print(keywords);
        if (f != "" && f.startsWith("#")) {
          f = f.substring(1);
          keywordsFilter.add(f);
        }
      });
      keywordsFilter.forEach((value) {
        keywordsFilterTapped.add(true);
      });
      setState(() {});
    }
  }

  Widget _buildkeywords(context) {
    if (AppStateContainer.of(context).device == Device.watch) {
      if (!_getTags) {
        return new Material(
            color: bgColor,
            child: new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  InkWell(
                      onTap: () {
                        setState(() {
                          _getTags = true;
                        });
                      },
                      child: Container(
                          child: Column(children: <Widget>[
                        IconTheme(
                          data: new IconThemeData(color: Colors.white),
                          child: new Icon(FontAwesomeIcons.hashtag, size: 40.0),
                        ),
                        Text(
                          "Get Tags",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                      ])))
                ])));
      }

      if (keywordsFilter != null) keywordsFilter.clear();
      if (keywords != null) keywords.clear();

      String upper = txt.text.toUpperCase();

      String b = upper.replaceAll(new RegExp(r'([.,!?\\-])'), '');
      keywords = b.split(" ");

      keywords.forEach((f) {
        if (!StringHelper.prnouns.contains(f) &&
            !StringHelper.verbs.contains(f) &&
            !StringHelper.others.contains(f) &&
            f != "" &&
            !f.startsWith("HTTP")) keywordsFilter.add(f);
      });
      keywordsFilter.forEach((value) {
        keywordsFilterTapped.add(false);
      });

      //   print(keywordsFilter.length);

      return new Material(
          color: bgColor,
          child: Container(
              padding: EdgeInsets.only(
                  left: 20.0, right: 10.0, top: 45.0, bottom: 45.0),
              child: ListView.builder(
                  itemCount: keywordsFilter.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Container(
                      padding: EdgeInsets.only(
                          left: 5.0, top: 3.0, bottom: 3.0, right: 5.0),
                      child: new Material(
                        child: InkWell(
                            // When the user taps the button, show a snackbar
                            onTap: () {
                              setState(() {
                                keywordsFilterTapped[index]
                                    ? keywordsFilterTapped[index] = false
                                    : keywordsFilterTapped[index] = true;
                              });
                            },
                            child: Container(
                              color: keywordsFilterTapped[index]
                                  ? Colors.white10
                                  : Color(0xFFf79646),
                              child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      keywordsFilter[index],
                                      style: new TextStyle(
                                          color: Colors.white, fontSize: 17.0),
                                    ),
                                    keywordsFilterTapped[index]
                                        ? new IconTheme(
                                            data: new IconThemeData(
                                                color: Colors.greenAccent),
                                            child: new Icon(
                                              FontAwesomeIcons.checkCircle,
                                              size: 10.0,
                                            ),
                                          )
                                        : new Text(""),
                                  ]),
                            )),
                        color: Colors.transparent,
                      ),
                      color: bgColor,
                    );
                  })));
    } else {
      return new ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          itemCount: keywordsFilter.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Container(
              padding:
                  EdgeInsets.only(left: 5.0, top: 3.0, bottom: 3.0, right: 5.0),
              child: new Material(
                  child: Container(
                color: bgColor,
                child: new Text(
                  "${keywordsFilter[index]}",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25.0),
                ),
              )),
              color: bgColor,
            );
          });

/*
      return new Material(
          color: bgColor,
          child: Container(
              padding: EdgeInsets.only(
                  left: 20.0, right: 10.0, top: 45.0, bottom: 45.0),
              child: ListView.builder(
                  itemCount: keywordsFilter.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Container(
                        padding: EdgeInsets.only(
                            left: 5.0, top: 3.0, bottom: 3.0, right: 5.0),
                        child: new Text(
                          keywordsFilter[index],
                          style: new TextStyle(
                              color: Colors.white, fontSize: 17.0),
                        ));
                  })));
                  */
    }
  }

  Widget _buildGroups(context) {
    if (_privateChat) {
      return new Material(
          color: bgColor,
          child: Center(
              child: Container(
            child: Text(
              "Sending to ${_user.action["UserName"]}",
              style: new TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          )));
    }
    if (_privateGroupChat) {
      groupListing.add(_user.action["GroupName"]);
      groupListTapped.add(true);

      return new Material(
          color: bgColor,
          child: Center(
              child: Container(
            child: Text(
              "Sending to ${_user.action["GroupName"]}",
              style: new TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          )));
    }
    if (groupListing.length == 0) {
      groupList = _user.groups;
      groupListing.add("All - Just saying");
      _user.groups.forEach((key, value) {
        groupListing.add(key);
      });
      groupListTapped.add(true);
      groupList.forEach((key, value) {
        groupListTapped.add(false);
      });
    }
    if (AppStateContainer.of(context).device == Device.watch) {
      return new GestureDetector(
          onTap: () {
            this._dismissKeyboard(context);
          },
          child: new Material(
              color: bgColor,
              child: Container(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 10.0, top: 45.0, bottom: 45.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: groupListing.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Container(
                          padding: EdgeInsets.only(
                              left: 5.0, top: 3.0, bottom: 3.0, right: 5.0),
                          child: new Material(
                            child: InkWell(
                                // When the user taps the button, show a snackbar
                                onTap: () {
                                  setState(() {
                                    groupListTapped[index]
                                        ? groupListTapped[index] = false
                                        : groupListTapped[index] = true;
                                  });
                                },
                                child: Container(
                                  color: groupListTapped[index]
                                      ? Colors.white10
                                      : Color(0xFFf79646),
                                  child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(
                                          "Grp - ${groupListing[index]}",
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize: 17.0),
                                        ),
                                        groupListTapped[index]
                                            ? new IconTheme(
                                                data: new IconThemeData(
                                                    color: Colors.greenAccent),
                                                child: new Icon(
                                                  FontAwesomeIcons.checkCircle,
                                                  size: 10.0,
                                                ),
                                              )
                                            : new Text(""),
                                      ]),
                                )),
                            color: Colors.transparent,
                          ),
                          color: bgColor,
                        );
                      }))));
    } else {
      return new ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          itemCount: groupListing.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Container(
              padding:
                  EdgeInsets.only(left: 5.0, top: 3.0, bottom: 3.0, right: 5.0),
              child: new Material(
                child: InkWell(
                    // When the user taps the button, show a snackbar
                    onTap: () {
                      setState(() {
                        groupListTapped[index]
                            ? groupListTapped[index] = false
                            : groupListTapped[index] = true;
                      });
                    },
                    child: Container(
                      color: groupListTapped[index]
                          ? Colors.white10
                          : Color(0xFFf79646),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "${groupListing[index]}",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 25.0),
                            ),
                            groupListTapped[index]
                                ? new IconTheme(
                                    data: new IconThemeData(
                                        color: Colors.greenAccent),
                                    child:
                                        new Icon(FontAwesomeIcons.checkCircle),
                                  )
                                : new Text(""),
                          ]),
                    )),
                color: Colors.transparent,
              ),
              color: bgColor,
            );
          });
    }
  }

  _longPressMenu(BuildContext context) {
    /* Navigator.push(
        context, MaterialPageRoute(builder: (context) => longPress()));*/
  }

  play() async {
    print("play");
    //String localUrl = await audioProvider.load();
    audioPlayer.play(_audioRecording, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    bgColor = Color(0xFFf79646);
    _user = AppStateContainer.of(context).user;

    _appBarHeight = MediaQuery.of(context).size.height / 6 + 20;

    if (_user.action != null &&
        _user.action.containsKey("Action") &&
        _user.action["Action"] == "ReplyToChat") {
      _privateChat = true;
      print(_user.action['UserID']);
      bgColor = Color(0xFF46b754);
    }

    if (_user.action != null &&
        _user.action.containsKey("Action") &&
        _user.action["Action"] == "ReplyToGroup") {
      _privateGroupChat = true;
      bgColor = Color(0xFF46b754);
    }

    if (AppStateContainer.of(context).device == Device.watch) {
      return new GestureDetector(
          onLongPress: () {
            //       this._longPressMenu(context);
          },
          child: new Scaffold(
              resizeToAvoidBottomPadding: false, body: _buildPageView()));
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child:
              new Scaffold(body: new Builder(builder: (BuildContext context) {
            _scaffoldContext = context;
            return new CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: true,
                    pinned: true,
                    snap: true,
                    backgroundColor: bgColor,
                    leading: new IconButton(
                      icon: new Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Hero(
                                tag: 'say',
                                child: new GestureDetector(
                                  onTap: () {
                                    chooseSourceBg();
                                  },
                                  child: Text("I want to Say ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24.0,
                                      )),
                                )),
                            IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(Icons.chat),
                            ),
                          ]),
                      background: _user.sayPic != null
                          ? new ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: new CachedNetworkImage(
                                imageUrl: _user.sayPic,
                                height: 96.0,
                                width: 96.0,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      /* background:  new Material(
                                elevation: 4.0,
                                shape: CircleBorder(),
                                color: Colors.transparent,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _user.profilePic),
                                  radius: 30.0,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/profile');
                                    },
                                    child: null,
                                  ),
                                ),
                              )*/
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Column(children: [
                      Container(
                          color: bgColor,
                          child: Column(children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 60.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildAudioButton(),
                                    _buildAudioRecordingButton(),
                                    _buildPictureButton(),
                                  ]),
                            ),
                            _image == null
                                ? Container()
                                : Container(child: Image.file(_image)),
                            Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    _audioRecording == null
                                        ? Container()
                                        : _buildAudioPlayButton(),
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      child: _buildTextInput(),
                                    ),
                                  ],
                                )),
                            _buildGroups(context),
                            keywordsFilter.length != 0
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    child: _buildkeywords(context),
                                  )
                                : Container(),
                            sending == true
                                ? Center(child: CircularProgressIndicator())
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.height / 14,
                                    child: Container(
                                      child: new InkWell(
                                        onTap: () {
                                          _shoutout();
                                        },
                                        child: new Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                30.0,
                                            height: 50.0,
                                            decoration: new BoxDecoration(
                                              color: Colors.yellow,
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0),
                                            ),
                                            child: new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Text(
                                                    'Say',
                                                    style: new TextStyle(
                                                        fontSize: 40.0,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  new IconTheme(
                                                    data: new IconThemeData(
                                                        color: Colors.blue),
                                                    child: new Icon(Icons.chat),
                                                  ),
                                                ])),
                                      ),
                                    )),
                            _buildCloseButton(),
                          ])),
                    ])
                  ]))
                ]);
          })));
    }
  }

  Future<bool> uploadPictureFile() async {
    String photoUrl;
    String name;

    name = new DateTime.now().millisecondsSinceEpoch.toString() +
        _user.id +
        ".jpg";

    if (_image != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dl = await (await task.onComplete).ref.getDownloadURL();
      downloadUrl = dl.toString();
    }
  }

  Future<bool> uploadAudioFile() async {
    String audioUrl;
    String name;
    File recordFile;

    if (_audioRecording != null) {
      recordFile = new File(_audioRecording);
    }
    name = new DateTime.now().millisecondsSinceEpoch.toString() +
        _user.id +
        ".m4a";

    if (recordFile != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(recordFile);
      var dl = await (await task.onComplete).ref.getDownloadURL();
      downloadAudioUrl = dl.toString();
    }
  }

  playClick() async {
    final file = new File('${(await getTemporaryDirectory()).path}/click.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());

    final result = await audioPlayer.play(file.path, isLocal: true);
    //String localUrl = await audioProvider.load();
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/click.mp3');
  }
  Future<ByteData> loadAsset2() async {
    return await rootBundle.load('assets/sent.mp3');
  }
  playSent() async {
    final file = new File('${(await getTemporaryDirectory()).path}/sent.mp3');
    await file.writeAsBytes((await loadAsset2()).buffer.asUint8List());

    final result = await audioPlayer.play(file.path, isLocal: true);
    //String localUrl = await audioProvider.load();
  }

  void _shoutout() async {
    playClick();
    setState(() {
      sending = true;
    });
    await uploadPictureFile();
    await uploadAudioFile();

    _addMessage(downloadUrl);
    /*
    var fcm = new FcmHelper();
    var data = await Firestore.instance.collection('users').getDocuments();
    data.documents.forEach((doc) {
      print(doc["fcmToken"]);
      fcm.sendNotification("Hey", txt.text, doc["fcmToken"]);
    });
*/

    //   final snackBar = SnackBar(content: Text("Msg Sent!"));
    // Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    playSent();
    Navigator.pop(context, true);
  }

  Future<Null> _addMessage(String downloadUrl) async {
    List<String> tags = new List<String>();

    if (_privateChat) {
      String currentId = _user.id;
      String peerId = _user.action['UserID'];
      String groupChatId;

      if (currentId.hashCode <= peerId.hashCode) {
        groupChatId = '$currentId-$peerId';
      } else {
        groupChatId = '$peerId-$currentId';
      }

      var newMessage = new Map<String, dynamic>();
      newMessage = new Map<String, dynamic>();

      newMessage['message'] = txt.text;
      newMessage['senderAvatar'] = _user.avatarname;
      newMessage['idFrom'] = currentId;
      newMessage['idTo'] = peerId;
      newMessage['timestamp'] = new DateTime.now();
      newMessage['pic_embed'] = downloadUrl;
      newMessage['audio_embed'] = downloadAudioUrl;

      await Firestore.instance
          .collection('chats')
          .document(groupChatId)
          .collection(groupChatId)
          .document(newMessage['timestamp'].millisecondsSinceEpoch.toString())
          .setData(newMessage);

      List<String> members = new List<String>();
      members.add(currentId);
      members.add(peerId);

      await Firestore.instance
          .collection("chats")
          .document(groupChatId)
          .setData({
        'senderID': newMessage['idFrom'],
        'lastupdate': newMessage['timestamp'],
        'message': newMessage['message'],
        'pic_embed': newMessage['pic_embed'],
        'audio_embed': newMessage['audio_embed'],
        'type': "private",
        'membersID': members,
      }).catchError((e) {
        exit(0);
        print(e);
      });

      Fluttertoast.showToast(msg: "Sent!!");

      var fcm = new FcmHelper();
      fcm.sendNotification(
          "Interest Me",
          "${_user.action['UserName']} ${newMessage['message']}",
          _user.action["UserMFCM"]);
      fcm.sendNotification(
          "Interest Me",
          "${_user.action['UserName']} ${newMessage['message']}",
          _user.action["UserWFCM"]);
      Navigator.pop(context, true);
      return null;
    }

    for (int i = 0; i < keywordsFilterTapped.length; i++) {
      if (keywordsFilterTapped[i]) {
        tags.add(keywordsFilter[i]);
      }
    }
    for (int i = 0; i < groupListTapped.length; i++) {
      if (i == 0) // to everyone
      {
        if (groupListTapped[i]) {
          /*
          Firestore.instance.collection("generalChat").add(<String, dynamic>{
            'sender': _user.username,
            'senderAvatar': _user.avatarname,
            'message': txt.text,
            'timestamp': FieldValue.serverTimestamp(),
          }).catchError((e) {
            print(e);
          });
          */

          String currentId = _user.id;
          String groupChatId = "General";

          var newMessage = new Map<String, dynamic>();
          newMessage = new Map<String, dynamic>();
          newMessage['message'] = txt.text;
          newMessage['senderAvatar'] = _user.avatarname;
          newMessage['idFrom'] = currentId;
          newMessage['idTo'] = "public";
          newMessage['timestamp'] = new DateTime.now();
          newMessage['keywords'] = tags;
          newMessage['likeCount'] = 0;
          List<String> likeList = new List<String>();
          newMessage['likeList'] = likeList;
          newMessage['pic_embed'] = downloadUrl;
          newMessage['audio_embed'] = downloadAudioUrl;

          await Firestore.instance
              .collection('chats')
              .document(groupChatId)
              .collection(groupChatId)
              .document(
                  newMessage['timestamp'].millisecondsSinceEpoch.toString())
              .setData(newMessage);

          await Firestore.instance
              .collection("chats")
              .document(groupChatId)
              .setData({
            'senderID': newMessage['idFrom'],
            'lastupdate': newMessage['timestamp'],
            'message': newMessage['message'],
            'searchable': true,
          }).catchError((e) {
            exit(0);
            print(e);
          });
          Fluttertoast.showToast(msg: "Sent!!");

          updateFollowers(_user.followers, groupChatId,
              newMessage['timestamp'].millisecondsSinceEpoch.toString());
        }
      } else {
        List<dynamic> uid = new List<dynamic>();
        if (groupListTapped[i]) {
          String currentId = _user.id;
          String groupChatId = groupListing[i];

          var newMessage = new Map<String, dynamic>();
          newMessage = new Map<String, dynamic>();
          newMessage['message'] = txt.text;
          newMessage['idFrom'] = currentId;
          newMessage['idTo'] = "Group";
          newMessage['timestamp'] = new DateTime.now();
          newMessage['keywords'] = tags;
          newMessage['likeCount'] = 0;
          List<String> likeList = new List<String>();
          newMessage['likeList'] = likeList;
          newMessage['pic_embed'] = downloadUrl;
          newMessage['audio_embed'] = downloadAudioUrl;

          await Firestore.instance
              .collection('chats')
              .document(groupChatId)
              .collection(groupChatId)
              .document(
                  newMessage['timestamp'].millisecondsSinceEpoch.toString())
              .setData(newMessage);

          await Firestore.instance
              .collection("chats")
              .document(groupChatId)
              .setData({
            'senderID': newMessage['idFrom'],
            'lastupdate': newMessage['timestamp'],
            'message': newMessage['message'],
          }).catchError((e) {
            exit(0);
            print(e);
          });

          Fluttertoast.showToast(msg: "Sent!!");

          var fcm = new FcmHelper();

          uid = _user.groups[groupListing[i]];
          uid.forEach((id) {
            Firestore.instance
                .collection('users')
                .document(id)
                .get()
                .then((dataUser) {
              fcm.sendNotification(
                  "Interest Me",
                  "${_user.avatarname} ${newMessage['message']}",
                  dataUser["fcmMToken"]);
              fcm.sendNotification(
                  "Interest Me",
                  "${_user.avatarname} ${newMessage['message']}",
                  dataUser["fcmWToken"]);
            }).catchError((onError) {
              print(onError.toString());
            });

            updateFollowers(_user.followers, groupChatId,
                newMessage['timestamp'].millisecondsSinceEpoch.toString());
/*
          fcm.sendNotification(
              "Interest Me",
              "${_user.avatarname} ${newMessage['message']}",
              id);
          fcm.sendNotification(
              "Interest Me",
              "${_user.action['UserName']} ${newMessage['message']}",
              _user.action["UserWFCM"]);
*/
          });
        }
      }
    }
  }

  void updateFollowers(
      List<dynamic> followers, String groupChatID, String msgDocID) {
    followers.forEach((follower) {
      List<String> updateData = new List<String>();
      updateData.add(groupChatID);
      updateData.add(msgDocID);
      Firestore.instance.collection("users").document(follower).updateData({
        'following.${_user.id}': updateData,
      }).catchError((e) {
        print(e);
      });
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
/*
class longPress extends StatelessWidget {
  const longPress({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.deepOrange,
        child: new Center(
          child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(right: 18.0, bottom: 10.0),
                        child: IconButton(
                            icon: new IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(FontAwesomeIcons.backward,
                                  size: 50.0),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            })),
                    Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Close",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        )),
                  ])),
        ));
  }
}
*/

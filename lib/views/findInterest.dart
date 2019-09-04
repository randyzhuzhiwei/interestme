import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/speech_recognition.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';

const double _appBarHeight = 110.0;

enum ConfirmAction { Cancel, Confirm }

class FindInterestScreen extends StatefulWidget {
  @override
  _FindInterestScreenState createState() => new _FindInterestScreenState();
}

class _FindInterestScreenState extends State<FindInterestScreen>
    with TickerProviderStateMixin {
  SpeechRecognition _speech;
  @override
  User _user;

  final controller = PageController(initialPage: 1);

  AnimationController _controller;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  bool _hasStarted = false;
  String _currentLocale = 'en_US';
  String _transcription = 'testing';
  var txt = new TextEditingController();
  BuildContext _scaffoldContext;
  Color bgColor = Color(0xFFee3338);
  ScrollController _scrollController= new ScrollController();
  Timer timer;

  @override
  initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    activateSpeechRecognizer();
    txt.text = "YOUTUBE";
      var _duration = new Duration(seconds: 1);
      timer = new Timer(_duration, scrollBottom);
  }
scrollBottom()
{

_scrollController.animateTo(
           _scrollController.position.pixels+50.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
          );
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
        //    final snackBar = SnackBar(content: Text('Speech listening'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      });

  void onRecognitionResult(String text) => setState(() {
        _transcription = text;
        //    final snackBar = SnackBar(content: Text('Results:${_transcription}'));
        //    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        txt.text = _transcription;
      });

  void onRecognitionComplete() => setState(() {
        _isListening = false;
        _hasStarted = true;
        controller.jumpToPage(2);
        // final snackBar = SnackBar(content: Text('Speech listening complete. Results:${_transcription}'));
        //  Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
      });

  void getKeyboard(BuildContext context) =>
      _speech.getKeyboard(text: txt.text).then((result) {
        //       final snackBar = SnackBar(content: Text('_MyAppState.start => result ${result}'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        //print('_MyAppState.start => result ${result}');
      });

  void onKeyboardResult(String text) => setState(() {
        //    final snackBar = SnackBar(content: Text('Results:${_transcription}'));
        //    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        txt.text = text;
      });

  void start(BuildContext context) =>
      _speech.listen(locale: _currentLocale).then((result) {
        setState(() {
          _isListening = true;
        });
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
                        child:
                            new Icon(FontAwesomeIcons.microphone, size: 40.0),
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
                      child: new Icon(FontAwesomeIcons.microphone, size: 30.0),
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
                    child: new Icon(FontAwesomeIcons.microphone, size: 30.0),
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
                    child: new Icon(FontAwesomeIcons.microphone, size: 30.0),
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
                        child:
                            new Icon(FontAwesomeIcons.microphone, size: 30.0),
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
                  child: new Icon(FontAwesomeIcons.microphone, size: 30.0),
                ),
                onPressed: null,
              )));
    }
  }

  Widget _buildTextInput() {
    txt.text = txt.text.toUpperCase();
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: bgColor,
          child: Container(
              margin: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 60.0, bottom: 10.0),
              child: Column(children: <Widget>[
                new GestureDetector(
                  onTap: () {
                    getKeyboard(context);
                  },
                  child: new Text(
                    txt.text,
                    maxLines: 3,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15.0),
                  ),
                ),
                Material(
                    color: bgColor,
                    child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: new InkWell(
                            onTap: () {
                              if (txt.text == "") {
                                Fluttertoast.showToast(msg: "Enter a keyword");
                                return;
                              }
                              Map<String, dynamic> _action = {
                                "Action": "Search",
                                "SearchTxt": txt.text,
                              };
                              AppStateContainer.of(context).user.action =
                                  _action;
                              Navigator.of(context).pushNamed('/searchResults');
                            },
                            child: Column(children: <Widget>[
                              Icon(FontAwesomeIcons.search,
                                  color: Colors.white),
                              Text(
                                "Search",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20.0),
                              ),
                            ]))))
              ])));
    } else {
      return new TextFormField(
        controller: txt,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        style: new TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0),
        decoration: InputDecoration(
          hintText: "YOUTUBE",
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
    return PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _buildOptionPage(),
        _buildAudioButton(),
        _buildTextInput(),
        _buildCloseButton()
      ],
    );
  }

  Widget _buildSearch() {
    return null;
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
    
    name = _user.username+"findBg"+new DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg";

    if (_image != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dl = await (await task.onComplete).ref.getDownloadURL();
        photoUrl = dl.toString();
      Firestore.instance.collection("users").document(_user.id).updateData({
        'find_pic': photoUrl,
      }).catchError((e) {
       exit(0);
        print(e);
      });
      AppStateContainer.of(context).user.findPic = photoUrl;
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
  Widget build(BuildContext context) {
    // TODO: implement build

    _user = AppStateContainer.of(context).user;
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Scaffold(
          resizeToAvoidBottomPadding: false, body: _buildPageView());
      //   Stack(
      //  fit: StackFit.expand,

    } else {
     return new WillPopScope(
          onWillPop: _onBackPressed,
          child:
              new Scaffold(body: new Builder(builder: (BuildContext context) {
               return new CustomScrollView(controller: _scrollController,
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
                                  child: Text("Find Interest ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24.0,
                                      )),
                                )),
                              
                              IconTheme(
                                data: new IconThemeData(color: Colors.white),
                                child: new Icon(Icons.search),
                              ),
                            ]),
  background: _user.findPic != null
                          ? new ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: new CachedNetworkImage(
                                imageUrl: _user.findPic,
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
    delegate: SliverChildListDelegate(
      [   Container(
                    color: bgColor,
                    height:MediaQuery.of(context).size.height,
                    child: Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 60.0),
                      ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: new Text(
                                  "Search",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 30.0),
                                ),
                              )),
                          Container(
                              color: Colors.white,
                              child: Container(
                                margin: EdgeInsets.only(top: 10.0),
                                padding: EdgeInsets.only(left: 10.0),
                                child: new TextField(
                                  controller: txt,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20.0),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              )),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width - 30,
                              child: Container(
                                child: new InkWell(
                                  onTap: () {
                                    
    txt.text = txt.text.toUpperCase();
                                    if (txt.text == "") {
                                      Fluttertoast.showToast(
                                          msg: "Enter a keyword");
                                      return;
                                    }
                                    Map<String, dynamic> _action = {
                                      "Action": "Search",
                                      "SearchTxt": txt.text,
                                    };
                                    AppStateContainer.of(context).user.action =
                                        _action;
                                    Navigator.of(context)
                                        .pushNamed('/searchResults');
                                  },
                                  child: new Container(
                                      width: 100.0,
                                      height: 50.0,
                                      decoration: new BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius:
                                            new BorderRadius.circular(10.0),
                                      ),
                                      child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Text(
                                              'Search ',
                                              style: new TextStyle(
                                                  fontSize: 40.0,
                                                  color: Colors.white),
                                            ),
                                            new IconTheme(
                                              data: new IconThemeData(
                                                  color: Colors.teal),
                                              child: new Icon(
                                                  FontAwesomeIcons.search),
                                            ),
                                          ])),
                                ),
                              )),
                         _buildCloseButton(),
                    ]))]))]);
                    
          })));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }

  double getLayoutHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    print(_appBarHeight);
    return (height - _appBarHeight - 170) / 5;
  }
}

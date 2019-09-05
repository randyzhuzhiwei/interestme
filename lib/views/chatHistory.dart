import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/date_helper.dart';
import 'package:intl/intl.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';
import '../models/speech_recognition.dart';
import '../data/fcm_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayer/audioplayer.dart';
import 'audio_provider.dart';
import 'package:audio_recorder/audio_recorder.dart';

const double _appBarHeight = 110.0;

class ChatHistoryScreen extends StatefulWidget {
  @override
  _ChatHistoryScreenState createState() => new _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with TickerProviderStateMixin {
  User _user;
  FocusNode _focusNode = new FocusNode();
  String _audioRecording = null;
  final formkey = new GlobalKey<FormState>();

  Recording _recording = new Recording();
  bool _isRecording = false;
  File _image;
  File _image2;
  String downloadUrl = null;
  String downloadAudioUrl = null;
  String groupChatId;
  String chatPartnerName;
  String chatPartnerID;
  String chatPartnerMFCM;
  String chatPartnerWFCM;
  String chatPartnerProfilePic;
  ScrollController _scrollController = new ScrollController();
  bool sending;

  Timer timer;

  AudioPlayer audioPlayer = new AudioPlayer();
  var txt = new TextEditingController();

  Color bgColor;
  final controller = PageController(initialPage: 0);
  var listMessage;

  @override
  initState() {
    sending = false;
    super.initState();
    _focusNode.addListener(_focusNodeListener);

    var _duration = new Duration(seconds: 1);
    timer = new Timer(_duration, scrollBottom);
  }

  scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<Null> _focusNodeListener() async {
    if (_focusNode.hasFocus) {
      print('TextField got the focus');
    } else {
      print('TextField lost the focus');
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusNodeListener);
    super.dispose();
  }

  playLocal() async {
    print("play");
    //String localUrl = await audioProvider.load();
    audioPlayer.play(_audioRecording, isLocal: true);
  }

  Widget _buildOptionPage() {
    return Material(
        color: Colors.blueGrey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(height: MediaQuery.of(context).size.height / 4),
              Container(
                  padding: EdgeInsets.only(
                    left: 20.0,
                  ),
                  child: InkWell(
                      onTap: () {
                        Map<String, dynamic> _action = {
                          "Action": "ReplyToChat",
                          "UserID": chatPartnerID,
                          "UserName": chatPartnerName,
                          "UserMFCM": chatPartnerMFCM,
                          "UserWFCM": chatPartnerWFCM
                        };
                        AppStateContainer.of(context).user.action = _action;
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/say');
                      },
                      child: Row(children: <Widget>[
                        Container(
                          child: IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child: new Icon(FontAwesomeIcons.reply, size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0),
                            height: 20.0,
                            child: Text(
                              "Reply ${chatPartnerName}",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18.0),
                            )),
                      ]))),
              Container(
                  padding: EdgeInsets.only(
                    left: 20.0,
                  ),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(children: <Widget>[
                        Container(
                          child: IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child:
                                new Icon(FontAwesomeIcons.backward, size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0, top: 12.0),
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

  void play(String audio_url) async {
    AudioProvider audioProvider = new AudioProvider(audio_url);
    String localUrl = await audioProvider.load();
    audioPlayer.play(localUrl, isLocal: true);
  }

  Widget _buildAudioPlayButton() {
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
              onPressed: playLocal,
            )));
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    var formatter = new DateFormat('HH:mm:ss dd-MM-yy');
    String formattedD = formatter.format(document['timestamp']);
    double dFontSize = 10.0;
    double mFontSize = 10.0;
    if (AppStateContainer.of(context).device == Device.watch) {
      dFontSize = 10.0;
      mFontSize = 10.0;
    } else {
      dFontSize = 12.0;
      mFontSize = 16.0;
    }
    String audio_url = document['audio_embed'];
    String message = document['message'];
    String pic_url = document['pic_embed'];

    if (document['idFrom'] == _user.id) {
      // Right (my message)
      return Container(
        child: Column(
          children: <Widget>[
            Column(children: <Widget>[
              pic_url == null
                  ? Container()
                  : Container(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: pic_url,
                        fit: BoxFit.contain,
                      ),
                    ),
            ]),
            Column(children: <Widget>[
              audio_url == null
                  ? Container()
                  : Container(
                      child: IconButton(
                        icon: new IconTheme(
                          data: new IconThemeData(color: Colors.white),
                          child: new Icon(FontAwesomeIcons.play, size: 30.0),
                        ),
                        onPressed: () {
                          play(audio_url);
                        },
                      ),
                    ),
            ]),

            Container(
              child: Text(
                message,
                style: TextStyle(fontSize: mFontSize, color: Colors.black),
                maxLines: 30,
              ),
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                  right: 10.0,
                  left: 40.0),
            ),

            Container(
              child: Text(
                formattedD,
                style:
                    TextStyle(fontSize: dFontSize, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(right: 20.0, top: 5.0, bottom: 5.0),
            ),
            //: Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        margin: EdgeInsets.only(bottom: 5.0),
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Column(children: <Widget>[
              pic_url == null
                  ? Container()
                  : Container(
                      child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: pic_url,
                          fit: BoxFit.contain),
                    ),
            ]),
            Column(children: <Widget>[
              audio_url == null
                  ? Container()
                  : Container(
                      child: IconButton(
                        icon: new IconTheme(
                          data: new IconThemeData(color: Colors.white),
                          child: new Icon(FontAwesomeIcons.play, size: 30.0),
                        ),
                        onPressed: () {
                          play(audio_url);
                        },
                      ),
                    ),
            ]),
            Container(
              child: Text(
                message,
                style: TextStyle(fontSize: mFontSize, color: Colors.black),
                maxLines: 30,
              ),
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.only(left: 10.0, right: 40.0),
            ),
            // Time
            // isLastMessageLeft(index) ?
            Container(
              child: Text(
                formattedD,
                style:
                    TextStyle(fontSize: dFontSize, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
            ),
            //: Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 5.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == _user.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != _user.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> uploadAudioFile() async {
    String audioUrl;
    String name;

    if (_audioRecording != null) {
      File recordFile = new File(_audioRecording);

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
  }

  Future<bool> uploadFile() async {
    String photoUrl;
    String name;

    name = new DateTime.now().millisecondsSinceEpoch.toString() +
        _user.id +
        ".jpg";

    if (_image2 != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image2);
      var dl = await (await task.onComplete).ref.getDownloadURL();
      downloadUrl = dl.toString();
    }
  }

  Widget _buildPictureButton() {
    return new Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(bottom: 5.0, right: 10.0),
        child: Material(
            elevation: 1.0,
            shape: CircleBorder(),
            color: Colors.transparent,
            child: IconButton(
              icon: new IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(FontAwesomeIcons.image, size: 30.0),
              ),
              onPressed: chooseSource,
            )));
  }

  Widget _buildAudioRecordingButton() {
    if (_isRecording) {
      return new Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(bottom: 5.0, right: 10.0),
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
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(bottom: 5.0, right: 10.0),
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
     await AudioRecorder.stop();
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _user = AppStateContainer.of(context).user;
    bgColor = Color(0xFF46b754);
    if (_user.action != null &&
        _user.action.containsKey("Action") &&
        _user.action["Action"] == "ChatHistory") {
      groupChatId = _user.action["groupID"];
      chatPartnerName = _user.action["chatPartnerName"];
      chatPartnerID = _user.action["chatPartnerID"];
      chatPartnerMFCM = _user.action["chatPartnerMFCM"];
      chatPartnerWFCM = _user.action["chatPartnerWFCM"];
      chatPartnerProfilePic = _user.action["chatPartnerProfilePic"];
    } else {
      Navigator.of(context).pop();
    }

    print(groupChatId);
    // groupChatId = "-LQOJ7x0cJ67TikL_gxW--LQHQNYhTCQa8s9B5c9p";
    if (AppStateContainer.of(context).device == Device.watch) {
      return new GestureDetector(
          onLongPress: () {
            //          this._addNewChat(context,chatPartnerID[controller.page.round()],chatPartnerName[controller.page.round()]);
          },
          child: Material(
            color: bgColor,
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('chats')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  listMessage = snapshot.data.documents;
                  return PageView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      children: <Widget>[
                        Column(children: <Widget>[
                          Container(
                              color: Colors.green[200],
                              height: 35.0,
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Center(
                                      child: Text(
                                    chatPartnerName,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15.0),
                                  )))),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemBuilder: (context, index) => buildItem(
                                  index, snapshot.data.documents[index]),
                              itemCount: snapshot.data.documents.length,
                              reverse: true,
                              //controller: listScrollController,
                            ),
                          ),
                          Container(height: 20.0)
                        ]),
                        _buildOptionPage(),
                      ]);
                }
              },
            ),
          ));
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child:
              new Scaffold(body: new Builder(builder: (BuildContext context) {
            return new CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 150.0,
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
                              tag: 'chat',
                              child: Text("Chat ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24.0,
                                  )),
                            ),
                            IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(FontAwesomeIcons.comment),
                            ),
                          ]),
                      background: new ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: new CachedNetworkImage(
                          imageUrl: chatPartnerProfilePic,
                          height: 96.0,
                          width: 96.0,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                              width: MediaQuery.of(context).size.width,
                              child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection('chats')
                                    .document(groupChatId)
                                    .collection(groupChatId)
                                    .orderBy('timestamp', descending: true)
                                    .limit(20)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    listMessage = snapshot.data.documents;
                                    return Column(children: <Widget>[
                                      Container(
                                          color: Colors.green[200],
                                          height: 35.0,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Container(
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: Center(
                                                  child: Text(
                                                chatPartnerName,
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 15.0),
                                              )))),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        padding: EdgeInsets.all(10.0),
                                        itemBuilder: (context, index) =>
                                            buildItem(index,
                                                snapshot.data.documents[index]),
                                        itemCount:
                                            snapshot.data.documents.length,
                                        reverse: true,
                                        //controller: listScrollController,
                                      ),
                                    ]);
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildAudioRecordingButton(),
                                    _buildPictureButton(),
                                  ]),
                            ),
                            _image == null
                                ? Container()
                                : Container(child: Image.file(_image)),
                            _audioRecording == null
                                ? Container()
                                : _buildAudioPlayButton(),
                            Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(0.0),
                                margin: EdgeInsets.all(0.0),
                                width: MediaQuery.of(context).size.width,
                                child: TextField(
                                  controller: txt,
                                  maxLines: 3,
                                  keyboardType: TextInputType.multiline,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 18.0),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                  ),
                                )),
                            sending == true
                                ? Center(child: CircularProgressIndicator())
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.height / 14,
                                    margin: EdgeInsets.only(top: 40.0),
                                    child: Container(
                                      child: new InkWell(
                                        onTap: () {
                                          _replyMessage(
                                              groupChatId,
                                              chatPartnerName,
                                              chatPartnerID,
                                              chatPartnerMFCM,
                                              chatPartnerWFCM);
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
                                                    'Send',
                                                    style: new TextStyle(
                                                        fontSize: 40.0,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  new IconTheme(
                                                    data: new IconThemeData(
                                                        color: Colors.blue),
                                                    child: new Icon(Icons.send,
                                                        size: 40.0),
                                                  ),
                                                ])),
                                      ),
                                    )),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                child: _buildCloseButton())
                          ])),
                    ])
                  ]))
                ]);
          })));
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

  void _replyMessage(
      String groupChatId,
      String chatPartnerName,
      String chatPartnerID,
      String chatPartnerMFCM,
      String chatPartnerWFCM) async {
    _image2 = _image;
    setState(() {
      sending = true;
      _image = null;
    });
    String msg = txt.text;
    String currentId = _user.id;
    String peerId = chatPartnerID;

    await uploadFile();
    await uploadAudioFile();

    var newMessage = new Map<String, dynamic>();
    newMessage = new Map<String, dynamic>();

    newMessage['message'] = msg;
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

    await Firestore.instance.collection("chats").document(groupChatId).setData({
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
        chatPartnerMFCM);
    fcm.sendNotification(
        "Interest Me",
        "${_user.action['UserName']} ${newMessage['message']}",
        chatPartnerWFCM);
    txt.text = "";
    sending = false;
    _image = null;
    setState(() {});
  }

  Widget _buildCloseButton() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: Color(0xFFf79646),
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
              margin: EdgeInsets.all(0.0),
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

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
}

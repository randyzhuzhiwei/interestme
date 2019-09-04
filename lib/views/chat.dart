import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../data/date_helper.dart';
import 'package:intl/intl.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';
import '../models/speech_recognition.dart';
import '../data/fcm_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

const double _appBarHeight = 110.0;

enum ConfirmAction { Cancel, Confirm }

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User _user;

  String currentId;

  Color bgColor;
  List<Widget> list = new List<Widget>();
  bool isLoading;
  StreamSubscription<QuerySnapshot> streamSub;

  StatusOverlay modalScreen;

  List<String> chatPartnerName = new List<String>();
  List<String> chatPartnerProfilePic = new List<String>();
  List<String> chatPartnerID = new List<String>();
  List<String> chatPartnerMFCM = new List<String>();
  List<String> chatPartnerWFCM = new List<String>();
  List<String> chatPartnerStatus = new List<String>();
  List<String> chatGrouprID = new List<String>();
  List<DateTime> lastUpdate = new List<DateTime>();
  List<String> message = new List<String>();
  List<String> senderID = new List<String>();

  ScrollController _scrollController = new ScrollController();
  Timer timer;
  String _userStatus;
  String _userProfilePic;
  final controller = PageController(initialPage: 0);

  var data;
  var data2;

  @override
  initState() {
    isLoading = true;
    super.initState();
  }

  scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.pixels + 150.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  ///watch only
  ///
  ///
  ///
  ///
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
    if (imageBg != null) _asyncConfirmDialog(context, imageBg);
  }

  Future<bool> uploadBgPictureFile(File _image) async {
    String photoUrl;
    String name;

    name = _user.username +
        "findBg" +
        new DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg";

    if (_image != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      print(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dl = await (await task.onComplete).ref.getDownloadURL();
      photoUrl = dl.toString();
      Firestore.instance.collection("users").document(_user.id).updateData({
        'chat_pic': photoUrl,
      }).catchError((e) {
        exit(0);
        print(e);
      });
      AppStateContainer.of(context).user.chatPic = photoUrl;
      setState(() {});
    }
  }

  Future<ConfirmAction> _asyncConfirmDialog(
      BuildContext context, File _image) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wallpaper'),
          content: const Text('Change wallpaper?'),
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

  void getChatHistory() async {
    print(currentId);

    data = await Firestore.instance
        .collection("chats")
        .where("membersID", arrayContains: currentId)
        // .where("message", isEqualTo:  "finch")
        .orderBy("lastupdate", descending: true)
        .getDocuments();

//no private chat
/*
    if (data.documents.length == 0) {
      for (int i = 0; i < _user.followers.length; i++) {
        chatPartnerID.add(_user.followers[i]);
      }
      _user.followering.forEach((key, value) {
        if (!chatPartnerID.contains(key)) chatPartnerID.add(key);
      });

      for (int i = 0; i < chatPartnerID.length; i++) {
        lastUpdate.add(new DateTime.now());
        message.add("Start Chat");
        senderID.add(_user.id);

        String currentId = _user.id;
        String peerId = chatPartnerID[i];
        String groupChatId;

        if (currentId.hashCode <= peerId.hashCode) {
          groupChatId = '$currentId-$peerId';
        } else {
          groupChatId = '$peerId-$currentId';
        }

        chatGrouprID.add(groupChatId);
      }

      await getUserDetails();

      for (int i = 0; i < chatPartnerID.length; i++) {
        String txtMsg;

        txtMsg = message[i];

        var formatter = new DateFormat('HH:mm:ss dd-MM-yy');
        String timestamp = formatter.format(lastUpdate[i]);

        if (AppStateContainer.of(context).device == Device.watch) {
          list.add(new PageView(
              scrollDirection: Axis.vertical,
              reverse: true,
              children: <Widget>[
                Material(
                    color: bgColor,
                    child: InkWell(
                        onTap: () {
                          Map<String, dynamic> _action = {
                            "Action": "ReplyToChat",
                            "UserID": chatPartnerID[i],
                            "UserName": chatPartnerName[i],
                            "UserMFCM": chatPartnerMFCM[i],
                            "UserWFCM": chatPartnerWFCM[i],
                          };
                          AppStateContainer.of(context).user.action = _action;
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/say');
                        },
                        child: new Center(
                            child: new Column(children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 15.0),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    chatPartnerProfilePic[i]),
                                radius: 40.0,
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                chatPartnerName[i],
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12.0),
                              )),
                          Container(
                              padding: EdgeInsets.only(left: 12.0, top: 10.0),
                              height: 60.0,
                              child: Text(
                                txtMsg,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12.0),
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                "",
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10.0),
                              )),
                        ])))),
                _buildOptionPage(chatPartnerID[i], chatPartnerName[i],
                    chatPartnerMFCM[i], chatPartnerWFCM[i])
              ]));
        } else {
          list.add(Material(
              color: bgColor,
              child: Container(
                  child: InkWell(
                      onTap: () {
                        Map<String, dynamic> _action = {
                          "Action": "ChatHistory",
                          "groupID": chatGrouprID[i],
                          "chatPartnerName": chatPartnerName[i],
                          "chatPartnerID": chatPartnerID[i],
                          "chatPartnerMFCM": chatPartnerMFCM[i],
                          "chatPartnerWFCM": chatPartnerWFCM[i],
                          "chatPartnerProfilePic": chatPartnerProfilePic[i],
                          "chatPartnerStatus": chatPartnerStatus[i],
                        };
                        AppStateContainer.of(context).user.action = _action;

                        Navigator.of(context).pushNamed('/chatHistory');
                      },
                      child: Row(children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: GestureDetector(
                                onTap: () {
                                  _showStatus(chatPartnerStatus[i],
                                      chatPartnerProfilePic[i]);
                                },
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      chatPartnerProfilePic[i]),
                                  radius: 40.0,
                                ))),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Text(chatPartnerName[i],
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 22.0))),
                                  Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(timestamp,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Container(
                                  padding: EdgeInsets.only(
                                      left: 15.0, right: 15.0, top: 15.0),
                                  child: txtMsg.length > 25
                                      ? Text(
                                          txtMsg.substring(0, 25),
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        )
                                      :
                                      //////Missing close button
                                      ///extbox too long,cannot see send button
                                      Text(
                                          txtMsg,
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        )),
                            ]),
                      ])))));
        }
      }
      /*  list.add(new PageView(
          scrollDirection: Axis.vertical,
          reverse: true,
          children: <Widget>[
            new Material(
                color: bgColor,
                child: InkWell(
                    // When the user taps the button, show a snackbar
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 55.0, bottom: 10.0),
                        child: Column(children: <Widget>[
                          IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child: new Icon(FontAwesomeIcons.checkCircle,
                                size: 40.0),
                          ),
                          Text(
                            "No Chat History\n Click to return",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20.0),
                          ),
                        ])))),
            _addChat(),
            _buildCloseButton()
          ]));
          */

      setState(() {
        isLoading = false;

        var _duration = new Duration(seconds: 1);
        timer = new Timer(_duration, scrollBottom);
      });
      return;
    } else {
      */
      data.documents.forEach((doc) {
        if (doc['membersID'][0] == _user.id) {
          chatPartnerID.add(doc['membersID'][1]);
        } else {
          chatPartnerID.add(doc['membersID'][0]);
        }

        lastUpdate.add(doc['lastupdate']);
        message.add(doc['message']);
        senderID.add(doc['senderID']);
        chatGrouprID.add(doc.documentID);
      });

//cross check with current chats with followers
      for (int i = 0; i < _user.followers.length; i++) {
        if (!chatPartnerID.contains(_user.followers[i])) {
          chatPartnerID.add(_user.followers[i]);

          lastUpdate.add(new DateTime.now());
          message.add("Start Chat");
          senderID.add(_user.id);

          String currentId = _user.id;
          String peerId = _user.followers[i];
          String groupChatId;

          if (currentId.hashCode <= peerId.hashCode) {
            groupChatId = '$currentId-$peerId';
          } else {
            groupChatId = '$peerId-$currentId';
          }

          chatGrouprID.add(groupChatId);
        }
      }
      
//cross check with current chats with followering
      _user.followering.forEach((key, value) {
        if (!chatPartnerID.contains(key)) {
          chatPartnerID.add(key);
          lastUpdate.add(new DateTime.now());
          message.add("Start Chat");
          senderID.add(_user.id);

          String currentId = _user.id;
          String peerId = key;
          String groupChatId;

          if (currentId.hashCode <= peerId.hashCode) {
            groupChatId = '$currentId-$peerId';
          } else {
            groupChatId = '$peerId-$currentId';
          }

          chatGrouprID.add(groupChatId);
        }
      });
// not too sure why this is needed?
/*
      for (int i = 0; i < chatPartnerID.length; i++) {
        lastUpdate.add(new DateTime.now());
        message.add("Start Chat");
        senderID.add(_user.id);

        String currentId = _user.id;
        String peerId = chatPartnerID[i];
        String groupChatId;

        if (currentId.hashCode <= peerId.hashCode) {
          groupChatId = '$currentId-$peerId';
        } else {
          groupChatId = '$peerId-$currentId';
        }

        chatGrouprID.add(groupChatId);
      }
    */
    await getUserDetails();

    for (int i = 0; i < chatPartnerID.length; i++) {
      String txtMsg;
      if (senderID[i] == _user.id) {
        txtMsg = "Me: ${message[i]}";
      } else {
        txtMsg = message[i];
      }
      DateTime today = new DateTime.now();
      int diffDays = today.difference(lastUpdate[i]).inDays;
       var formatter;
      if(diffDays==0)
      {
       formatter = new DateFormat.jm();
      }
      else
      { 
        formatter = new DateFormat('dd-MM-yy');
      }
      String timestamp = formatter.format(lastUpdate[i]);

      if (AppStateContainer.of(context).device == Device.watch) {
        list.add(new PageView(
            scrollDirection: Axis.vertical,
            reverse: true,
            children: <Widget>[
              Material(
                  color: bgColor,
                  child: InkWell(
                      onTap: () {
                        Map<String, dynamic> _action = {
                          "Action": "ChatHistory",
                          "groupID": chatGrouprID[i],
                          "chatPartnerName": chatPartnerName[i],
                          "chatPartnerID": chatPartnerID[i],
                          "chatPartnerMFCM": chatPartnerMFCM[i],
                          "chatPartnerWFCM": chatPartnerWFCM[i],
                          "chatPartnerProfilePic": chatPartnerProfilePic[i],
                          "chatPartnerStatus": chatPartnerStatus[i],
                        };
                        AppStateContainer.of(context).user.action = _action;

                        Navigator.of(context).pushNamed('/chatHistory');
                      },
                      child: new Center(
                          child: new Column(children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 15.0),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  chatPartnerProfilePic[i]),
                              radius: 40.0,
                            )),
                        Container(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text(
                              chatPartnerName[i],
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12.0),
                            )),
                        Container(
                            padding: EdgeInsets.only(left: 12.0, top: 10.0),
                            height: 60.0,
                            child: Text(
                              txtMsg,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12.0),
                            )),
                        Container(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text(
                              timestamp,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 10.0),
                            )),
                      ])))),
              _buildOptionPage(chatPartnerID[i], chatPartnerName[i],
                  chatPartnerMFCM[i], chatPartnerWFCM[i])
            ]));
      } else {
        list.add(Material(
            color: bgColor,
            child: Container(
                child: InkWell(
                    onTap: () {
                      Map<String, dynamic> _action = {
                        "Action": "ChatHistory",
                        "groupID": chatGrouprID[i],
                        "chatPartnerName": chatPartnerName[i],
                        "chatPartnerID": chatPartnerID[i],
                        "chatPartnerMFCM": chatPartnerMFCM[i],
                        "chatPartnerWFCM": chatPartnerWFCM[i],
                        "chatPartnerProfilePic": chatPartnerProfilePic[i],
                        "chatPartnerStatus": chatPartnerStatus[i],
                      };
                      AppStateContainer.of(context).user.action = _action;

                      Navigator.of(context).pushNamed('/chatHistory');
                    },
                    child: Row(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: GestureDetector(
                              onTap: () {
                                _showStatus(chatPartnerStatus[i],
                                    chatPartnerProfilePic[i]);
                              },
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    chatPartnerProfilePic[i]),
                                radius: 40.0,
                              ))),
                      Expanded(
                        child:
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(chatPartnerName[i],
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 22.0))),
                                Container(
                                  child: Text(timestamp,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 14.0)),
                                ),
                              ],
                            ),
                            Container(
                                padding: EdgeInsets.only(
                                    left: 15.0, right: 15.0, top: 15.0),
                                child: txtMsg.length > 25
                                    ? Text(
                                        txtMsg.substring(0, 25),
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18.0),
                                      )
                                    : Text(
                                        txtMsg,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18.0),
                                      )),
                          ])),
                    ])))));
      }
    }
    setState(() {
      isLoading = false;

      var _duration = new Duration(seconds: 1);
      timer = new Timer(_duration, scrollBottom);
    });
    return;
  }

  void _showStatus(String status, String profilePic) {
    print("here");
    Profile p = new Profile(profilePic, status);

    Navigator.of(context).push(modalScreen = new StatusOverlay(p));
  }

  void getUserDetails() async {


    QuerySnapshot data;

  List<String> tempChatPartnerName = new List<String>();
  List<String> tempChatPartnerProfilePic = new List<String>();
  List<String> tempChatPartnerStatus = new List<String>();
  List<String> tempChatPartnerMFCM = new List<String>();
  List<String> tempChatPartnerWFCM = new List<String>();
  List<String> tempChatPartnerDocID= new List<String>();

      data = await Firestore.instance
          .collection('users')
          .where("followers", arrayContains: _user.id)
          .getDocuments();

          data.documents.forEach((dataUser) {
            tempChatPartnerDocID.add(dataUser.documentID);
       tempChatPartnerName.add(dataUser["aname"]);
        tempChatPartnerProfilePic.add(dataUser["profile_pic"]);
        tempChatPartnerStatus.add(dataUser["description"]);
        tempChatPartnerMFCM.add(dataUser["fcmMToken"]);
        tempChatPartnerWFCM.add(dataUser["fcmWToken"]);
    });

  data = await Firestore.instance
          .collection('users')
          .where("followering", arrayContains: _user.id)
          .getDocuments();

    data.documents.forEach((dataUser) {
        if (!tempChatPartnerDocID.contains(dataUser.documentID)) {
       tempChatPartnerName.add(dataUser["aname"]);
        tempChatPartnerProfilePic.add(dataUser["profile_pic"]);
        tempChatPartnerStatus.add(dataUser["description"]);
        tempChatPartnerMFCM.add(dataUser["fcmMToken"]);
        tempChatPartnerWFCM.add(dataUser["fcmWToken"]);
        }
    });
    
   for (int i = 0; i < chatPartnerID.length; i++) {
        int y = tempChatPartnerDocID.indexOf(chatPartnerID[i]);
         chatPartnerName.add(tempChatPartnerName[y]);
        chatPartnerProfilePic.add(tempChatPartnerProfilePic[y]);
        chatPartnerStatus.add(tempChatPartnerStatus[y]);
        chatPartnerMFCM.add(tempChatPartnerMFCM[y]);
        chatPartnerWFCM.add(tempChatPartnerWFCM[y]);
   }


    /*
    for (int i = 0; i < chatPartnerID.length; i++) {
      await Firestore.instance
          .collection('users')
          .document(chatPartnerID[i])
          .get()
          .then((dataUser) {
        chatPartnerName.add(dataUser["aname"]);
        chatPartnerProfilePic.add(dataUser["profile_pic"]);
        chatPartnerStatus.add(dataUser["description"]);
        chatPartnerMFCM.add(dataUser["fcmMToken"]);
        chatPartnerWFCM.add(dataUser["fcmWToken"]);
      }).catchError((onError) {
        print(onError.toString());

        exit(0);
      });
    }
    */
  }

  @override
  void dispose() {
    //streamSub.cancel();
    super.dispose();
  }

  Widget _buildPage(
      String chatPartnerName,
      String chatPartnerProfilePic,
      String chatPartnerStatus,
      String message,
      String lastUpdate,
      Color color) {
    FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance.collection('users').document(currentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) return new Text('${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            break;
          default:
            {
              if (snapshot.hasData) {
                chatPartnerName = snapshot.data["aname"];
                chatPartnerName = snapshot.data["profile_pic"];

                return new Material(
                    color: color,
                    child: new Center(
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          /*  CircleAvatar(
                backgroundImage: NetworkImage(chatPartnerProfilePic),
                radius: 20.0,
              ),*/
                          Text(chatPartnerName),
                          Text(lastUpdate),
                          Text(message),
                        ])));
              } else {
                return new Material(
                    color: bgColor,
                    child: new Center(
                      child: new Text(
                        "No chat History",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30.0),
                      ),
                    ));
              }
            }
        }
      },
    );
  }

  _buildPageView() {
    getChatHistory();

    /*
      String chatPartnerID;
    String message;
    String chatPartnerName="a";
    String chatPartnerProfilePic="a";


    l.forEach((doc) {
      message = doc['message'];

      if (doc['membersID'][0] == _user.id) {
        chatPartnerID = doc['membersID'][1];
      } else {
        chatPartnerID = doc['membersID'][0];
      }
          chatPartnerName = data.aname;
          chatPartnerName = data["profile_pic"];
          
      Widget w = _buildPage(chatPartnerName, chatPartnerProfilePic, message,
          doc['lastupdate'].toString(), Color(0xFFf79646));
      list.add(w);
    });
    return list;
*/
  }

  _addNewChat(
      BuildContext context, String chatPartnerID, String chatPartnerName) {
    print(controller);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => longPress(chatPartnerID, chatPartnerName)));
  }

  void checkDB() async {
    String peerId = "-LQHQNYhTCQa8s9B5c9p";
    String groupChatId;

    //currentId = AppStateContainer.of(context).user.id;

    if (currentId.hashCode <= peerId.hashCode) {
      groupChatId = '$currentId-$peerId';
    } else {
      groupChatId = '$peerId-$currentId';
    }
    var newContact = new Map<String, dynamic>();
    List<String> _myList = new List();
    /*   chat group           
    */
    _myList.add(currentId);
    _myList.add(peerId);
    newContact['membersID'] = _myList;
    newContact['type'] = "private";
    newContact['lastupdate'] = new DateTime.now();
    newContact['message'] = "Test message2";

    Firestore.instance
        .collection("chats")
        .document(groupChatId)
        .setData(newContact);

    newContact = new Map<String, dynamic>();
    newContact['message'] = "hi, it is me again";
    newContact['idFrom'] = currentId;
    newContact['idTo'] = peerId;
    newContact['timestamp'] = new DateTime.now();

    Firestore.instance
        .collection('chats')
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData(newContact);
  }

  void _streamChats() async {
    streamSub = Firestore.instance
        .collection("chats")
        .where("membersID", arrayContains: currentId)
        .snapshots()
        .listen((data) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget _buildOptionPage(String chatPartnerID, String chatPartnerName,
      String chatPartnerMFCM, String chatPartnerWFCM) {
    print(chatPartnerMFCM);
    print(chatPartnerWFCM);
    print(chatPartnerID);

    if (AppStateContainer.of(context).device == Device.watch) {
      return Material(
          color: Colors.blueGrey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(height: 30.0),
                Container(
                    padding: EdgeInsets.only(
                      left: 20.0,
                    ),
                    child: InkWell(
                        onTap: () {
                          print(controller.page.round());
                          Map<String, dynamic> _action = {
                            "Action": "ReplyToChat",
                            "UserID": chatPartnerID,
                            "UserName": chatPartnerName,
                            "UserMFCM": chatPartnerMFCM,
                            "UserWFCM": chatPartnerWFCM
                          };
                          AppStateContainer.of(context).user.action = _action;
                          Navigator.of(context).pushNamed('/say');
                        },
                        child: Row(children: <Widget>[
                          Container(
                            child: IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child:
                                  new Icon(FontAwesomeIcons.reply, size: 30.0),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 5.0),
                              height: 20.0,
                              child: Text(
                                "Msg ${chatPartnerName}",
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
                          Navigator.pop(context);
                        },
                        child: Row(children: <Widget>[
                          Container(
                            child: IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(FontAwesomeIcons.backward,
                                  size: 30.0),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 5.0),
                              height: 20.0,
                              child: Text(
                                "Close",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18.0),
                              )),
                        ]))),
                Container(height: 30.0),
              ]));
    } else {
      return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20.0),
              child: new InkWell(
                onTap: () {
                  Map<String, dynamic> _action = {
                    "Action": "ReplyToChat",
                    "UserID": chatPartnerID,
                    "UserName": chatPartnerName,
                    "UserMFCM": chatPartnerMFCM,
                    "UserWFCM": chatPartnerWFCM
                  };
                  AppStateContainer.of(context).user.action = _action;
                  Navigator.of(context).pushNamed('/say');
                },
                child: new Container(
                    height: 50.0,
                    decoration: new BoxDecoration(
                      color: Colors.grey,
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Reply ${chatPartnerName}",
                            style: new TextStyle(
                                fontSize: 20.0, color: Colors.white),
                          ),
                          new IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child: new Icon(FontAwesomeIcons.reply),
                          ),
                        ])),
              ),
            ),
          ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _user = AppStateContainer.of(context).user;
    currentId = AppStateContainer.of(context).user.id;

    bgColor = Color(0xFF46b754);
    if (isLoading) {
      _buildPageView();
//checkDB();
    }

    if (AppStateContainer.of(context).device == Device.watch) {
      return new GestureDetector(
        onLongPress: () {
          //          this._addNewChat(context,chatPartnerID[controller.page.round()],chatPartnerName[controller.page.round()]);
        },
        child: isLoading
            ? new Material(
                color: bgColor,
                child: new Center(child: new CircularProgressIndicator()))
            : PageView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                children: list,
              ),

        /*
          FutureBuilder<QuerySnapshot>(
            future: Firestore.instance
                .collection("chats")
                .where("membersID", arrayContains: currentId)
                .getDocuments(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return new Text('${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Material(
                      color: bgColor,
                      child:
                          new Center(child: new CircularProgressIndicator()));
                default:
                  {
                    if (snapshot.hasData) {
                      print(snapshot.data.documents[0]['membersID'][0]);
                      return PageView(
                        controller: controller,
                        scrollDirection: Axis.vertical,
                        children: _buildPageView(snapshot.data.documents),
                      );
                    } else {
                      return new Material(
                          color: bgColor,
                          child: new Center(
                            child: new Text(
                              "No chat History",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 30.0),
                            ),
                          ));
                    }
                  }
              }
            },
          )
          */
      );
      /*
          child: new FutureBuilder(future: new QuerySnapshot(() async {
            var chathistory = await getChatHistory();
            return await chathistory;
          }), builder: (BuildContext context, AsyncSnapshot chatHistory) {
            //  data.documents.forEach((doc) => print(doc["aname"]));
            if (chatHistory.hasData) {
              QuerySnapshot shot=chatHistory;
              print(chatHistory)
            return Scaffold(
                resizeToAvoidBottomPadding: false, body: Text("hi"));
            }
            else
            {
              return new Center(
                            child: new CircularProgressIndicator(),);
            }
          }));
          */
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child:
              new Scaffold(body: new Builder(builder: (BuildContext context) {
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
                                  child: Text("Chat ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24.0,
                                      )),
                                )),
                            IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(FontAwesomeIcons.comment),
                            ),
                          ]),
                      background: _user.sayPic != null
                          ? new ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: new CachedNetworkImage(
                                imageUrl: _user.chatPic,
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
                    Container(
                        color: bgColor,
                        child: Column(children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 60.0),
                          ),
                          isLoading
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  color: bgColor,
                                  child: new Center(
                                      child: new CircularProgressIndicator()))
                              : ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(10.0),
                                  itemBuilder: (context, index) =>
                                      buildItem(index, list[index]),
                                  itemCount: list.length,
                                  //controller: listScrollController,
                                ),
                          /*PageView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: list),*/

                          isLoading
                              ? Container(
                                  padding: EdgeInsets.only(top: 40.0),
                                  child: _buildCloseButton())
                              : _buildCloseButton(),
                        ]))
                  ]))
                ]);
          })));
    }
  }

  Widget buildItem(int index, Widget document) {
    return document;
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
}

class longPress extends StatelessWidget {
  String _chatPartnerID;
  String _chatPartnerName;

  // const longPress({Key key}) : super(key: key);

  longPress(String chatPartnerID, String chatPartnerName) {
    _chatPartnerID = chatPartnerID;
    _chatPartnerName = chatPartnerName;
    print(_chatPartnerID);

    print(_chatPartnerName);
  }
  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.lightBlue,
        child: new ListView(children: <Widget>[
          InkWell(
              onTap: () {
                Map<String, dynamic> _action = {
                  "Action": "ReplyToChat",
                  "UserID": _chatPartnerID,
                  "UserName": _chatPartnerName
                };
                AppStateContainer.of(context).user.action = _action;
                Navigator.of(context).pushNamed('/say');
              },
              child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Row(children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 45.0, top: 20.0),
                      child: IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child: new Icon(FontAwesomeIcons.reply, size: 40.0),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Text(
                          "Reply",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
                        )),
                  ]))),
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Row(children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 45.0, top: 0.0),
                      child: IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child:
                            new Icon(FontAwesomeIcons.plusCircle, size: 40.0),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, top: 0.0),
                        child: Text(
                          "New Chat",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
                        )),
                  ]))),
          InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                  child: Row(children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 40.0, top: 0.0),
                  child: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(FontAwesomeIcons.backward, size: 40.0),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text(
                      "Menu",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18.0),
                    )),
              ]))),
        ]));
  }
}

class StatusOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  final Profile p;

  // In the constructor, require a Todo
  StatusOverlay(this.p);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new Center(
        child: Column(
          children: [
            Container(),
            Container(
                padding: EdgeInsets.only(top: 15.0),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(p.profile_pic),
                  radius: 60.0,
                )),
            Container(
              margin: EdgeInsets.only(top: 20.0),
            ),
            Container(
              child: Text("Status",
                  style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              child: Text(
                p.status,
                style: TextStyle(fontSize: 24.0, color: Colors.black),
                maxLines: 30,
              ),
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0),
                child: new IconButton(
                    icon: new IconTheme(
                      data: new IconThemeData(color: Colors.white),
                      child: new Icon(FontAwesomeIcons.timesCircle, size: 30.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }))
          ],
        ),
      )
    ]));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class Profile {
  final String profile_pic;
  final String status;

  Profile(this.profile_pic, this.status);
}

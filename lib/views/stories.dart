import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:image_picker/image_picker.dart';

enum ConfirmAction { Cancel, Confirm }

class StoriesScreen extends StatefulWidget {
  @override
  _StoriesScreenState createState() => new _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with TickerProviderStateMixin {
  User _user;

  String currentId;

  List<Widget> list = new List<Widget>();
  bool isLoading;
  bool refresh;
  Color bgColor;
  StreamSubscription<QuerySnapshot> streamSub;

  List<String> chatPartnerName = new List<String>();
  List<String> chatPartnerProfilePic = new List<String>();
  List<String> chatPartnerID = new List<String>();
  List<String> chatPartnerMFCM = new List<String>();
  List<String> chatPartnerWFCM = new List<String>();
  List<String> chatGrouprID = new List<String>();
  List<DateTime> lastUpdate = new List<DateTime>();
  List<String> message = new List<String>();
  List<String> senderID = new List<String>();
  List<String> groupChatIdList = new List<String>();
  List<String> docIDs = new List<String>();

  List<String> pic_url = new List<String>();
  List<String> audio_url = new List<String>();

  List<dynamic> likesID = new List<String>();

  List<String> likesCounter = List<String>();
  List<bool> likesByMe = new List<bool>();

  final controller = PageController(initialPage: 0);

  var st = new SplayTreeMap<int, dynamic>();

  Map<dynamic, dynamic> followeringTemp;

  List<String> followingList = new List<String>();

  String groupChatId;
  String docID;
  var data;

  String youtubeURL = "https://www.youtube.com/watch";
  String youtubeURL2 = "https://youtu.be/";

  AudioPlayer audioPlayer = new AudioPlayer();

  ScrollController _scrollController = new ScrollController();
  int noMessageCounter = 9999900;

  @override
  initState() {
    isLoading = true;
    refresh = true;
    super.initState();
  }

  scrollBottom() {
    _scrollController.animateTo(
      _scrollController.position.pixels + 150.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  void getGroupStories() async {
    QuerySnapshot data;
    groupChatId = 'ITClub';
    data = await Firestore.instance
        .collection('chats')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy("timestamp", descending: true)
        .limit(30)
        .getDocuments();

    if (data.documents.length > 0) {
      data.documents.forEach((dataUser) {
        String txtMsg = dataUser['message'];
        String pic_embed = dataUser['pic_embed'];
        String audio_embed = dataUser['audio_embed'];

        if (pic_embed != null) {
          pic_url.add(pic_embed);
        } else {
          pic_url.add("null");
        }
        if (audio_embed != null) {
          audio_url.add(audio_embed);
        } else {
          audio_url.add("null");
        }
        message.add(txtMsg);
        //message.add(dataUser['message']);
        lastUpdate.add(dataUser['timestamp'].toDate());
        likesID = dataUser['likeList'];
        docIDs.add(dataUser.documentID);
        if (likesID != null) {
          bool iLike = false;
          likesID.forEach((key) {
            if (key == _user.id) iLike = true;
          });
          if (iLike) {
            likesByMe.add(true);
          } else {
            likesByMe.add(false);
          }
        } else {
          likesByMe.add(false);
        }
        if (dataUser['likeCount'] != null) {
          likesCounter.add(dataUser['likeCount'].toString());
        } else {
          likesCounter.add("0");
        }

        chatPartnerID.add(dataUser['idFrom']);
        groupChatIdList.add(groupChatId);
      });
    }
  }

  ///watch only
  ///
  ///
  ///
  ///
  void getStories() async {
    int count = 10;

    int currentKey = st.lastKey();
    print(
        "$currentKey: ${st[currentKey][0]} and ${st[currentKey][1]} and ${st[currentKey][2]}");

    groupChatId = st[currentKey][1];
    docID = currentKey.toString();
    if (!docID.startsWith("99999")) {
      print("group chat id $groupChatId");
      print(docID);

      await Firestore.instance
          .collection('chats')
          .document(groupChatId)
          .collection(groupChatId)
          .document(docID)
          .get()
          .then((dataUser) {
        String txtMsg = dataUser['message'];
        String pic_embed = dataUser['pic_embed'];
        String audio_embed = dataUser['audio_embed'];

        if (pic_embed != null) {
          pic_url.add(pic_embed);
        } else {
          pic_url.add("null");
        }
        if (audio_embed != null) {
          audio_url.add(audio_embed);
        } else {
          audio_url.add("null");
        }
        message.add(txtMsg);
        //message.add(dataUser['message']);
        lastUpdate.add(dataUser['timestamp'].toDate());
        likesID = dataUser['likeList'];
        docIDs.add(docID);
        if (likesID != null) {
          bool iLike = false;
          likesID.forEach((key) {
            if (key == _user.id) iLike = true;
          });
          if (iLike) {
            likesByMe.add(true);
          } else {
            likesByMe.add(false);
          }
        } else {
          likesByMe.add(false);
        }
        if (dataUser['likeCount'] != null) {
          likesCounter.add(dataUser['likeCount'].toString());
        } else {
          likesCounter.add("0");
        }
      }).catchError((onError) {
        exit(0);
        print(onError.toString());
      });
    } else {
      message.add("No messages");
      pic_url.add("null");
      audio_url.add("null");
      lastUpdate.add(DateTime.now());
      likesCounter.add('0');
      likesByMe.add(false);
      docIDs.add(docID);
    }
    chatPartnerID.add(st[currentKey][0]);
    groupChatIdList.add(groupChatId);

    while (st.lastKeyBefore(currentKey) != null && count != 0) {
      currentKey = st.lastKeyBefore(currentKey);
      print("$currentKey: ${st[currentKey][0]} and ${st[currentKey][1]}");
      count--;

      groupChatId = st[currentKey][1];
      docID = currentKey.toString();
      if (!docID.startsWith("99999")) {
        await Firestore.instance
            .collection('chats')
            .document(groupChatId)
            .collection(groupChatId)
            .document(docID)
            .get()
            .then((dataUser) {
          String txtMsg = dataUser['message'];

          String pic_embed = dataUser['pic_embed'];
          String audio_embed = dataUser['audio_embed'];

          if (pic_embed != null) {
            pic_url.add(pic_embed);
          } else {
            pic_url.add("null");
          }
          if (audio_embed != null) {
            audio_url.add(audio_embed);
          } else {
            audio_url.add("null");
          }
          message.add(txtMsg);
          // message.add(dataUser['message']);
          lastUpdate.add(dataUser['timestamp'].toDate());
          likesID = dataUser['likeList'];
          docIDs.add(docID);
          if (likesID != null) {
            bool iLike = false;
            likesID.forEach((key) {
              if (key == _user.id) iLike = true;
            });
            if (iLike) {
              likesByMe.add(true);
            } else {
              likesByMe.add(false);
            }
          } else {
            likesByMe.add(false);
          }
          if (dataUser['likeCount'] != null) {
            likesCounter.add(dataUser['likeCount'].toString());
          } else {
            likesCounter.add("0");
          }
        }).catchError((onError) {
          exit(0);
          print(onError.toString());
        });
      } else {
        message.add("No messages");
        pic_url.add("null");
        audio_url.add("null");
        lastUpdate.add(DateTime.now());
        likesCounter.add('0');
        likesByMe.add(false);
        docIDs.add(docID);
      }
      chatPartnerID.add(st[currentKey][0]);
      groupChatIdList.add(groupChatId);
    }
  }

  void getChatHistory() async {
    await getGroupStories();
    await getUserGroupDetails();
    buildUI();
    setState(() {
      isLoading = false;
      refresh = false;

      var _duration = new Duration(seconds: 1);
      new Timer(_duration, scrollBottom);
    });
    /*
    // Get posting by following users.
    await Firestore.instance
        .collection('users')
        .document(_user.id)
        .get()
        .then((dataUser) {
      AppStateContainer.of(context).user.followering = dataUser["following"];
      followeringTemp = dataUser["following"];
    }).catchError((onError) {
      exit(0);
      print(onError.toString());
    });

    followeringTemp.forEach((key, value) {
      List<String> details = new List<String>();
      details.add(key);
      details.add(value[0]);
      if (value[1] == "null") {
        details.add(noMessageCounter.toString());

        st[noMessageCounter] = details;
        noMessageCounter++;
      } else {
        details.add(value[1]);

        st[int.parse(value[1])] = details;
      }
    });

    if (st.lastKey() != null) {
      await getStories();
      await getUserDetails();

//key is order by time
//0 is time (doc id)
//1 is user doc id
//2 is chat id
/*
    for (var key in st.keys) {
      print("$key: ${st[key][0]} and ${st[key][1]}");
    }
*/

      buildUI();
      setState(() {
        isLoading = false;
        refresh = false;

        var _duration = new Duration(seconds: 1);
        new Timer(_duration, scrollBottom);
      });
      return;
    } else {
      list.add(new Material(
          color: bgColor,
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: new Center(
                child: new Text(
                  "No stories",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30.0),
                ),
              ))));
      setState(() {
        isLoading = false;
        refresh = false;

        var _duration = new Duration(seconds: 1);
        new Timer(_duration, scrollBottom);
      });
      return;
    }
    */
  }

  play(String audio_url) async {
    AudioProvider audioProvider = new AudioProvider(audio_url);
    String localUrl = await audioProvider.load();
    audioPlayer.play(localUrl, isLocal: true);
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
        'stories_pic': photoUrl,
      }).catchError((e) {
        exit(0);
        print(e);
      });
      AppStateContainer.of(context).user.storiesPic = photoUrl;
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

  void buildUI() {
    for (int i = 0; i < chatPartnerID.length; i++) {
      String txtMsg;

      txtMsg = message[i];
      print("length - $chatPartnerID.length");

      print(likesByMe[i]);
      var formatter = new DateFormat('HH:mm:ss dd-MM-yy');
      String timestamp = formatter.format(lastUpdate[i]);

      print(txtMsg);
      txtMsg.toLowerCase().contains(youtubeURL) ? print(txtMsg) : print("no");

      if (AppStateContainer.of(context).device == Device.watch) {
        list.add(new PageView(
            scrollDirection: Axis.vertical,
            reverse: true,
            children: <Widget>[
              Material(
                  color: bgColor,
                  child: Column(children: <Widget>[
                    Container(
                      height: 20.0,
                      child: Text(""),
                    ),
                    Container(
                        height: 180.0,
                        /*child: InkWell(
                            onTap: () {
                              Map<String, dynamic> _action = {
                                "Action": "ChatHistory",
                                "groupID": chatGrouprID[i],
                                "chatPartnerName": chatPartnerName[i],
                                "chatPartnerID": chatPartnerID[i],
                                "chatPartnerMFCM": chatPartnerMFCM[i],
                                "chatPartnerWFCM": chatPartnerWFCM[i],
                              };
                              AppStateContainer.of(context).user.action = _action;
      
                              Navigator.of(context).pushNamed('/chatHistory');
                            },
                           */
                        child: SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 200.0,
                                ),
                                child: new Center(
                                    child: new Column(children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
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
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        groupChatIdList[i],
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12.0),
                                      )),
                                  pic_url[i] == "null"
                                      ? Container()
                                      : Container(
                                          child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: pic_url[i]),
                                        ),
                                  audio_url[i] == "null"
                                      ? Container()
                                      : Container(
                                          child: IconButton(
                                            icon: new IconTheme(
                                              data: new IconThemeData(
                                                  color: Colors.white),
                                              child: new Icon(
                                                  FontAwesomeIcons.play,
                                                  size: 20.0),
                                            ),
                                            onPressed: () {
                                              play(audio_url[i]);
                                            },
                                          ),
                                        ),
                                  txtMsg.toLowerCase().contains(youtubeURL) ||
                                          txtMsg
                                              .toLowerCase()
                                              .contains(youtubeURL2)
                                      ? new GestureDetector(
                                          onTap: () {
                                            playVideo(txtMsg);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 15.0,
                                                  right: 15.0,
                                                  top: 15.0),
                                              child: Text(
                                                txtMsg,
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12.0),
                                              )))
                                      : Container(
                                          padding: EdgeInsets.only(
                                              left: 15.0,
                                              right: 15.0,
                                              top: 15.0),
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
                                  docIDs[i].startsWith("99999")
                                      ? Text("")
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                              likesByMe[i]
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5.0),
                                                      child: new IconButton(
                                                          icon: new IconTheme(
                                                            data: new IconThemeData(
                                                                color: Colors
                                                                    .orange),
                                                            child: new Icon(
                                                                FontAwesomeIcons
                                                                    .thumbsUp,
                                                                size: 20.0),
                                                          ),
                                                          onPressed: () {}))
                                                  : Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5.0),
                                                      child: new IconButton(
                                                          icon: new IconTheme(
                                                            data:
                                                                new IconThemeData(
                                                                    color: Colors
                                                                        .white),
                                                            child: new Icon(
                                                                FontAwesomeIcons
                                                                    .thumbsUp,
                                                                size: 20.0),
                                                          ),
                                                          onPressed: () {
                                                            likeThisStory(
                                                                docIDs[i],
                                                                groupChatIdList[
                                                                    i],
                                                                i);
                                                          })),
                                              Text(
                                                likesCounter[i],
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12.0),
                                              )
                                            ]),
                                  Container(
                                      padding: EdgeInsets.only(top: 5.0),
                                      height: 60.0,
                                      child: Text(" "))
                                ])))))
                  ])),
              _buildOptionPage(chatPartnerID[i], chatPartnerName[i],
                  groupChatIdList[i], chatPartnerMFCM[i], chatPartnerWFCM[i])
            ]));
      } else {
        print("loading");
        list.add(Material(
            color: bgColor,
            child: Container(
                /*child: InkWell(
                            onTap: () {
                              Map<String, dynamic> _action = {
                                "Action": "ChatHistory",
                                "groupID": chatGrouprID[i],
                                "chatPartnerName": chatPartnerName[i],
                                "chatPartnerID": chatPartnerID[i],
                                "chatPartnerMFCM": chatPartnerMFCM[i],
                                "chatPartnerWFCM": chatPartnerWFCM[i],
                              };
                              AppStateContainer.of(context).user.action = _action;
      
                              Navigator.of(context).pushNamed('/chatHistory');
                            },
                           */
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 200.0,
                        ),
                        child: new Column(children: <Widget>[
                          Container(
                              height: MediaQuery.of(context).size.height / 5,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      padding:
                                          EdgeInsets.only(top: 10.0, left: 5.0),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                chatPartnerProfilePic[i]),
                                        radius: 60.0,
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Column(children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.only(top: 10.0),
                                            child: Text(
                                              chatPartnerName[i],
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 26.0),
                                            )),
                                        Container(
                                            margin: EdgeInsets.only(top: 10.0),
                                            child: Text(
                                              "Grp: " + groupChatIdList[i],
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 22.0),
                                            )),
                                        docIDs[i].startsWith("99999")
                                            ? Text("")
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                    likesByMe[i]
                                                        ? Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5.0),
                                                            child:
                                                                new IconButton(
                                                                    icon:
                                                                        new IconTheme(
                                                                      data: new IconThemeData(
                                                                          color:
                                                                              Colors.orange),
                                                                      child: new Icon(
                                                                          FontAwesomeIcons
                                                                              .thumbsUp,
                                                                          size:
                                                                              45.0),
                                                                    ),
                                                                    onPressed:
                                                                        () {}))
                                                        : Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5.0),
                                                            child: new IconButton(
                                                                icon: new IconTheme(
                                                                  data: new IconThemeData(
                                                                      color: Colors
                                                                          .white),
                                                                  child: new Icon(
                                                                      FontAwesomeIcons
                                                                          .thumbsUp,
                                                                      size:
                                                                          35.0),
                                                                ),
                                                                onPressed: () {
                                                                  likeThisStory(
                                                                      docIDs[i],
                                                                      groupChatIdList[
                                                                          i],
                                                                      i);
                                                                })),
                                                    Text(
                                                      likesCounter[i],
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 20.0),
                                                    )
                                                  ])
                                      ]))
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                          ),
                          pic_url[i] == "null"
                              ? Container()
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: pic_url[i]),
                                ),
                          audio_url[i] == "null"
                              ? Container()
                              : Container(
                                  child: IconButton(
                                    icon: new IconTheme(
                                      data: new IconThemeData(
                                          color: Colors.white),
                                      child: new Icon(FontAwesomeIcons.play,
                                          size: 30.0),
                                    ),
                                    onPressed: () {
                                      play(audio_url[i]);
                                    },
                                  ),
                                ),
                          txtMsg.toLowerCase().contains(youtubeURL) ||
                                  txtMsg.toLowerCase().contains(youtubeURL2)
                              ? new GestureDetector(
                                  onTap: () {
                                    playVideo(txtMsg);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    child: Text(
                                      txtMsg,
                                      style: TextStyle(
                                          fontSize: 24.0, color: Colors.black),
                                      maxLines: 30,
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 8.0, 10.0, 8.0),
                                    margin: EdgeInsets.fromLTRB(
                                        10.0, 8.0, 10.0, 8.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: Text(
                                    txtMsg,
                                    style: TextStyle(
                                        fontSize: 24.0, color: Colors.black),
                                    maxLines: 30,
                                  ),
                                  padding:
                                      EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                  margin:
                                      EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                          Container(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text(
                                timestamp,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16.0),
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 5.0),
                              height: 40.0,
                              child: Text(" ")),
                          _buildOptionPage(
                              chatPartnerID[i],
                              chatPartnerName[i],
                              groupChatIdList[i],
                              chatPartnerMFCM[i],
                              chatPartnerWFCM[i]),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 5.0,
                            color: Colors.white,
                          )
                        ]))))));
      }
    }
    setState(() {
      refresh = false;

      var _duration = new Duration(seconds: 1);
      new Timer(_duration, scrollBottom);
    });
  }

  void likeThisStory(
      String docID, String groupChatIdList, int listCount) async {
    print("here");
    List<String> listing = new List<String>();
    listing.add(_user.id);
    int count;

    await Firestore.instance
        .collection('chats')
        .document(groupChatIdList)
        .collection(groupChatIdList)
        .document(docID)
        .get()
        .then((dataUser) {
      count = dataUser['likeCount'];
      count++;
    });
    await Firestore.instance
        .collection('chats')
        .document(groupChatIdList)
        .collection(groupChatIdList)
        .document(docID)
        .updateData({
      'likeList': FieldValue.arrayUnion(listing),
      'likeCount': count,
    }).catchError((e) {
      exit(0);
      print(e);
    });

    likesCounter[listCount] = count.toString();
    likesByMe[listCount] = true;

    setState(() {
      refresh = true;

      var _duration = new Duration(seconds: 2);
      new Timer(_duration, refreshTimer);
    });
  }

  void playVideo(String txt) {
    print(txt);
    List<String> keywords = txt.split(" ");
    String url;

    keywords.forEach((f) {
      print(f);
      if (f.toLowerCase().contains(youtubeURL) ||
          f.toLowerCase().contains(youtubeURL2)) {
        url = f;
      }
    });

    print(url);
    Map<String, dynamic> _action = {
      "Action": "PlayVideo",
      "YoutubeLink": url,
    };
    AppStateContainer.of(context).user.action = _action;

    Navigator.of(context).pushNamed('/video');
  }

  void getUserGroupDetails() async {
    for (int i = 0; i < chatPartnerID.length; i++) {
      bool fetchedUser = false;
      for (int y = 0; y < i; y++) {
        if (chatPartnerID[i] == chatPartnerID[y]) {
          chatPartnerName.add(chatPartnerName[y]);
          chatPartnerProfilePic.add(chatPartnerProfilePic[y]);
          chatPartnerMFCM.add(chatPartnerMFCM[y]);
          chatPartnerWFCM.add(chatPartnerWFCM[y]);
          y = i;
          fetchedUser = true;
          break;
        }
      }
      if (!fetchedUser) {
        await Firestore.instance
            .collection('users')
            .document(chatPartnerID[i])
            .get()
            .then((dataUser) {
          print("$i - ${dataUser["aname"]}");
          chatPartnerName.add(dataUser["aname"]);
          chatPartnerProfilePic.add(dataUser["profile_pic"]);
          chatPartnerMFCM.add(dataUser["fcmMToken"]);
          chatPartnerWFCM.add(dataUser["fcmWToken"]);
        }).catchError((onError) {
          exit(0);
          print(onError.toString());
        });
      }
    }
  }

  void getUserDetails() async {
    for (int i = 0; i < chatPartnerID.length; i++) {
      await Firestore.instance
          .collection('users')
          .document(chatPartnerID[i])
          .get()
          .then((dataUser) {
        print("$i - ${dataUser["aname"]}");
        chatPartnerName.add(dataUser["aname"]);
        chatPartnerProfilePic.add(dataUser["profile_pic"]);
        chatPartnerMFCM.add(dataUser["fcmMToken"]);
        chatPartnerWFCM.add(dataUser["fcmWToken"]);
      }).catchError((onError) {
        exit(0);
        print(onError.toString());
      });
    }
  }

  @override
  void dispose() {
    //  streamSub.cancel();
    super.dispose();
  }

  Widget _buildPage(String chatPartnerName, String chatPartnerProfilePic,
      String message, String lastUpdate, Color color) {
    FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance.collection('users').document(currentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        print("test");
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

  _addNewChat(
      BuildContext context, String chatPartnerID, String chatPartnerName) {
    print(controller);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => longPress(chatPartnerID, chatPartnerName)));
  }

  Widget _buildOptionPage(String chatPartnerID, String chatPartnerName,
      String chatGroupName, String chatPartnerMFCM, String chatPartnerWFCM) {
    if (AppStateContainer.of(context).device == Device.watch) {
      print(chatPartnerMFCM);
      print(chatPartnerWFCM);
      return Material(
          color: bgColor,
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
                            "Action": "ReplyToGroup",
                            "GroupName": chatGroupName,
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
                                "Reply ${chatGroupName}",
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
          margin: EdgeInsets.only(bottom: 50.0),
          width: MediaQuery.of(context).size.width - 100.0,
          child: Column(children: <Widget>[
            Container(
              child: new InkWell(
                onTap: () {
                  Map<String, dynamic> _action = {
                    "Action": "ReplyToGroup",
                    "GroupName": chatGroupName,
                  };
                  AppStateContainer.of(context).user.action = _action;
                  Navigator.of(context).pushNamed('/say');
                },
                child: new Container(
                    height: 50.0,
                    decoration: new BoxDecoration(
                      color: Color(0xFFc6704b),
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Reply ${chatGroupName}",
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
            Container(
              padding: EdgeInsets.only(top: 20.0),
              child: new InkWell(
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
                child: new Container(
                    height: 50.0,
                    decoration: new BoxDecoration(
                      color: Color(0xFFc6704b),
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

  void refreshTimer() {
    list.clear();
    buildUI();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    bgColor = Color(0xFF4bacc6);
    _user = AppStateContainer.of(context).user;
    currentId = AppStateContainer.of(context).user.id;

    if (isLoading && refresh) {
      print("build page");
      _buildPageView();
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
            : refresh
                ? new Material(
                    color: bgColor,
                    child: new Center(child: new CircularProgressIndicator()))
                : PageView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    children: list,
                  ),
      );
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
                                  child: Text("Recent Stories ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24.0,
                                      )),
                                )),
                            IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(FontAwesomeIcons.podcast),
                            ),
                          ]),
                      background: _user.sayPic != null
                          ? new ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: new CachedNetworkImage(
                                imageUrl: _user.storiesPic,
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
                              ? new Container(
                                  height: MediaQuery.of(context).size.height,
                                  color: bgColor,
                                  child: new Center(
                                      child: new CircularProgressIndicator()))
                              : refresh
                                  ? new Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      color: bgColor,
                                      child: new Center(
                                          child:
                                              new CircularProgressIndicator()))
                                  : Column(children: list),
                          /*PageView(
                                          controller: controller,
                                          scrollDirection: Axis.horizontal,
                                          children: list),*/

                          isLoading || refresh
                              ? Container()
                              : _buildCloseButton(),
                        ]))
                  ]))
                ]);
          })));
    }
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

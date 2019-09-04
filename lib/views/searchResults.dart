import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

const double _appBarHeight = 110.0;

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => new _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  User _user;

  List<userCard> ucList = new List<userCard>();
  Color bgColor = Color(0xFFee3338);

  String currentId;

  List<Widget> list = new List<Widget>();
  bool isLoading;
  bool firstStart = true;

  final controller = PageController(initialPage: 0);

  var data;
  String youtubeURL = "https://www.youtube.com/watch";
  String youtubeURL2 = "https://youtu.be/";

  ScrollController _scrollController= new ScrollController();
  AudioPlayer audioPlayer = new AudioPlayer();

  @override
  initState() {
    isLoading = true;
    firstStart = true;
    super.initState();
  }

scrollBottom()
{

_scrollController.animateTo(
           _scrollController.position.pixels+150.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
          );
}
  ///watch only
  ///
  ///
  ///
  ///

  Future<Null> searchChats(String id, String keyword) async {
    QuerySnapshot data;

    print(keyword);
    data = await Firestore.instance
        .collection("chats")
        .document(id)
        .collection(id)
        .where("keywords", arrayContains: keyword)
        .orderBy("timestamp", descending: true)
        .limit(5)
        .getDocuments();
    if (data.documents.length > 0) {
      data.documents.forEach((doc) {
        userCard uc = new userCard();
        uc.senderID = doc['idFrom'];
        uc.group = id;
        uc.docID = doc.documentID;
        String txtMsg = doc['message'];

        String pic_embed = doc['pic_embed'];
        String audio_embed = doc['audio_embed'];

        if (pic_embed != null) {
          uc.pic_url = pic_embed;
        } else {
          uc.pic_url = "null";
        }
        if (audio_embed != null) {
          uc.audio_url = audio_embed;
        } else {
          uc.audio_url = "null";
        }
        uc.message = txtMsg;

        print(uc.message);
        print(uc.message.toLowerCase().contains(youtubeURL));
        print(uc.message.toLowerCase().contains(youtubeURL2));
                         

        uc.lastupdate = doc['timestamp'];
        List<dynamic> likesID = new List<String>();
        likesID = doc['likeList'];
        if (likesID != null) {
          bool iLike = false;
          likesID.forEach((key) {
            if (key == _user.id) iLike = true;
          });
          if (iLike) {
            uc.likesByMe = true;
          } else {
            uc.likesByMe = false;
          }
        } else {
          uc.likesByMe = false;
        }
        if (doc['likeCount'] != null) {
          uc.likesCounter = (doc['likeCount'].toString());
        } else {
          uc.likesCounter = "0";
        }
        ucList.add(uc);
      });
    }
  }

  play(String audio_url) async {
    AudioProvider audioProvider = new AudioProvider(audio_url);
    String localUrl = await audioProvider.load();
    audioPlayer.play(localUrl, isLocal: true);
  }

  void getChatHistory() async {
    QuerySnapshot data;
    String keyword = _user.action["SearchTxt"];
    List<String> docIDList = new List<String>();

    data = await Firestore.instance
        .collection("chats")
        .where("searchable", isEqualTo: true)
        .getDocuments();

    data.documents.forEach((doc) {
      docIDList.add(doc.documentID);
    });

    print(data.documents.length);
    for (int i = 0; i < docIDList.length; i++) {
      await searchChats(docIDList[i], keyword);
    }

    print("get user details");
    await getUserDetails();

    print("get user details - done");
    for (int i = 0; i < ucList.length; i++) {
      var formatter = new DateFormat('HH:mm:ss dd-MM-yy');
      String timestamp = formatter.format(ucList[i].lastupdate);

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
                                                 ucList[i].profile_pic),
                                        radius: 40.0,
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                         ucList[i].aname,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12.0),
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        ucList[i].group,
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12.0),
                                      )),
                                      
                          ucList[i].pic_url== "null"
                              ? Container()
                              : Container(
                                  child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image:  ucList[i].pic_url),
                                ),
                         ucList[i].audio_url == "null"
                              ? Container()
                              : Container(
                                  child: IconButton(
                                    icon: new IconTheme(
                                      data: new IconThemeData(
                                          color: Colors.white),
                                      child: new Icon(FontAwesomeIcons.play,
                                          size: 20.0),
                                    ),
                                    onPressed: () {
                                      play(ucList[i].audio_url);
                                    },
                                  ),
                                ),
                                  ucList[i].message.toLowerCase().contains(youtubeURL) || ucList[i].message.toLowerCase().contains(youtubeURL2)
                                      ? new GestureDetector(
                                          onTap: () {
                                            playVideo(ucList[i].message);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 15.0,
                                                  right: 15.0,
                                                  top: 15.0),
                                              child: Text(
                                                ucList[i].message,
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
                                            ucList[i].message,
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
                                Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                              ucList[i].likesByMe
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
                                                                ucList[i].docID,
                                                                ucList[i].group,
                                                                i);
                                                          })),
                                              Text(
                                                ucList[i].likesCounter,
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
             _buildOptionPage(
                              ucList[i].senderID,
                              ucList[i].aname,
                              ucList[i].fcmMToken,
                              ucList[i].fcmWToken,
                              ucList[i].group)
            ]));
      } else {
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
                                      padding:
                                          EdgeInsets.only(top: 10.0, left: 5.0),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                ucList[i].profile_pic),
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
                                              ucList[i].aname,
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 26.0),
                                            )),
                                        Container(
                                            margin: EdgeInsets.only(top: 10.0),
                                            child: Text(
                                              "Grp: " + ucList[i].group,
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 22.0),
                                            )),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              ucList[i].likesByMe
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5.0),
                                                      child: new IconButton(
                                                          icon: new IconTheme(
                                                            data:
                                                                new IconThemeData(
                                                                    color: Colors
                                                                        .orange),
                                                            child: new Icon(
                                                                FontAwesomeIcons
                                                                    .thumbsUp,
                                                                size: 45.0),
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
                                                                size: 35.0),
                                                          ),
                                                          onPressed: () {
                                                            likeThisStory(
                                                                ucList[i].docID,
                                                                ucList[i].group,
                                                                i);
                                                          })),
                                              Text(
                                                ucList[i].likesCounter,
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                          ucList[i].pic_url == "null"
                              ? Container()
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: ucList[i].pic_url),
                                ),
                          ucList[i].audio_url == "null"
                              ? Container()
                              : Container(
                                  child: IconButton(
                                    icon: new IconTheme(
                                      data: new IconThemeData(
                                          color: Colors.white),
                                      child: new Icon(FontAwesomeIcons.play,
                                          size: 30.0),
                                    ),
                                     onPressed: (){play(ucList[i].audio_url);},
                                     
                                  ),
                                ),
                          ucList[i].message.toLowerCase().contains(youtubeURL) || ucList[i].message.toLowerCase().contains(youtubeURL2) 
                              ? new GestureDetector(
                                  onTap: () {
                                    print("hello");
                                    playVideo(ucList[i].message);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height/3,
              child: Text(
                
                 ucList[i].message,
                style: TextStyle(fontSize: 24.0, color: Colors.black),maxLines: 30,
              ),
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
            ))
                              : Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height/3,
              child: Text(
                
                 ucList[i].message,
                style: TextStyle(fontSize: 24.0, color: Colors.black),maxLines: 30,
              ),
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
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
                              ucList[i].senderID,
                              ucList[i].aname,
                              ucList[i].fcmMToken,
                              ucList[i].fcmWToken,
                              ucList[i].group),
                                Container( margin:EdgeInsets.only(top:40.0), width: MediaQuery.of(context).size.width,
                                    height:5.0,
                                    color: Colors.white,)
                        ]))))));
      }
    }

    print("setstate");

    setState(() {
      isLoading = false;
      
      var _duration = new Duration(seconds: 1);
      new Timer(_duration, scrollBottom);
    });
    if (list.length == 0) {
      list.add(new Material(
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
                      child: new Icon(FontAwesomeIcons.searchMinus, size: 40.0),
                    ),
                    Text(
                      "No results\n Click to return",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ])))));
    }
    return;
  }

  void buildUI() {}
  void playVideo(String txt) {
    print(txt);
    List<String> keywords = txt.split(" ");
    String url;

    keywords.forEach((f) {
      print(f);
      if (f.toLowerCase().contains(youtubeURL) || f.toLowerCase().contains(youtubeURL2) ) {
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

    ucList[listCount].likesCounter = count.toString();
    ucList[listCount].likesByMe = true;
/*
    setState(() {
      refresh = true;

      var _duration = new Duration(seconds: 2);
      new Timer(_duration, refreshTimer);
    });
    */
  }

  void refreshTimer() {
    list.clear();
    buildUI();
  }

  void getUserDetails() async {
    print("get user details - start");
    bool copy = false;
    for (int i = 0; i < ucList.length; i++) {
      for (int y = 0; y < i; y++) {
        if (ucList[i].senderID == ucList[y].senderID) {
          ucList[i].aname = ucList[y].aname;
          ucList[i].profile_pic = ucList[y].profile_pic;
          ucList[i].fcmMToken = ucList[y].fcmMToken;
          ucList[i].fcmWToken = ucList[y].fcmWToken;
          y = i;
          copy = true;
        }
      }
      if (!copy) {
        print("fetching user data!");
        await Firestore.instance
            .collection('users')
            .document(ucList[i].senderID)
            .get()
            .then((dataUser) {
          ucList[i].aname = dataUser["aname"];
          ucList[i].profile_pic = dataUser["profile_pic"];
          ucList[i].fcmMToken = dataUser["fcmMToken"];
          ucList[i].fcmWToken = dataUser["fcmWToken"];
        }).catchError((onError) {
          
                        exit(0);
          print(onError.toString());
        });
      }
    }

    print("get user details - end");
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildPageView() {
    getChatHistory();
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

  Widget _buildOptionPage(String chatPartnerID, String chatPartnerName,
      String chatPartnerMFCM, String chatPartnerWFCM, String groupID) {
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
                            "Action": "ReplyToGroup",
                            "UserID": groupID,
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
                                "Reply ${groupID}",
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
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
            Container(
              child: new InkWell(
                onTap: () {
                  Map<String, dynamic> _action = {
                    "Action": "ReplyToGroup",
                    "GroupName": groupID,
                  };
                  AppStateContainer.of(context).user.action = _action;
                  Navigator.of(context).pushNamed('/say');
                },
                child: new Container(
                    height: 50.0,
                    decoration: new BoxDecoration(
                      color: Colors.orange,
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Reply ${groupID}",
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
                      color: Colors.orange,
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

    print("here");
    _user = AppStateContainer.of(context).user;
    currentId = AppStateContainer.of(context).user.id;

    print("firstStart - $firstStart");
    if (firstStart) {
      if (_user.action == null ||
          !_user.action.containsKey("Action") ||
          _user.action["Action"] != "Search") {
        Navigator.of(context).pop();
      }
      if (_user.action["SearchTxt"] == "") {
        Navigator.of(context).pop();
      }
    }
    firstStart = false;

    if (isLoading) {
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
                                child: Text("Find Interest ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 24.0,
                                    )),
                              ),
                              IconTheme(
                                data: new IconThemeData(color: Colors.white),
                                child: new Icon(Icons.search),
                              ),
                            ]),

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
      [  Container(
                    color: bgColor,
                    child: Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 60.0),
                      ),
                     isLoading
                            ? new Container(
                              height:  MediaQuery.of(context).size.height,
                                color: bgColor,
                                child: new Center(
                                    child: new CircularProgressIndicator()))
                            : Column(children:list),
                      
                      isLoading
                          ? Container(
                              padding: EdgeInsets.only(top: 40.0),
                              child: _buildCloseButton())
                          : _buildCloseButton(),
                    ]))]))]);
                    
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

class userCard {
  String aname;
  String profile_pic;
  String fcmMToken;
  String fcmWToken;
  DateTime lastupdate;
  String message;
  String senderID;
  String group;

  bool likesByMe;
  String likesCounter;
  String docID;
  String pic_url;
  String audio_url;
}

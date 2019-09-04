import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:interest_me_mobile_app/data/string_helper.dart';
//import 'package:flutter_youtube_extractor/flutter_youtube_extractor.dart';


class dbscriptScreen extends StatefulWidget {
  @override
  _dbscriptScreenState createState() => new _dbscriptScreenState();
}

class _dbscriptScreenState extends State<dbscriptScreen> {
  List<userCard> ucList = new List<userCard>();

 bool _isPlaying = false;
   String _youtubeMediaLink = 'Unknown';
  bool isLandScape = false;


  static const MethodChannel platform =
      const MethodChannel('edu.jcu.mySocialApp/recognizer');

  _dbscriptScreenState() {
    platform.setMethodCallHandler(_handleMethod);
  }
/*
Future<void> initPlatformState() async {
    try {
      FlutterYoutubeExtractor.getYoutubeMediaLink(
          youtubeLink: 'https://www.youtube.com/embed/f-BzUepNeZw',
          onReceive: (link) {
            if (!mounted) return;

            setState(() {
              _youtubeMediaLink = link;
              print(_youtubeMediaLink);
            });
          });
    } on PlatformException {
      _youtubeMediaLink = 'Failed to get Youtube Media link.';
    }
  }
*/
void initState() {
    super.initState();
    //initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

//checkDB();

//var keywords = "I want to test this message. Minecraft and also keywords".split(" ");
/*
    List<dynamic> keywordsFilter= new List<dynamic>();
var regExp = new RegExp(r"([.!?\\-])",caseSensitive: false,multiLine: false);
var str = "I want to test this message. Minecraft, and also keywords";


List<String> keywords;
String b=str.replaceAll(new RegExp(r'([.,!?\\-])'), '');
keywords=b.split(" ");

print(keywords.length);
   keywords.forEach((f) {
     print(f);
     String a=f.toString();
      if (!StringHelper.prnouns.contains(a) && !StringHelper.verbs.contains(a) && a!="")
        keywordsFilter.add(a);
    });

keywordsFilter.forEach((f) {
  print("keyword - $f");
});
*/
    //  testF();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("test"),
      ),
      body: new Center(
          child: Text("test")
                
        
        )
    );
  }

  Future<Null> _showNativeView() async {
    await platform.invokeMethod('showKeyboard', "default text by Randy");
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onKeyboard":
        debugPrint(call.arguments);
        return new Future.value("");
    }
  }

  void testF() async {
    print("test2");
    QuerySnapshot data;
    String keyword = "switch";
    List<String> docIDList = new List<String>();

    data = await Firestore.instance
        .collection("chats")
        .where("searchable", isEqualTo: true)
        .getDocuments();

    print(data.documents.length);
    data.documents.forEach((doc) {
      docIDList.add(doc.documentID);
    });

    for (int i = 0; i < docIDList.length; i++) {
      await testFF(docIDList[i], keyword);
    }

    print("test4");
    ucList.forEach((f) {
      print(f.group);
      print(f.message);
      print(f.senderID);
    });
  }

  Future<Null> testFF(String id, String keyword) async {
    QuerySnapshot data;

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
        uc.message = doc['message'];
        uc.lastupdate = doc['timestamp'].toString();
        ucList.add(uc);
      });
    }
  }

  void checkDB() async {
    String peerId = "-LQHQNYhTCQa8s9B5c9p";
    List<String> groupname = new List<String>();

    List<String> users = new List<String>();
    List<String> usersName = new List<String>();

    List<dynamic> details = new List<String>();

    groupname.add("IT Club");
    groupname.add("Switch");
    groupname.add("Minecraft");

    users.add("-LQHQNYhTCQa8s9B5c9p");
    users.add("-LQOJ7x0cJ67TikL_gxW");
    users.add("E2qtiINABfvNSBMWOPQn");

    var newContact = new Map<String, dynamic>();
    var following = new Map<String, dynamic>();
    var followingDetails = new Map<String, dynamic>();
    List<String> _myList = new List();

    /*   chat group           
    */
    details.add("IT Club");
    details.add("1541599859416");
    var data = await Firestore.instance.collection("users").getDocuments();
    data.documents.forEach((doc) {
      for (int i = 0; i < groupname.length; i++) {
        newContact[groupname[i]] = users;
      }

      for (int i = 0; i < users.length; i++) {
        followingDetails[users[i]] = details;
      }

      Firestore.instance
          .collection("users")
          .document(doc.documentID)
          .updateData({'following': followingDetails});

      /*     
      Firestore.instance
          .collection("users")
          .document(doc.documentID)
          .updateData({'followers': users});
    });
*/
/*
      Firestore.instance
          .collection("users")
          .document(doc.documentID)
          .updateData({'groups': newContact});
          */
    });

    print("done");
  }
}

class userCard {
  String aname;
  String description;
  String profile_pic;
  String fcmToken;
  String fcmWToken;
  String fcmMToken;
  String lastupdate;
  String message;
  String senderID;
  String group;
}

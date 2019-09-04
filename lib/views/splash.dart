import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login.dart';
import '../app_state_container.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'routes.dart';

class SplashScreen extends StatefulWidget {
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static bool status = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  static bool _connection = true;
  bool loginStatus = false;
  Timer timer;

  getSharedPreferenceUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
/*
    await prefs.setString('LoggedInUsername', "user3");
    await prefs.setString('LoggedInPassword', "123");

    //user 2
    await prefs.setString('LoggedInUsername', "user2");
    await prefs.setString('LoggedInPassword', "1234");
*/

    String username = prefs.getString("LoggedInUsername");
    String password = prefs.getString("LoggedInPassword");

    if (username == null) {
      loginStatus = false;
      status = false;

      var _duration = new Duration(seconds: 1);
      timer = new Timer(_duration, navigationPage);
    }

    loginStatus = true;

    var data = await Firestore.instance
        .collection('users')
        .where("username", isEqualTo: username)
        .where("password", isEqualTo: password)
        .getDocuments();

//Found user
    if (data.documents.length == 1) {
      FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
      firebaseMessaging.getToken().then((token) {
        AppStateContainer.of(context).user.fcmToken = token;
        if (AppStateContainer.of(context).device == Device.watch) {
          if (token != data.documents[0]["fcmWToken"]) {
            Firestore.instance
                .collection("users")
                .document(data.documents[0].documentID)
                .updateData({'fcmWToken': token}).catchError((e) {
              print(e);
            });
          }
        } else {
          if (token != data.documents[0]["fcmMToken"]) {
            Firestore.instance
                .collection("users")
                .document(data.documents[0].documentID)
                .updateData({'fcmMToken': token}).catchError((e) {
              print(e);
            });
          }
        }
      });

//set context data
      AppStateContainer.of(context).user.username =
          data.documents[0]["username"];
      AppStateContainer.of(context).user.avatarname =
          data.documents[0]["aname"];
      AppStateContainer.of(context).user.status =
          data.documents[0]["description"];
      AppStateContainer.of(context).user.profilePic =
          data.documents[0]["profile_pic"];
          
      AppStateContainer.of(context).user.chatPic =
          data.documents[0]["chat_pic"];
      AppStateContainer.of(context).user.sayPic =
          data.documents[0]["say_pic"];
      AppStateContainer.of(context).user.storiesPic =
          data.documents[0]["stories_pic"];
          
      AppStateContainer.of(context).user.findPic =
          data.documents[0]["find_pic"];
      AppStateContainer.of(context).user.followering =
          data.documents[0]["following"];
      AppStateContainer.of(context).user.followers =
          data.documents[0]["followers"];
      AppStateContainer.of(context).user.groups = data.documents[0]["groups"];

      /*
        AppStateContainer.of(context).user.followers.forEach((a) {
        print("followers - $a");
      });

      AppStateContainer.of(context).user.followering.forEach((key, value) {
        // print("following - $a");
      });

      Map<dynamic, dynamic> followeringTemp;
      followeringTemp = data.documents[0]["following"];
      var st = new SplayTreeMap<int, dynamic>();

      followeringTemp.forEach((key, value) {
        List<String> details = new List<String>();
        details.add(key);
        details.add(value[0]);
        details.add(value[1]);
        st[int.parse(value[1])] = details;
      });
      int count = 10;
      if (st.lastKey() != null) {
        int currentKey = st.lastKey();
        //  print("$currentKey: ${st[currentKey][0]} and ${st[currentKey][1]}");

        while (st.lastKeyBefore(currentKey) != null && count != 0) {
          currentKey = st.lastKeyBefore(currentKey);
          //   print("$currentKey: ${st[currentKey][0]} and ${st[currentKey][1]}");
          count--;
        }
      }

      AppStateContainer.of(context).user.groups.forEach((key, value) {
        //   print("group - $key");
        List<dynamic> temp = value;
        temp.forEach((f) {
          //            print("members - $f");
        });
      });

      */
      AppStateContainer.of(context).user.id = data.documents[0].documentID;
      status = true;
    } else {
      status = false;
    }

    var _duration = new Duration(seconds: 2);
    timer = new Timer(_duration, navigationPage);
  }

  void ExitApp() {
    exit(0);
  }

  void navigationPage() {
    
    if (_connectionStatus != 'Failed') {
      if (!status) {
        if (loginStatus) {
          Fluttertoast.showToast(msg: "Login failed");
        }
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/loginView', (Route<dynamic> route) => false);
        //   Navigator.of(context).popAndPushNamed('/loginView');
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/menu', (Route<dynamic> route) => false);
        //   Navigator.of(context).popAndPushNamed('/menu');
      }
    } else {
      Fluttertoast.showToast(msg: "Check conncection");
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/loginView', (Route<dynamic> route) => false);
    }
    
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferenceUser();
    initConnectivity();
  }

  Future<Null> initConnectivity() async {
    String connectionStatus;
    bool connection;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      connection = true;
    } on PlatformException catch (e) {
      print(e.toString());
      connection = false;
      connectionStatus = 'Failed';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connection = connection;
      _connectionStatus = connectionStatus;
    });
  }

  void tutorial() {
    if (timer != null) {
      timer.cancel();
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/tutorial', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_connection) {
      var _duration = new Duration(seconds: 2);
      new Timer(_duration, ExitApp);
    }
    if (AppStateContainer.of(context).device == Device.watch) {

      /*return Center(
                          child:Image(
                                image: new AssetImage('assets/say_w.gif'),width: MediaQuery.of(context).size.width/10*9 ,
                              ));
*/
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: ListView(children: <Widget>[
            Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 30.0, bottom: 10.0),
                child: Column(children: <Widget>[
                  Container(
                      child: Center(
                          child: Hero(
                              tag: 'logo',
                              child: Image(
                                image: new AssetImage('assets/logo_anim.gif'),width: MediaQuery.of(context).size.width / 4*3,
                              )))),
                                new GestureDetector(
                    onTap: () {
                      tutorial();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                       margin: EdgeInsets.only(top: 30.0),
                    child:IconTheme(
                              data: new IconThemeData(color: Colors.deepOrangeAccent),
                              child: new Icon(
                                Icons.live_help,
                                size: 35.0,
                              ),
                            )),
                  ),
                  Container(
                    
                      child: Text("Designed by AF, AH, MB and RZ\nNQASG IT Club",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold))),
                  _connection
                      ? Container()
                      : new Text("No network"),
                ]))
          ]));
      //   Stack(
      //  fit: StackFit.expand,

    } else {
      return new MaterialApp(
        theme: ThemeData(accentColor: Colors.blue),
        title: "InterestMe",
        home: new Scaffold(
            body: Column(children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height / 4 * 3,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Hero(
                      tag: 'logo',
                      child: Image(
                        image: new AssetImage('assets/logo_anim.gif'),
                        width: MediaQuery.of(context).size.width / 2,
                      )))),
          Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Column(
                children: <Widget>[
                  _connection
                      ? /*CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )
                        */
                      new Text("")
                      : new Text("No network"),
                  new GestureDetector(
                    onTap: () {
                      tutorial();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              'Tutorial',
                              style: new TextStyle(
                                  fontSize: 22.0, color: Colors.white),
                            ),
                            new IconTheme(
                              data: new IconThemeData(color: Colors.white),
                              child: new Icon(
                                Icons.live_help,
                                size: 30.0,
                              ),
                            ),
                          ]),
                          
                      margin: EdgeInsets.fromLTRB(70.0, 15.0, 70.0, 8.0),
                      decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
                  ),
                  Container(
                    
                      margin: EdgeInsets.only(top: 20.0),
                      child: Text("Designed by AF, AH, MB and RZ\nNQASG IT Club",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold)))
                ],
              )))
        ])),
      );
    }
  }
}

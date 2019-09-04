import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/user.dart';
import 'views/routes.dart';
import 'views/splash.dart';
import 'app_state_container.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:screen/screen.dart';
import 'package:html_unescape/html_unescape.dart';
import 'createNewUser.dart';
import 'views/testVideo.dart';

void main() => runApp(
      new MySocialApp(),
    );

class MySocialApp extends StatefulWidget {
  _MyApp createState() => new _MyApp();
}

class _MyApp extends State<MySocialApp> {
  // This widget is the root of your application.

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Screen.keepOn(true);
    /*
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        //   print("on launch");
        displayNotification(msg['notification']['body']);
        //print(msg['notification']['body']);
      },
      onResume: (Map<String, dynamic> msg) {
        //   print("on resume");
        displayNotification(msg['notification']['body']);
        //print(msg['notification']['body']);
      },
      onMessage: (Map<String, dynamic> msg) {
        displayNotification(msg['notification']['body']);
        //print(msg['notification']['body']);
      },
    );
    */
  }
/*

  void displayNotification(String urlText) async {
    Timer _timer;

    var unescape = new HtmlUnescape();
    var text = unescape.convert(urlText);

    text = Uri.decodeFull(text);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    Fluttertoast.showToast(msg: text);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1', 'Interest Me', 'Interest Me',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Interest Me', text, platformChannelSpecifics,
        payload: 'chat');

    _timer = new Timer(const Duration(seconds: 5), () {
      setState(() {
        //   final snackBar = SnackBar(content: Text('Speech: ${text}'));

        //   _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.pushNamed(context, '/chat');
  }
*/
/*
  void getChatHistory() async {
    
    String currentId="-LQHQNYhTCQa8s9B5c9p";


    var data = await Firestore.instance
        .collection("chats")
        .where("membersID", arrayContains: currentId)
       // .where("message", isEqualTo:  "finch")
       .orderBy("lastupdate")
        .limit(5)
        .getDocuments();

print(data.documents.length);
print(currentId);
 data.documents.forEach((doc) {
   print(doc.documentID);
 });
  }
  */
  @override
  Widget build(BuildContext context) {

    /*
    getChatHistory();

    return CircularProgressIndicator();
    */
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return new AppStateContainer(
        user: User(),
        //device: Device.watch,
        device: Device.mobile,
        child: MaterialApp(
            title: "InterestMe",
            routes: routesFinder.routes,
            home: new Scaffold(
              key: _scaffoldKey,
              //body: new LoginViewScreen(),
              body: new SplashScreen(),
              //body: new testVideoScreen(),
              //body: new dbscriptScreen(),
              //body:new createNewUser()
            
                          )
            ));
  }
}

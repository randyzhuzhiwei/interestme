import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user.dart';
import '../app_state_container.dart';
import '../models/speech_recognition.dart';
import 'splash.dart';
import 'routes.dart';

class LogoutViewScreen extends StatefulWidget {
  @override
  _LogoutViewScreenState createState() => new _LogoutViewScreenState();
}

class _LogoutViewScreenState extends State<LogoutViewScreen> {
  User _user;
  initState() {
    super.initState();
    _logout();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _user = AppStateContainer.of(context).user;

    if (AppStateContainer.of(context).device == Device.watch) {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: ListView(children: <Widget>[
            Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 60.0, bottom: 10.0),
                child: Column(children: <Widget>[
                  Container(child: Image.asset('assets/logo.png')),
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                ]))
          ]));
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
              body: Center(
                  child: new Form(
                      child: new Container(
                          color: Color(0xFFf79646),
                          child: ListView(children: <Widget>[
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 20.0),
                                  ),
                                ])
                          ]))))));
    }
  }

  void _logout() async {
    await getSharedPreferenceUser();
  }

  Future<Null> getSharedPreferenceUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('LoggedInUsername', "");
    await prefs.setString('LoggedInPassword', "");

    Navigator.pushNamed(context, '/loginView');
  }
 Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
}

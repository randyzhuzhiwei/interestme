import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'menu.dart';
import 'test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  _LoginScreenState createState() => new _LoginScreenState();
}

enum FormType { login, signup }

class _LoginScreenState extends State<LoginScreen> {
  final formkey = new GlobalKey<FormState>();

  StreamSubscription<QuerySnapshot> streamSub;
  var _isLoggedIn = false;

  FormType _formView;
  String _email;
  String _password;

  WaitingOverlay modalScreen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoggedIn = false;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(modalScreen = new WaitingOverlay());
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Exit Application?"), actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () => Navigator.pop(context, false),
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () => Navigator.pop(context, true),
              )
            ]));
  }

  _updateSharedPreferenceUser(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('LoggedInUser', username);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: ListView(
              //   Stack(
              //  fit: StackFit.expand,
              children: <Widget>[
               
                  Container(
              margin: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 80.0, bottom: 10.0),
                  child:RaisedButton(
                elevation: 10.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                color: new Color(0xFF4bacc6),
                onPressed: () {
             

         final screenSize = MediaQuery.of(context).size;
         //213.3
final screenHeight = screenSize.height; //213.3
final screenWidth = screenSize.width;
print(screenSize);
print(screenHeight);
print(screenWidth);
                 validateAndSubmit();
                },
                splashColor: Colors.blueGrey,
                child: new Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 40.0),
                ),
              ))
                 
              ]),
        );
  }

  Container _containerMenu() {
    return Container(
      margin: EdgeInsets.only(top: 60.0),
      child: new Column(
        children: <Widget>[
          ButtonTheme(
              minWidth: 250.0,
              height: 50.0,
              child: RaisedButton(
                elevation: 10.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                color: new Color(0xFF4bacc6),
                onPressed: () {
                  setState(() {
                    _isLoggedIn = true;
                    _formView = FormType.login;
                  });
                },
                splashColor: Colors.blueGrey,
                child: new Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 40.0),
                ),
              )),
          new Container(
            margin: EdgeInsets.only(top: 40.0),
          ),
          ButtonTheme(
              minWidth: 250.0,
              height: 50.0,
              child: RaisedButton(
                elevation: 10.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                color: new Color(0xFFf79646),
                onPressed: () {
                  setState(() {
                    _isLoggedIn = true;
                    _formView = FormType.signup;
                  });
                },
                splashColor: Colors.blueGrey,
                child: new Text(
                  'Sign up',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 40.0),
                ),
              ))
        ],
      ),
    );
  }

  Container _containerLogin() {
    return Container(
      child: new Form(
        key: formkey,
        child: new Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInputs() + buildSubmitButtons()),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      new Container(
          width: 300.0,
          child: new TextFormField(
            decoration: new InputDecoration(labelText: 'Email'),
            validator: (value) =>
                value.isEmpty ? 'Email cannot be empty' : null,
            onSaved: (value) => _email = value,
          )),
      new Container(
          width: 300.0,
          child: new TextFormField(
            decoration: new InputDecoration(labelText: 'Password'),
            validator: (value) =>
                value.isEmpty ? 'Password cannot be empty' : null,
            obscureText: true,
            onSaved: (value) => _password = value,
          )),
      Padding(padding: EdgeInsets.only(top: 40.0)),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formView == FormType.login) {
      return [
        ButtonTheme(
            minWidth: 250.0,
            height: 50.0,
            child: RaisedButton(
              elevation: 10.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0)),
              color: new Color(0xFF4bacc6),
              onPressed: validateAndSubmit,
              splashColor: Colors.blueGrey,
              child: new Text(
                'Login',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 40.0),
              ),
            )),
        Padding(padding: EdgeInsets.only(top: 40.0)),
        new IconButton(
          icon: new Icon(FontAwesomeIcons.timesCircle),
          tooltip: 'Close',
          onPressed: () {
            setState(() {
              _isLoggedIn = false;
            });
          },
        )
      ];
    } else {
      return [
        ButtonTheme(
            minWidth: 250.0,
            height: 50.0,
            child: RaisedButton(
              elevation: 10.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0)),
              color: new Color(0xFFf79646),
              onPressed: () {
                var newContact = new Map<String, dynamic>();
                newContact['username'] = "user3";
                newContact['profile_pic'] = "ran.jpg";
                newContact['aname'] = "Mr Good Guy.jpg";
                newContact['description'] = "Good status";
                newContact['password'] = "123";
                newContact['fcmToken'] = "123";
                Firestore.instance.collection("users").add(newContact);
                


              },
              splashColor: Colors.blueGrey,
              child: new Text(
                'Sign up',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 40.0),
              ),
            )),
        Padding(padding: EdgeInsets.only(top: 40.0)),
        new IconButton(
          icon: new Icon(FontAwesomeIcons.timesCircle),
          tooltip: 'Close',
          onPressed: () {
            setState(() {
              _isLoggedIn = false;
            });
          },
        )
      ];
    }
  }

// -- Delete - Used to test page
  //           Navigator.push(
  //            context,
  //           MaterialPageRoute(builder: (context) => TestPage()),
  //       );
  // -- Delete

  void validateAndSubmit() async {
    _email="user3";
    _password="123";
      try {
          streamSub = Firestore.instance
              .collection("users")
              .where("username", isEqualTo: _email)
              .where("password", isEqualTo: _password)
              .snapshots()
              .listen((data) {
            //  data.documents.forEach((doc) => print(doc["aname"]));

            if (data.documents.length == 1) {
              //StorageReference imageLink = storage.ref().child('giftShopItems').child(documentSnapshot['imageName']);

              FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

              firebaseMessaging.getToken().then((token) {
                print(token);

                AppStateContainer.of(context).user.fcmToken = token;
                Firestore.instance
                    .collection("users")
                    .document(data.documents[0].documentID)
                    .updateData({'fcmToken': token}).catchError((e) {
                  print(e);
                });
              });

              AppStateContainer.of(context).user.username =
                  data.documents[0]["username"];
              AppStateContainer.of(context).user.avatarname =
                  data.documents[0]["aname"];
              AppStateContainer.of(context).user.status =
                  data.documents[0]["description"];
              AppStateContainer.of(context).user.profilePic =
                  data.documents[0]["profile_pic"];
              AppStateContainer.of(context).user.fcmToken =
                  data.documents[0]["fcmToken"];
              AppStateContainer.of(context).user.id =
                  data.documents[0].documentID;
              _updateSharedPreferenceUser(_email);

              streamSub.cancel();
              Navigator.popAndPushNamed(context, '/menu');
              Fluttertoast.showToast(msg: "Login success");
            } else {
              streamSub.cancel();

              Fluttertoast.showToast(msg: "Login failed");
              //setstate for invalid login
              modalScreen.closeModal(context);
            }
          });

          /*
          var db = new DatabaseHelper();
          String username;
          List<Map<String, dynamic>> userQuery = await db.query(
              "SELECT username from User where username='$_email' and password ='$_password'");

          for (var usertable in userQuery) {
            username= usertable['username'];
          }
          if (userQuery.length >= 1) {
           // InheritedStateContainer
           //print(AppStateContainer.of(context).state.toString());
           
           
          }
            
          FirebaseUser user = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);
               modalScreen.closeModal(context);
          if (user != null) {
           
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          }
          */

      
        //  modalScreen.closeModal(context);
      } catch (e) {
        print('error: $e');

        modalScreen.closeModal(context);
      }
    
  }

  @override
  void dispose() {
    streamSub.cancel();
    super.dispose();
  }

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}

class WaitingOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

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

  BuildContext context;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          )
        ],
      ),
    );
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

  void closeModal(BuildContext context) {
    Navigator.pop(context);
  }
}

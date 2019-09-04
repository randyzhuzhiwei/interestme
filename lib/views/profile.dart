import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'menu.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../app_state_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firestore_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => new _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formkey = new GlobalKey<FormState>();
  var db = new FirestoreHelper();

  User _user;

  File _image;
  Color bgColor;

  ScrollController _scrollController= new ScrollController();
  Timer timer;
  
  final controller = PageController(initialPage: 1);

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
  initState() {
    super.initState();   var _duration = new Duration(seconds: 1);
      timer = new Timer(_duration, scrollBottom);
  }
scrollBottom()
{

_scrollController.animateTo(
           _scrollController.position.pixels+150.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
          );
}

  Future<String> _getSharedPreferenceUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('LoggedInUser');
  }

/*
  _getUser() async {
    var db = new DatabaseHelper();

    db.dropUser();
    db.CreateUsertabele();
    String username = await _getSharedPreferenceUser();

    List<Map<String, dynamic>> userQuery =
        await db.query("SELECT * from User where username='$username' ");

    for (var usertable in userQuery) {
      print(usertable['status']);
      _user = new User(usertable['username'], "", usertable['avatarname'],
          usertable['status']);
    }
  }
*/
  Widget _buildProfilePicture() {
    print(_user.profilePic);
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: Color(0xFF8a67ab),
          child: new Center(
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                CircleAvatar(
                  backgroundImage: _image == null
                      ? CachedNetworkImageProvider(_user.profilePic)
                      : FileImage(_image),
                  radius: 60.0,
                ),
              ])));
    } else {
      return new Container(
        padding: EdgeInsets.only(top: 30.0),
        child: CircleAvatar(
          backgroundImage: _image == null
              ? NetworkImage(_user.profilePic)
              : FileImage(_image),
          radius: 60.0,
          child: InkWell(
            onTap: () {
              chooseSource();
            },
            child: null,
          ),
        ),
      );
    }
  }

  Widget _buildProfileCard() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: Color(0xFF8a67ab),
          child: new Center(
              child: new Column(children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(3.0),
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
                  border: new Border.all(color: Colors.white24)),
              child: new Text(
                "Status",
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Text(
                _user.status,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
            )
          ])));
    } else {
      return new Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          height: 400.0,
          width: 400.0,
          child: Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  border: new Border.all(
                      color: Color(0xFF88ab67),
                      width: 5.0,
                      style: BorderStyle.solid),
                  borderRadius:
                      new BorderRadius.all(new Radius.circular(20.0))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new TextFormField(
                          initialValue: _user.avatarname,
                          decoration: new InputDecoration(
                            labelText: 'Avatar Name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          validator: (value) =>
                              value.isEmpty ? 'Avatar cannot be empty' : null,
                          onSaved: (value) => _user.avatarname = value,
                        )),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new TextFormField(
                          initialValue: _user.status,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          decoration: new InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                          ),
                          validator: (value) =>
                              value.isEmpty ? 'Status cannot be empty' : null,
                          onSaved: (value) => _user.status = value,
                        )),
                    /*           Container(
                        child: _image == null
            ? new Text('No image selected.')
            : new Image.file(_image),
      ),*/

                    ButtonTheme(
                        minWidth: 250.0,
                        height: 50.0,
                        child: RaisedButton(
                          elevation: 10.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          color: new Color(0xFF88ab67),
                          onPressed: validateAndUpdate,
                          splashColor: Colors.blueGrey,
                          child: new Text(
                            'Update',
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 40.0),
                          ),
                        )),
                    ButtonTheme(
                        minWidth: 250.0,
                        height: 50.0,
                        child: RaisedButton(
                          elevation: 10.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          color: new Color(0xFF88ab67),
                          onPressed: () {
                            Navigator.pushNamed(context, '/logoutView');
                          },
                          splashColor: Colors.blueGrey,
                          child: new Text(
                            'Log out',
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 40.0),
                          ),
                        ))
                  ])));
    }
  }

  Widget _buildPageView() {
    return PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _buildOptionPage(),
        _buildProfilePicture(),
        _buildProfileCard(),
        _buildCloseButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    bgColor = Color(0xFF8a67ab);
    //_getUser();
    var map = new Map<String, dynamic>();
    map['username'] = "ran";
    map['password'] = "123";
    map['avatarname'] = "Mr Lucky";
    map['status'] =
        "I am a person who is positive about every aspect of life. There are many things I like to do, to see, and to experience. I like to read, I like to write; I like to think, I like to dream; I like to talk, I like to listen. I like to see the sunrise in the morning, I like to see the moonlight at night; I like to feel the music flowing on my face, I like to smell the wind coming from the ocean. ";
    map['profilepic'] =
        "https://firebasestorage.googleapis.com/v0/b/interestme-b71ed.appspot.com/o/user2.jpg?alt=media&token=c06dce0d-f7df-4633-aebd-9b559c7e27ae";

    _user = new User.map(map);

    _user = AppStateContainer.of(context).user;

    print(_user.profilePic);

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
                                child: Text("My Profile ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 24.0,
                                    )),
                              ),
                              IconTheme(
                                data: new IconThemeData(color: Colors.white),
                                child: new Icon(Icons.portrait),
                              ),
                            ]),
                        background: new ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: new CachedNetworkImage(
                            imageUrl: _user.profilePic,
                            height: 96.0,
                            width: 96.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                       ),
                    ),
                SliverList(
    delegate: SliverChildListDelegate(
      [  new Form(
                    key: formkey,
                    child: Container(
                        color: bgColor,
                        child: Column(children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 60.0),
                          ),
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _buildProfilePicture(),
                                Container(
                                  padding: EdgeInsets.only(top: 20.0),
                                ),
                                _buildProfileCard(),
                                _buildCloseButton(),
                              ])
                        ])))]))]);
          })));
    }
  }

  Widget _buildCloseButton() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
          color: Color(0xFF8a67ab),
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
              margin: EdgeInsets.only(top: 1.0),
              child: new IconButton(
                  icon: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: new Icon(FontAwesomeIcons.timesCircle),
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  })));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndUpdate() async {
    if (validateAndSave()) {
      try {
        String fname=_user.username+ new DateTime.now().millisecondsSinceEpoch.toString() +'.jpg';
        await uploadFile(fname);

        Navigator.pop(context, true);
      } catch (e) {
        print('error: $e');
      }
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

  Future<bool> uploadFile(String name) async {
    String downloadUrl;
    String photoUrl;

      
    if (_image != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(name);

      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dl = await (await task.onComplete).ref.getDownloadURL();
      photoUrl = dl.toString();
      Firestore.instance.collection("users").document(_user.id).updateData({
        'profile_pic': photoUrl,
        'aname': _user.avatarname,
        'description': _user.status
      }).catchError((e) {
        
                        exit(0);
        print(e);
      });
      AppStateContainer.of(context).user.profilePic = photoUrl;
    } else {
      Firestore.instance.collection("users").document(_user.id).updateData({
        'aname': _user.avatarname,
        'description': _user.status
      }).catchError((e) {
        
                        exit(0);
        print(e);
      });
    }

    AppStateContainer.of(context).user.avatarname = _user.avatarname;
    AppStateContainer.of(context).user.status = _user.status;
    Fluttertoast.showToast(msg: "Profile Updated!");
  }
}

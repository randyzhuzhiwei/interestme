import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:interest_me_mobile_app/data/string_helper.dart';
//import 'package:flutter_youtube_extractor/flutter_youtube_extractor.dart';

class createNewUser extends StatefulWidget {
  @override
  _createNewUserState createState() => new _createNewUserState();
}

class _createNewUserState extends State<createNewUser> {
  void initState() {
    super.initState();
    addUser();
    //initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Create new user"),
        ),
        body: new Center(child: Text("test")));
  }

  void addUser() async {
    
    userCard user1 = new userCard();

    user1.aname = "user8";
    user1.description = "Cool";
    user1.fcmMToken = "";
    user1.fcmWToken = "";
    List<String> followers = new List<String>();
    followers.add(" ");
    user1.followers = followers;

    Map<String, dynamic> following = new Map<String, dynamic>();

    List<String> followingUser = new List<String>();


    user1.following = following;

    Map<String, dynamic> groups = new Map<String, dynamic>();

    List<String> groupUser = new List<String>();

    groupUser.add("abc");

    groups["ITClub"] = groupUser;

    user1.groups = groups;
    user1.password = user1.aname;
    user1.profile_pic = "https://firebasestorage.googleapis.com/v0/b/interestme-b71ed.appspot.com/o/teen-boy-character-avatar-vector-11360092.jpg?alt=media&token=e06c77c7-8326-4641-8eac-155f0dccb7fe";
    user1.username = user1.aname;

    var newUser = new Map<String, dynamic>();
    newUser['aname'] = user1.aname;
    newUser['description'] = user1.description;
    newUser['fcmWToken'] = user1.fcmWToken;
    newUser['fcmMToken'] = user1.fcmMToken;
    newUser['followers'] = user1.followers;
    newUser['following'] = user1.following;
    newUser['groups'] = user1.groups;
    newUser['password'] = user1.password;
    newUser['profile_pic'] = user1.profile_pic;
    newUser['username'] = user1.username;


    //Firestore.instance.collection("users").add(newUser);

List<String> totalgroup = new List<String>();
  totalgroup.add("-LW0fGtY0XyIP0fifQwd");
  totalgroup.add("-LW0fGtq9P8itSh8784_");
    totalgroup.add("-LW0fGtsjw3jl12PKTy6");
    totalgroup.add("-LW0fGtuOfB7849zYr7h");
    totalgroup.add("-LT7avWrUIloBJTG4hWG");
    totalgroup.add("-L_QnpA8E2bIPNf53Ean");
    totalgroup.add("-L_Qpf2peyNJbZShf2EC");
    totalgroup.add("-L_QprQqJMUX6ZfQIihT");
    totalgroup.add("-L_Qq6Jr_aRpjTg6rsAe");
    
    
 followers = new List<String>();
    followers.add("-LW0fGtY0XyIP0fifQwd");
    followers.add("-LW0fGtq9P8itSh8784_");
    followers.add("-LW0fGtsjw3jl12PKTy6");
    followers.add("-LW0fGtuOfB7849zYr7h");
    followers.add("-LT7avWrUIloBJTG4hWG");
    followers.add("-L_QnpA8E2bIPNf53Ean");
    followers.add("-L_Qpf2peyNJbZShf2EC");
    followers.add("-L_QprQqJMUX6ZfQIihT");
    followers.add("-L_Qq6Jr_aRpjTg6rsAe");


    following = new Map<String, dynamic>();

    followingUser = new List<String>();

    followingUser.add("ITClub");
    followingUser.add("1547355917133");

    following["-LW0fGtY0XyIP0fifQwd"] = followingUser;
    
    followingUser = new List<String>();

    followingUser.add("ITClub");
    followingUser.add("1547356837114");
    
    following["-LW0fGtq9P8itSh8784_"] = followingUser;
    
    followingUser = new List<String>();

    followingUser.add("ITClub");
    followingUser.add("1551850518825");
    following["-LW0fGtsjw3jl12PKTy6"] = followingUser;
    followingUser = new List<String>();

    followingUser.add("ITClub");
    followingUser.add("1550378746151");
    following["-LW0fGtuOfB7849zYr7h"] = followingUser;
    
    followingUser = new List<String>();

    followingUser.add("ITClub");
    followingUser.add("null");
    following["-LT7avWrUIloBJTG4hWG"] = followingUser;
    following["-L_QnpA8E2bIPNf53Ean"] = followingUser;
    following["-L_Qpf2peyNJbZShf2EC"] = followingUser;
    following["-L_QprQqJMUX6ZfQIihT"] = followingUser;
    following["-L_Qq6Jr_aRpjTg6rsAe"] = followingUser;


     groups = new Map<String, dynamic>();

     groupUser = new List<String>();

    groupUser.add("-LW0fGtY0XyIP0fifQwd");
    groupUser.add("-LW0fGtq9P8itSh8784_");
    groupUser.add("-LW0fGtsjw3jl12PKTy6");
    groupUser.add("-LW0fGtuOfB7849zYr7h");
    groupUser.add("-LT7avWrUIloBJTG4hWG");
    groupUser.add("-L_QnpA8E2bIPNf53Ean");
    groupUser.add("-L_Qpf2peyNJbZShf2EC");
    groupUser.add("-L_QprQqJMUX6ZfQIihT");
    groupUser.add("-L_Qq6Jr_aRpjTg6rsAe");

    groups["ITClub"] = groupUser;

/*
totalgroup.forEach((f) {

 Firestore.instance
          .collection("users")
          .document(f)
          .updateData({'followers':followers,'following':following,'groups': groups});
});
    
*/
/*
    Firestore.instance.collection("users").add(newUser);
    Firestore.instance.collection("users").add(newUser);
    Firestore.instance.collection("users").add(newUser);
    Firestore.instance.collection("users").add(newUser);

     Firestore.instance
          .collection("users")
          .document("-LT7avWrUIloBJTG4hWG")
          .updateData({'followers':followers,'following':following,'groups': groups});


    following = new Map<String, dynamic>();

    followingUser = new List<String>();

    followingUser.add("Family");
    followingUser.add("null");

   // following["-LT7Wd6HGvigbQaZmfZy"] = followingUser;
    following["-LT7XvwxoMO_xXWn6VH-"] = followingUser;
    following["-LT7ZD_KbLNIoUGlCmFx"] = followingUser;
    following["-LT7avWrUIloBJTG4hWG"] = followingUser;
 Firestore.instance
          .collection("users")
          .document("-LT7Wd6HGvigbQaZmfZy")
          .updateData({'following':following});
          
    following = new Map<String, dynamic>();

    followingUser = new List<String>();

    followingUser.add("Family");
    followingUser.add("null");

    following["-LT7Wd6HGvigbQaZmfZy"] = followingUser;
   // following["-LT7XvwxoMO_xXWn6VH-"] = followingUser;
    following["-LT7ZD_KbLNIoUGlCmFx"] = followingUser;
    following["-LT7avWrUIloBJTG4hWG"] = followingUser;
 Firestore.instance
          .collection("users")
          .document("-LT7XvwxoMO_xXWn6VH-")
          .updateData({'following':following});
          
    following = new Map<String, dynamic>();

    followingUser = new List<String>();

    followingUser.add("Family");
    followingUser.add("null");

    following["-LT7Wd6HGvigbQaZmfZy"] = followingUser;
    following["-LT7XvwxoMO_xXWn6VH-"] = followingUser;
   // following["-LT7ZD_KbLNIoUGlCmFx"] = followingUser;
    following["-LT7avWrUIloBJTG4hWG"] = followingUser;
 Firestore.instance
          .collection("users")
          .document("-LT7ZD_KbLNIoUGlCmFx")
          .updateData({'following':following});
          
    following = new Map<String, dynamic>();

    followingUser = new List<String>();

    followingUser.add("Family");
    followingUser.add("null");

    following["-LT7Wd6HGvigbQaZmfZy"] = followingUser;
    following["-LT7XvwxoMO_xXWn6VH-"] = followingUser;
    following["-LT7ZD_KbLNIoUGlCmFx"] = followingUser;
    //following["-LT7avWrUIloBJTG4hWG"] = followingUser;
 Firestore.instance
          .collection("users")
          .document("-LT7avWrUIloBJTG4hWG")
          .updateData({'following':following});
    Fluttertoast.showToast(msg: "User created");
  */
  }
}

class userCard {
  String aname;
  String description;
  String fcmToken;
  String fcmWToken;
  String fcmMToken;
  List<String> followers;
  Map<String, dynamic> following;
  Map<String, dynamic> groups;
  String password;
  String profile_pic;
  String username;
}

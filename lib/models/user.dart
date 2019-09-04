import 'dart:core';
class User{

  String _username;
  String _password;
  String _avatarname;
  String _status;
  String _profilePic;
  String _sayPic;
  String _storiesPic;
  String _findPic;
  String _chatPic;
  String _id;
  String _fcmToken;
  String _sendingID;
  Map<String, dynamic> _action;
  Map<dynamic, dynamic> _groups;
  List<dynamic> _followers;
   Map<dynamic, dynamic> _followering;
  

  User();

  User.map(dynamic obj){
    this._username=obj['username'];
    this._password=obj['password'];
    this._avatarname=obj['avatarname'];
    this._status=obj['status'];
    this._profilePic=obj['profilePic'];
    this._sayPic=obj['sayPic'];
    this._storiesPic=obj['storiesPic'];
    this._findPic=obj['findPic'];
    this._chatPic=obj['chatPic'];
    this._sendingID=obj['sendingID'];
    this._action=obj['action'];
    this._groups=obj['groups'];
    this._followers=obj['followers'];
    this._followering=obj['followering'];
    
  }

  String get username => _username;
  String get password => _password;
  String get avatarname => _avatarname;
  String get status => _status;
  String get profilePic => _profilePic;
  String get sayPic => _sayPic;
  String get storiesPic => _storiesPic;
  String get findPic => _findPic;
  String get chatPic => _chatPic;
  String get id => _id;
  String get fcmToken => _fcmToken;
  String get sendingID => _sendingID;
  Map<String, dynamic>  get action => _action;
  Map<dynamic, dynamic>  get groups => _groups;
  List<dynamic> get followers => _followers;
 Map<dynamic, dynamic> get followering => _followering;

  
  void set username(String name) {
    _username=name;
  }
  void set password(String password) {
    _password=password;
  }  void set avatarname(String avatarname) {
    _avatarname=avatarname;
  }  void set status(String status) {
    _status=status;
  }void set profilePic(String profilePic) {
    _profilePic=profilePic;
  }void set sayPic(String sayPic) {
    _sayPic=sayPic;
  }void set storiesPic(String storiesPic) {
    _storiesPic=storiesPic;
  }void set findPic(String findPic) {
    _findPic=findPic;
  }void set chatPic(String chatPic) {
    _chatPic=chatPic;
  }void set id(String id) {
    _id=id;
  }void set fcmToken(String fcmToken) {
    _fcmToken=fcmToken;
  }
  void set sendingID(String sendingID) {
    _sendingID=sendingID;
  }

  void set action( Map<String, dynamic>  action) {
    _action=action;
  }

  void set groups( Map<dynamic, dynamic>  groups) {
    _groups=groups;
  }
  
  void set followers(List<dynamic> followers) {
    _followers=followers;
  }
  
  void set followering( Map<dynamic, dynamic>  followering) {
    _followering=followering;
  }

  Map<String, dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['username']=_username;
    map['password']=password;
    map['avatarname']=avatarname;
    map['status']=status;
    map['profilePic']=profilePic;
    map['sayPic']=sayPic;
    map['storiesPic']=storiesPic;
    map['findPic']=findPic;
    map['chatPic']=chatPic;
    map['sendingID']=sendingID;
    map['action']=action;
    return map;
  }
}
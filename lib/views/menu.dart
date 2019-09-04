import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:interest_me_mobile_app/views/audio_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../app_state_container.dart';
import '../models/user.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'permission.dart';
import 'package:flutter/services.dart' show rootBundle;
/*
import 'say.dart';
import 'trends.dart';
import 'findInterest.dart';
import 'groups.dart';
import 'test.dart';
import 'routes.dart';
*/

double _appBarHeight;
int random = 3;

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => new _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  User _user;

  AnimationController _controller;
  Random rnd = new Random();
  Animation _animation;
  //String _platformVersion;
  //Permission permission;

  String clickPath;
  AudioPlayer audioPlayer = new AudioPlayer();

  final controller = PageController(initialPage: 1);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    // initplatform();
    checkPermission();
    var _duration = new Duration(seconds: 4);
    new Timer.periodic(_duration, (Timer t) {
      int no = rnd.nextInt(7);

      while (random == no) {
        no = rnd.nextInt(6);
      }
      random = no;
      setState(() {
        _controller.forward();
      });
    });
  }

  checkPermission() async {
    Permission.getPermissions();
/* 
 List<Permissions> permissions = await Permission.getPermissionsStatus([PermissionName.Camera, PermissionName.Microphone,PermissionName.Storage]);
    
     List<Permissions> permissionNames = await Permission.requestPermissions([PermissionName.Camera, PermissionName.Microphone,PermissionName.Storage]);
   if(permissions[0].permissionStatus==PermissionStatus.notAgain ||permissions[0].permissionStatus==PermissionStatus.notDecided  )
     {
        PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Camera);

     }
    if(permissions[1].permissionStatus==PermissionStatus.notAgain ||permissions[1].permissionStatus==PermissionStatus.notDecided  )
     {
        PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Microphone);

     }
    if(permissions[2].permissionStatus==PermissionStatus.notAgain ||permissions[2].permissionStatus==PermissionStatus.notDecided  )
     {
        PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Storage);

     }
     */

/*
  if(camPermission==PermissionStatus.notDecided)
  {
PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Camera);

  }
  PermissionStatus micPermission = await Permission.getSinglePermissionStatus(PermissionName.Microphone);
  if(micPermission==PermissionStatus.notDecided)
  {
PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Microphone);

  }
   PermissionStatus storagePermission = await Permission.getSinglePermissionStatus(PermissionName.Storage);
  if(storagePermission==PermissionStatus.notDecided)
  {
PermissionStatus permissionNames = await Permission.requestSinglePermission(PermissionName.Storage);

  }
*/
/*
  PermissionStatus camPermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
  if(camPermission==PermissionStatus.unknown)
  {
Map<PermissionGroup, PermissionStatus> camPermissions = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
  }

    PermissionStatus micPermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
  if(micPermission==PermissionStatus.unknown)
  {
Map<PermissionGroup, PermissionStatus> micPermissions = await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
  }
      PermissionStatus storagePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if(storagePermission==PermissionStatus.unknown)
  {
Map<PermissionGroup, PermissionStatus> storagePermissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }
  */
  }

/*
//its just for getting the platform version
  initplatform() async {
    String platfrom;
    try {
      platfrom = await SimplePermissions.platformVersion;
    } on Exception {
      platfrom = "platform not found";
    }
    if (!mounted) return;
//otherwise set the platform to our _platformversion global variable
setState(() => _platformVersion = platfrom);
    checkPermission();
  }

  checkPermission() async {
    permission = Permission.RecordAudio;
    bool res = await SimplePermissions.checkPermission(permission);
    print(res);
    if (!res) {
      requestPermission(permission);
    }
  permission = Permission.WriteExternalStorage;
    bool res2 = await SimplePermissions.checkPermission(permission);
    if (!res2) {
      requestPermission(permission);
    }
    print(res2);
  permission = Permission.Camera;
    bool res3 = await SimplePermissions.checkPermission(permission);
    if (!res3) {
      requestPermission(permission);
    }
    print(res3);
  }

  requestPermission(Permission permission) async {
    print(permission);
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }
*/
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  playClick() async {
    final file = new File('${(await getTemporaryDirectory()).path}/click.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());

    final result = await audioPlayer.play(file.path, isLocal: true);
    //String localUrl = await audioProvider.load();
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/click.mp3');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _user = AppStateContainer.of(context).user;

    _appBarHeight = MediaQuery.of(context).size.height / 6;

    if (AppStateContainer.of(context).device == Device.watch) {
      return new GestureDetector(
          onLongPress: () {
            //    this._longPressMenu(context);
          },
          child: new Scaffold(
              resizeToAvoidBottomPadding: false, body: _buildPageView())
          //   Stack(
          //  fit: StackFit.expand,
          );
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
              body: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 30.0, bottom: 10.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Container(
                          child: Hero(
                              tag: 'logo',
                              child: Image(
                                image: new AssetImage('assets/logo.png'),
                                width: MediaQuery.of(context).size.width / 2,
                              ))),
                      new CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(_user.profilePic),
                        radius: 50.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: null,
                        ),
                      ),
                    ]),
                height: _appBarHeight,
              ),
              Container(
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        playClick();
                        Navigator.pushNamed(context, '/say');
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: random != 0
                            ? new Text(
                                "I want to say",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              )
                            : FadeTransition(
                                opacity: _animation,
                                child: Image(
                                    image: new AssetImage('assets/say2.gif'))),
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFFf79646),
              ),
              Container(
                margin: EdgeInsets.only(top: 3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        playClick();
                        Navigator.pushNamed(context, '/stories');
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: random != 1
                            ? new Text(
                                "Recent stories",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              )
                            : FadeTransition(
                                opacity: _animation,
                                child: Image(
                                    image:
                                        new AssetImage('assets/stories.gif'))),
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF4bacc6),
              ),
              Container(
                margin: EdgeInsets.only(top: 3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        playClick();
                        Navigator.pushNamed(context, '/interest');
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: random != 2
                            ? new Text(
                                "Find Interest",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              )
                            : FadeTransition(
                                opacity: _animation,
                                child: Image(
                                    image: new AssetImage('assets/find.gif'))),
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFFee3338),
              ),
              Container(
                margin: EdgeInsets.only(top: 3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        playClick();
                        Navigator.pushNamed(context, '/chat');
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: random != 3
                            ? new Text(
                                "Chat",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              )
                            : FadeTransition(
                                opacity: _animation,
                                child: Image(
                                    image: new AssetImage('assets/chat.gif'))),
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF46b754),
              ),
              Container(
                margin: EdgeInsets.only(top: 3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        playClick();
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: random != 4
                            ? new Text(
                                "My Profile",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              )
                            : FadeTransition(
                                opacity: _animation,
                                child: Image(
                                    image:
                                        new AssetImage('assets/profile.gif'))),
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF8a67ab),
              ),
            ],
          )));
    }
  }

  ///watch only
  Widget _buildPage(
      {String menu,
      IconTheme icon,
      Image iconAmin,
      Color color,
      String route}) {
    return new Material(
        color: color,
        child: InkWell(
            onTap: () {
              AppStateContainer.of(context).user.action = null;
              Navigator.pushNamed(context, route);
            },
            child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 45.0, bottom: 10.0),
                child: iconAmin == null
                    ? Column(children: <Widget>[
                        Container(height: 80.0, child: icon),
                        Text(
                          menu,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                      ])
                    : Column(children: <Widget>[
                        Container(
                            height: 80.0,
                            child: random % 2 == 0
                                ? FadeTransition(
                                    opacity: _animation, child: iconAmin)
                                : icon),
                        Text(
                          menu,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                      ]))));
  }

  Widget _buildPageView() {
    return PageView(
        scrollDirection: Axis.vertical,
        controller: controller,
        children: [
          _buildOptionPage(),
          _buildPage(
              menu: "I want to say",
              color: Color(0xFFf79646),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  Icons.chat,
                  size: 80.0,
                ),
              ),
              iconAmin: Image(
                image: new AssetImage("assets/say2.gif"),
                width: 80.0,
              ),
              route: '/say'),
          _buildPage(
              menu: "Recent stories",
              color: Color(0xFF4bacc6),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  FontAwesomeIcons.podcast,
                  size: 80.0,
                ),
              ),
              iconAmin: Image(
                image: new AssetImage("assets/stories.gif"),
                width: 92.0,
              ),
              route: '/stories'),
          _buildPage(
              menu: "Find Interest",
              color: Color(0xFFee3338),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  Icons.search,
                  size: 80.0,
                ),
              ),
              iconAmin: Image(
                image: new AssetImage("assets/find.gif"),
                width: 80.0,
              ),
              route: '/interest'),
          _buildPage(
              menu: "Chat",
              color: Color(0xFF46b754),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  FontAwesomeIcons.comment,
                  size: 80.0,
                ),
              ),
              iconAmin: Image(
                image: new AssetImage("assets/chat.gif"),
                width: 80.0,
              ),
              route: '/chat'),
          _buildPage(
              menu: "Profile",
              color: Color(0xFF8a67ab),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  Icons.portrait,
                  size: 80.0,
                ),
              ),
              iconAmin: Image(
                image: new AssetImage("assets/profile.gif"),
                width: 80.0,
              ),
              route: '/profile'),
          _buildPage(
              menu: "Log out",
              color: Color(0xFF57ba9c),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  Icons.exit_to_app,
                  size: 80.0,
                ),
              ),
              route: '/logoutView'),
          /*         _buildPage(
              menu: "Play Video",
              color: Color(0xFF8a67ab),
              icon: IconTheme(
                data: new IconThemeData(color: Colors.white),
                child: new Icon(
                  Icons.video_library,
                  size: 80.0,
                ),
              ),
              route: '/video'),*/
        ]);
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
                        exit(0);
                      },
                      child: Row(children: <Widget>[
                        Container(
                          height: 50.0,
                          child: IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child: new Icon(FontAwesomeIcons.checkCircle,
                                size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0, top: 12.0),
                            height: 50.0,
                            child: Text(
                              "Exit App",
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

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Log out?"), actions: <Widget>[
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

  double getLayoutHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return (height - _appBarHeight - 90) / 5;
  }
  /*
  _longPressMenu(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => longPress()));
  }
  */
}
/*
class longPress extends StatelessWidget {
  const longPress({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return new Material(
        color: Colors.lightBlue,
        child: new ListView(children: <Widget>[
          InkWell(
              onTap: () {
                Navigator.of(context).pop(0);
              },
              child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Row(children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 45.0, top: 30.0),
                      child: IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child:
                            new Icon(FontAwesomeIcons.timesCircle, size: 40.0),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, top: 30.0),
                        child: Text(
                          "Resume",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
                        )),
                  ]))),
          InkWell(
              onTap: () {
                exit(0);
              },
              child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Row(children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 45.0, bottom: 30.0),
                      child: IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child:
                            new Icon(FontAwesomeIcons.checkCircle, size: 40.0),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, bottom: 30.0),
                        child: Text(
                          "Exit App",
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
*/

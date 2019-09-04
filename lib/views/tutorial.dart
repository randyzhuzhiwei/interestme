import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/speech_recognition.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'tutorialD.dart';
import 'splash.dart';
import 'routes.dart';

const double _appBarHeight = 110.0;

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => new _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  @override

  final controller = PageController(initialPage: 1);

  Color bgColor = Colors.deepOrangeAccent;

  int _current = 0;
  @override
  initState() {
    super.initState();
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
                        Navigator.of(context).pushNamedAndRemoveUntil(
            '/splash', (Route<dynamic> route) => false);
                      },
                      child: Row(children: <Widget>[
                        Container(
                          height: 50.0,
                          child: IconTheme(
                            data: new IconThemeData(color: Colors.white),
                            child: new Icon(FontAwesomeIcons.home,
                                size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0, top: 12.0),
                            height: 50.0,
                            child: Text(
                              "Home",
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

  Widget _buildPage({String menu,Color color, String route}) {
   
    return new Material(
        color: color,
        child: InkWell(
            onTap: () {
              
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: route)));
                       
            },
            child: Container(
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 85.0, bottom: 10.0),
                child:Column(children: <Widget>[
                    
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
  _buildPageView() {
    
    return 
          PageView(
            scrollDirection: Axis.vertical,
            controller: controller,
            children: [
              _buildOptionPage(),
              _buildPage(
                  menu: "Send message?",
                  color: Color(0xFFf79646),
                  route: 'say'),
              _buildPage(
                  menu: "See posting?",
                  color: Color(0xFF4bacc6),
                  route: 'story'),
              _buildPage(
                  menu: "Search tagged messages",
                  color: Color(0xFFee3338),
                  route: 'find'),
              _buildPage(
                  menu: "Chat with friend?",
                  color: Color(0xFF46b754),
                  route: 'chat'),
              _buildPage(
                  menu: "View profile?",
                  color: Color(0xFF8a67ab),
                  route: 'profile'),
             
        ]);
  }

  Widget build(BuildContext context) {
    // TODO: implement build

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
           return new CustomScrollView(slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: bgColor,
                      leading: new IconButton(
                        icon: new Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            '/splash', (Route<dynamic> route) => false),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Tutorial ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24.0,
                                  )),
                              IconTheme(
                                data: new IconThemeData(color: Colors.white),
                                child: new Icon(Icons.live_help),
                              ),
                            ]),
                      ),
                    ),
                SliverList(
    delegate: SliverChildListDelegate(
      [  Column(children: [
                  Container(alignment: Alignment.center, child: Text("How can I help you?", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                  )),height: 70.0),
                  Container(
                      child: Column(children: [Container(
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: "say")));
                       
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                                "How to send message",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26.0),
                              )
                           ,
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFFf79646),
              ),
              Container(
                margin:EdgeInsets.only(top:3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: "story")));
                       
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                                "How to see friends posting",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26.0),
                              )
                           ,
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF4bacc6),
              ),
              Container(
                margin:EdgeInsets.only(top:3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: "find")));
                       
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                                "How to find tagged messages",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26.0),
                              )
                           ,
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFFee3338),
              ),
              Container(
                margin:EdgeInsets.only(top:3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: "chat")));
                       
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                                "How to chat with friends",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26.0),
                              )
                           ,
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF46b754),
              ),
              Container(
                margin:EdgeInsets.only(top:3.0),
                child: new Material(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new TutorialDetailScreen(value: "profile")));
                       
                      },
                      child: new Container(
                        margin: EdgeInsets.only(top: 3.0),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                                "How to change my profile",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26.0),
                              )
                           ,
                        height: getLayoutHeight(context),
                      )),
                  color: Colors.transparent,
                ),
                color: Color(0xFF8a67ab),
              ),
                  ]))
                ])]))]);
          })));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
  
  double getLayoutHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return (height - _appBarHeight - 90) / 5;
  }
}

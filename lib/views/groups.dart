/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'menu.dart';

const double _appBarHeight = 110.0;

class MyGroupScreen extends StatefulWidget {
  @override
  _MyGroupScreenState createState() => new _MyGroupScreenState();
}

class _MyGroupScreenState extends State<MyGroupScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return new WillPopScope(
        onWillPop: _onBackPressed,
        child:   new Scaffold(
            body: new Container(
                color: Color(0xFF46b754),
                child: ListView(
                  children: <Widget>[
                    Container(
                        color: Colors.white,
                        child: new Container(
                          margin: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 30.0, bottom: 10.0),
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                new Container(
                                    child: Image.asset('assets/logo.png')),
                                new Container(
                                    alignment: Alignment.center,
                                    child: Image.asset('assets/profile.png'))
                              ]),
                          height: _appBarHeight,
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                            margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    "My Groups",
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 30.0),
                                  ),
                                  new IconButton(
                                icon: new IconTheme(
                                  data: new IconThemeData(color: Colors.red),
                                  child: new Icon(Icons.add_circle),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen()),
                                  );
                                })
                                ]))),
                    Container(
                      child: new Material(
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuScreen()),
                              );
                            },
                            child: new Container(
                              margin: EdgeInsets.only(top: 0.0),
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              child: new Text(
                                "Mario Family",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 30.0),
                              ),
                              height: getLayoutHeight(context),
                            )),
                        color: Colors.transparent,
                      ),
                      color: Color(0xFFee3338),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0.0),
                      color: Color(0xFFf6925e),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: new Text(
                        "IT Club",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30.0),
                      ),
                      height: getLayoutHeight(context),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0.0),
                      color: Color(0xFF33bdb6),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: new Text(
                        "Adolescents",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30.0),
                      ),
                      height: getLayoutHeight(context),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0.0),
                      color: Color(0xFF205da9),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: new Text(
                        "Switch",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30.0),
                      ),
                      height: getLayoutHeight(context),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0.0),
                      color: Color(0xFFacacac),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: new Text(
                        "Minecraft",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30.0),
                      ),
                      height: getLayoutHeight(context),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                            margin: EdgeInsets.only(top: 1.0),
                            child: new IconButton(
                                icon: new IconTheme(
                                  data: new IconThemeData(color: Colors.blue),
                                  child: new Icon(FontAwesomeIcons.timesCircle),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen()),
                                  );
                                }))),
                  ],
                ))));
  }


  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
  double getLayoutHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    print(_appBarHeight);
    return (height - _appBarHeight - 170) / 5;
  }
}
*/
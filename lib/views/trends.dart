/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/user.dart';
import 'menu.dart';
import '../app_state_container.dart';

const double _appBarHeight = 110.0;

class TrendsScreen extends StatefulWidget {
  @override
  _TrendsScreenState createState() => new _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  
  User _user;
    String _text = "initial";
  TextEditingController _c;

  initState(){
    _c = new TextEditingController();
    super.initState();
  }

 Widget _buildPage({String menu, IconButton icon, Color color, void f()}) {
    return new Material(
        color: color,
        child: InkWell(
            onTap: () {
              f();
            },
            child: Container(
                margin: EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 60.0, bottom: 40.0),
                child: Column(children: <Widget>[
                  icon,
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
    return 
        TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15.0),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'What do you want to say?'
                ),
              
      
    );
  }

_dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _user = AppStateContainer.of(context).user;
    if (AppStateContainer.of(context).device == Device.watch) {
     // return new Scaffold(
      //    resizeToAvoidBottomPadding: false, body: _buildPageView());
       return new GestureDetector(
    onTap: () {
      
      this._dismissKeyboard(context);
    },
    child: SafeArea(
      child:Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(_text),
            new RaisedButton(onPressed: () {
              
                        print("");

              showDialog(child: new Dialog(
                child: new Column(
                  children: <Widget>[
                    new TextField(
                        decoration: new InputDecoration(hintText: "Update Info"),
                        controller: _c,

                    ),
                    new FlatButton(
                      child: new Text("Save"),
                      onPressed: (){
                        setState((){
                        this._text = _c.text;
                      });
                      Navigator.pop(context);
                      },
                    )
                  ],
                ),

              ), context: context);
            },child: new Text("Show Dialog"),)
          ],
        )
      ),
    )));
    } else {
      return new WillPopScope(
          onWillPop: _onBackPressed,
          child: new Scaffold(
              body: new Container(
                  color: Color(0xFF4bacc6),
                  child: ListView(
                    children: <Widget>[
                      Container(
                          color: Colors.white,
                          child: new Container(
                            margin: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                top: 30.0,
                                bottom: 10.0),
                            child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            child: new Text(
                              "Top Trends",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 30.0),
                            ),
                          )),
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
                                  "#Switch",
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
                        color: Color(0xFFf79646),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0.0),
                        color: Color(0xFFaed478),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: new Text(
                          "#School",
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
                        color: Color(0xFF8897cb),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: new Text(
                          "#ITClub",
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
                        color: Color(0xFFa6692b),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: new Text(
                          "#Xmas",
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
                        color: Color(0xFF23365f),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: new Text(
                          "#Minecraft",
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
                                    data:
                                        new IconThemeData(color: Colors.orange),
                                    child:
                                        new Icon(FontAwesomeIcons.timesCircle),
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
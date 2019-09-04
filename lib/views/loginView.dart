import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user.dart';
import '../app_state_container.dart';
import '../models/speech_recognition.dart';
import 'splash.dart';
import 'routes.dart';

class LoginViewScreen extends StatefulWidget {
  @override
  _LoginViewScreenState createState() => new _LoginViewScreenState();
}

class _LoginViewScreenState extends State<LoginViewScreen> {
  final formkey = new GlobalKey<FormState>();
  User _user;
  String _username;
  String _password;
  String inputOptions;

  ScrollController _scrollController= new ScrollController();
  Color bgColor;

  SpeechRecognition _speech;
  var txt = new TextEditingController();

  var txt2 = new TextEditingController();
  final controller = PageController(initialPage: 0);
  initState() {
    super.initState();
    _speech = new SpeechRecognition();
    _speech.setKeyboardResultHandler(onKeyboardResult);
    txt.text = "";
    txt2.text = "";

    bgColor = Color(0xFFf79646);
  }

  @override
  Widget build(BuildContext context) {
    
    print("Login View OK");
    // TODO: implement build
    _user = AppStateContainer.of(context).user;

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
  SliverList(
    delegate: SliverChildListDelegate(
      [   
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                left: 70.0,
                                right: 50.0,
                                top: 80.0,
                                bottom: 0.0),
                            child: Image.asset('assets/logo.png'),
                            height:
                                (MediaQuery.of(context).size.height / 3) + 50,
                          ),
                          Container(
                              child: _containerLogin()
                                  ),
                        ])]))
               
        
              ]);
              })));
        }
  }

  void onKeyboardResult(String text) => setState(() {
        //    final snackBar = SnackBar(content: Text('Results:${_transcription}'));
        //    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);

        if (inputOptions == "Password") txt2.text = text;
        if (inputOptions == "Username") txt.text = text;
      });
  void getKeyboard(BuildContext context) =>
      _speech.getKeyboard(text: "").then((result) {
        //       final snackBar = SnackBar(content: Text('_MyAppState.start => result ${result}'));
        //   Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
        //print('_MyAppState.start => result ${result}');
      });

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }

  Widget _buildPageView() {
    return PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _buildUserNamePage(),
        _buildPasswordPage(),
        _buildLoginButtonPage(),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildUserNamePage() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
        color: bgColor,
        child: new Center(
            child: Container(
                padding: EdgeInsets.only(
                  top: 50.0,
                ),
                child: Column(children: <Widget>[
                  new Text(
                    "Username",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18.0),
                  ),
                  new GestureDetector(
                      onTap: () {
                        inputOptions = "Username";
                        getKeyboard(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 30.0),
                          child: new Text(
                            txt.text,
                            maxLines: 1,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0),
                          ))),
                  new GestureDetector(
                      onTap: () {
                        inputOptions = "Username";
                        getKeyboard(context);
                      },
                      child: new Text("___________________________"
                            ,maxLines: 1,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0),)),
                  new Container(
                    padding: EdgeInsets.only(top: 40.0),
                    child: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: Icon(Icons.arrow_drop_up),
                    )
                  )
                ]))),
      );
    } else {}
  }

  Widget _buildPasswordPage() {
    if (AppStateContainer.of(context).device == Device.watch) {
      return new Material(
        color: bgColor,
        child: new Center(
            child: Container(
                padding: EdgeInsets.only(
                  top: 50.0,
                ),
                child: Column(children: <Widget>[
                  new Text(
                    "Password",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18.0),
                  ),
                  new GestureDetector(
                      onTap: () {
                        inputOptions = "Password";
                        getKeyboard(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 30.0),
                          child: new Text(
                            txt2.text,
                            maxLines: 1,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0),
                          ))),
                 
                  new GestureDetector(
                    onTap: () {
                      inputOptions = "Password";
                      getKeyboard(context);
                    },
                    child: new Text("___________________________",
                            maxLines: 1,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0),),
                  ),
                  new Container(
                    padding: EdgeInsets.only(top: 40.0),
                    child: new IconTheme(
                    data: new IconThemeData(color: Colors.white),
                    child: Icon(Icons.arrow_drop_up),
                    )
                  )
                ]))),
      );
    } else {
      
    }
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
            decoration: new InputDecoration(labelText: 'Username'),
            validator: (value) =>
                value.isEmpty ? 'Username cannot be empty' : null,
            onSaved: (value) => txt.text = value,
          )),
      new Container(
          width: 300.0,
          child: new TextFormField(
            decoration: new InputDecoration(labelText: 'Password'),
            validator: (value) =>
                value.isEmpty ? 'Password cannot be empty' : null,
            obscureText: true,
            onSaved: (value) => txt2.text = value,
          )),
      Padding(padding: EdgeInsets.only(top: 40.0)),
    ];
  }

  List<Widget> buildSubmitButtons() {
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
             exit(0);
          },
        )
      ];
   
  }

  void validateAndSubmit() async {
    
    if (validateAndSave()) {
_login();
    }
  }
  
  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget _buildLoginButtonPage() {
    return new Material(
        color: bgColor,
        child: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              InkWell(
                  onTap: () {
                    _login();
                  },
                  child: Container(
                      child: Column(children: <Widget>[
                    IconButton(
                      icon: new IconTheme(
                        data: new IconThemeData(color: Colors.white),
                        child: new Icon(Icons.input, size: 40.0),
                      ),
                      onPressed: () {
                        _login();
                      },
                    ),
                    Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ])))
            ])));
  }

  void _login() async {
    await getSharedPreferenceUser();
  }

  Future<Null> getSharedPreferenceUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('LoggedInUsername', txt.text);
    await prefs.setString('LoggedInPassword', txt2.text);

//Navigator.of(context).pushNamedAndRemoveUntil('/splash', (Route<dynamic> route) => false);
    //    Navigator.of(context).push('/splash');
    print("here");

    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
    */
    Navigator.pushNamed(context, '/splash');
  }

  Widget _buildCloseButton() {
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
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/speech_recognition.dart';
import '../app_state_container.dart';
import '../models/user.dart';
import 'menu.dart';
import 'package:carousel_slider/carousel_slider.dart';

const double _appBarHeight = 110.0;


List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class TutorialDetailScreen extends StatefulWidget {
  @override
  
  String value;
  
  
  TutorialDetailScreen({Key key, this.value}) : super(key: key);
  _TutorialDetailScreenState createState() => new _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen>
    with TickerProviderStateMixin {
  @override
  User _user;

  final controller = PageController(initialPage: 1);

  var txt = new TextEditingController();
  Color bgColor = Colors.deepOrangeAccent;
  String watch_img;
  AssetImage img_watch;

  int _current = 0;
  @override
  initState() {
    if(widget.value=="say")
    {
      watch_img='assets/say_w.gif';
      imgList=imgSayList;
    }if(widget.value=="story")
    {
      watch_img='assets/story_w.gif';
      imgList=imgStoryList;
    }if(widget.value=="find")
    {
      watch_img='assets/find_w.gif';
      imgList=imgFindList;
    }if(widget.value=="chat")
    {
      watch_img='assets/chat_w.gif';
      imgList=imgChatList;
    }if(widget.value=="profile")
    {
      watch_img='assets/profile_w.gif';
      imgList=imgProfileList;
    }
    super.initState();
    img_watch=new AssetImage(watch_img);
    child = map<Widget>(
      imgList,
      (index, i) {
        return Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: Stack(children: <Widget>[
              Image.asset(i, fit: BoxFit.cover, width: 1000.0),
            ]),
          ),
        );
      },
    ).toList();
    
  }
List<String> imgList;
/*
  List<String> imgSayList = [
  assets/say_w.gif',
  assets/chat_w.gif',
  assets/find_w.gif',
  assets/profile_w.gif',
  assets/story_w.gif',
    
  ];

*/
  List<String> imgSayList = [
    'assets/say1.jpg',
    'assets/say2.jpg',
    'assets/say3.jpg',
    'assets/say4.jpg',
    'assets/say5.jpg',
    'assets/say6.jpg',
  ];
  
  List<String> imgStoryList = [
    'assets/story5.jpg',
    'assets/story1.jpg',
    'assets/story2.jpg',
    'assets/story3.jpg',
    'assets/story4.jpg',
  ];

  
  List<String> imgFindList = [
    'assets/find6.jpg',
    'assets/find1.jpg',
    'assets/find2.jpg',
    'assets/find3.jpg',
    'assets/find4.jpg',
    'assets/find5.jpg',
  ];

  
  
  List<String> imgChatList = [
    'assets/chat1.jpg',
    'assets/chat2.jpg',
    'assets/chat3.jpg',
  ];
  
  List<String> imgProfileList = [
    'assets/profile1.jpg',
    'assets/profile2.jpg',
    'assets/profile3.jpg',
    'assets/profile4.jpg',
    'assets/profile5.jpg',
  ];
  List child;

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
                            child: new Icon(FontAwesomeIcons.backward,
                                size: 40.0),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 5.0, top: 12.0),
                            height: 50.0,
                            child: Text(
                              "Back",
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

  _buildPageView() {
    
    return 
          PageView(
            scrollDirection: Axis.vertical,
            controller: controller,
            children: [
              _buildOptionPage(),
                Material(
                color: Colors.black87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(),
                Container(
                 height: MediaQuery.of(context).size.height / 10 *9,
                  child: Image(
                                image: img_watch,
                              )
                )
            ])
              )
            ]);
  }

  @override
  void dispose() {
    //streamSub.cancel();
    super.dispose();
    img_watch=null;
    
    
  }

  Widget build(BuildContext context) {
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
            return new CustomScrollView(slivers: <Widget>[
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
      [ Column(
                  children: [
                     Container(height:70.0),
                  Container(
                    child: Column(children: [
                  CarouselSlider(
                    items: child,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    //aspectRatio: 2.0,
                    height: MediaQuery.of(context).size.height / 5*4,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: map<Widget>(
                      imgList,
                      (index, url) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == index
                                  ? Color.fromRGBO(0, 0, 0, 0.9)
                                  : Color.fromRGBO(0, 0, 0, 0.4)),
                        );
                      },
                    ),
                  ),
                ]))])]))]);
          })));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.pop(context, true);
    return null;
  }
}

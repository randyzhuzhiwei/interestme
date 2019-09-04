import 'package:flutter/material.dart';
import 'dlogin.dart';
import 'menu.dart';
import 'say.dart';
import 'profile.dart';
import 'splash.dart';
import 'findInterest.dart';
import 'chat.dart';
import 'chatHistory.dart';
import 'stories.dart';
import 'searchResults.dart';
import 'video.dart';
import 'loginView.dart';
import 'logoutView.dart';
import 'tutorial.dart';


class routesFinder{

BuildContext _ctx;


  routesFinder(this._ctx);

  
  BuildContext get ctx => _ctx;
  
 static final routes= {
'/login':(BuildContext context)=>new LoginScreen(),
'/splash':(BuildContext context)=>new SplashScreen(),
'/menu':(BuildContext context)=>new MenuScreen(),
'/say':(BuildContext context)=>new SayScreen(),
'/profile':(BuildContext context)=>new ProfileScreen(),
'/interest':(BuildContext context)=>new FindInterestScreen(),
'/chat':(BuildContext context)=>new ChatScreen(),
'/chatHistory':(BuildContext context)=>new ChatHistoryScreen(),
'/stories':(BuildContext context)=>new StoriesScreen(),
'/searchResults':(BuildContext context)=>new SearchResultScreen(),
'/video':(BuildContext context)=>new VideoScreen(),
'/loginView':(BuildContext context)=>new LoginViewScreen(),
'/logoutView':(BuildContext context)=>new LogoutViewScreen(),
'/tutorial':(BuildContext context)=>new TutorialScreen(),

};



}
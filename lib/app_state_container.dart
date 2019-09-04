// app_state_container.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';


enum Device { mobile, watch }

class AppStateContainer extends InheritedWidget {
   AppStateContainer({
      Key key,
      @required Widget child,
      this.user,
      this.device,
   }): super(key: key, child: child);
	
   final User user;
   final Device device;
	
   static AppStateContainer of(BuildContext context) {
      return context.inheritFromWidgetOfExactType(AppStateContainer) as AppStateContainer;
   }

   @override
   bool updateShouldNotify(AppStateContainer oldWidget) => true;
}

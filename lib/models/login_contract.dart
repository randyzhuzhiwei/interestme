import 'user.dart';


abstract class LoginContract{
  void onLoginSuccess(User user);
  void onLoginError(String error);
  
}


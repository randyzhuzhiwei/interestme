import 'package:http/http.dart' as http;

class FcmHelper {
  static final FcmHelper _instance = new FcmHelper.internal();
  factory FcmHelper() => _instance;

  static FcmHelper _fcm;
  
  Future<FcmHelper> get fcm async {
   
    return _fcm;
  }
  FcmHelper.internal();

   final String url = "https://us-central1-interestme-b71ed.cloudfunctions.net/notify";

  
  Future<Null> sendNotification(String title,String body,String token) async {

String encodedBody;

String encodedTitle;

 String temp ;

String emptyURL="";
       temp = Uri.parse(emptyURL).replace(query: body).toString();
      encodedBody= temp.substring(1); 
      
       temp = Uri.parse(emptyURL).replace(query: title).toString();
      encodedTitle= temp.substring(1); 

print("sending title - $title and body $body");
    http.post(url, headers: {"title": encodedTitle, "body": encodedBody,"token": token}).then(
        (response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    });
    return null;
  }
}

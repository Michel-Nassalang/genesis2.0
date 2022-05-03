import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationService {

  static void initialize(){
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((event) { 
      print("Un nouveau message a été publié !");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { 
      print("Un nouveau message a été publié !");
     });
  }

  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken(vapidKey: "BFSKYKurXVIEdTzEWrh7u6IpyqF5Nm2-GLafqeCB1pbx6DFQsw0gWUTKm_LQbv5Y7IgCfwaJhm0CyG0C4khfMuo");
  }

}
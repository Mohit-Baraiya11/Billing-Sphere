
import 'package:firebase_messaging/firebase_messaging.dart';

class Firebase_Api{
  final _firebaseMessing = FirebaseMessaging.instance;
  Future<void> initNotifications()async{
    await _firebaseMessing.requestPermission();
    final FCMToken = await _firebaseMessing.getToken();
    print('📝 📝 📝  Token : $FCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

Future<void> handleBackgroundMessage (RemoteMessage message)async{
  print('Title :${message.notification?.title}');
  print('Body :${message.notification?.body}');
  print('Title :${message.data}');
}
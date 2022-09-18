import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationTopic {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void subscribeToTopic(List<String> topics) {
    for (var e in topics) _firebaseMessaging.subscribeToTopic(e);
  }

  void unsubscribeFromTopic(List<String> topics) {
    for (var e in topics) _firebaseMessaging.unsubscribeFromTopic(e);
  }
}

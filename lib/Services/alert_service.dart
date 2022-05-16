import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bg_service.dart';
import 'fcm_service.dart';
import 'utility_service.dart';

class AlertService {
  Future<void> sendAlert(String title, String body) async {
    List<String> tokens = [];
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User _currentUser = FirebaseAuth.instance.currentUser;
    List<String> emergencyContacts =
        extractNumbers(prefs.getStringList("numbers"));
    QuerySnapshot querySnapshot =
        await users.where('phoneNumber', whereIn: emergencyContacts).get();
    List<String> uids = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return data['uid'].toString();
    }).toList();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      tokens.add(data['fcmToken']);
    }

    FCMService fcmService = FCMService();
    fcmService.sendMessage(tokens, title, body, {'uid': _currentUser.uid});
    logNotifications(uids, _currentUser.uid);
  }

  void logNotifications(List<String> uids, String uid) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('notifications');

    notifications.add({
      'from': uid,
      'to': uids,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }
}

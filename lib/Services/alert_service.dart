import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bg_service.dart';
import 'fcm_service.dart';
import 'unitility_service.dart';

class AlertService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  List<String> tokens = [];

  Future<void> sendAlert(String title, String body) async {
    BackgroundService.initializeService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User _currentUser = FirebaseAuth.instance.currentUser;
    List<String> emergencyContacts =
        extractNumbers(prefs.getStringList("numbers"));
    emergencyContacts = emergencyContacts != []
        ? ['+919791322960', '+911234567890']
        : emergencyContacts;
    print(emergencyContacts);
    QuerySnapshot querySnapshot =
        await users.where('phoneNumber', whereIn: emergencyContacts).get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      tokens.add(data['fcmToken']);
    }
    print(tokens);

    FCMService fcmService = FCMService();
    fcmService.sendMessage(tokens, title, body, {'uid': _currentUser.uid});
  }
}

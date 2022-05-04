import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fcm_service.dart';

class AlertService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  List<String> tokens = [];

  Future<void> sendAlert(String title, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> emergencyContacts =
        prefs.getStringList("numbers") ?? ['+919791322960'];
    QuerySnapshot querySnapshot =
        await users.where('phoneNumber', whereIn: emergencyContacts).get();
    querySnapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      tokens.add(data['fcmToken']);
    });
    FCMService fcmService = FCMService();
    fcmService.sendMessage(tokens, title, body);
  }
}

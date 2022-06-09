import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fcm_service.dart';
import 'utility_service.dart';

class AlertService {
  String subTitle = "Click to view location";

  Future<void> sendAlert(bool isSos) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Position myLocation = await Geolocator.getCurrentPosition();
    User _currentUser = FirebaseAuth.instance.currentUser;

    String sosMessage = '${_currentUser.displayName} is in danger!';
    String safeMessage = '${_currentUser.displayName} is Safe!';
    String sosSMS =
        '${_currentUser.displayName} is in danger!\n https://maps.google.com/?q=${myLocation.latitude},${myLocation.longitude}';
    String safeSMS =
        '${_currentUser.displayName} is Safe!\n https://maps.google.com/?q=${myLocation.latitude},${myLocation.longitude}';
    List<String> tokens = [];

    List<String> emergencyContacts =
        extractNumbers(prefs.getStringList("numbers"));
    QuerySnapshot querySnapshot =
        await users.where('phoneNumber', whereIn: emergencyContacts).get();

    List<String> uids = [];
    List<String> fcmContacts = [];
    List<String> nonAppUsers = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      tokens.add(data['fcmToken']);
      uids.add(data['uid'].toString());
      fcmContacts.add(data['phoneNumber']);
    }

    for (var number in emergencyContacts) {
      if (!fcmContacts.contains(number)) {
        nonAppUsers.add(number);
      }
    }

    FCMService fcmService = FCMService();
    fcmService.sendMessage(tokens, isSos ? sosMessage : safeMessage, subTitle,
        {'uid': _currentUser.uid});

    _sendSMS(isSos ? sosSMS : safeSMS, nonAppUsers);

    logNotifications(isSos, uids, _currentUser.uid);
  }

  void logNotifications(bool isSos, List<String> uids, String uid) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('notifications');

    notifications.add({
      'from': uid,
      'to': uids,
      'sos': isSos,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}

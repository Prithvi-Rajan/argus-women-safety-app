import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:womensafteyhackfair/constants.dart';


class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<String> getToken() async {
    String token = await _fcm.getToken();
    return token;
  }

  Future<bool> sendMessage(
      List<String> userTokens, String title, String body) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "registration_ids": userTokens,
      "collapse_key": "type_a",
      "notification": {
        "title": title,
        "body": body,
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${FCM_KEY}'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('FCM error');
      return false;
    }
  }
}

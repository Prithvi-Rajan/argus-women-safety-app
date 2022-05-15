import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:womensafteyhackfair/constants.dart';
import 'package:womensafteyhackfair/firebase_options.dart';
import 'package:womensafteyhackfair/theme.dart';

import './Dashboard/Splsah/Splash.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  showNotification(
      message.notification.title, message.notification.body, message.data);

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupNotification();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

setupNotification() async {
  await FirebaseMessaging.instance.requestPermission();
  final token = await FirebaseMessaging.instance.getToken();
  print("Notification Token $token");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(
        message.notification.title, message.notification.body, message.data);

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }, onError: (e) {
    print("Foreground Notification Error: $e");
  });
}

void showNotification(
    String title, String body, Map<String, dynamic> payload) async {
  await _demoNotification(title, body, payload);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _demoNotification(
    String title, String body, Map<String, dynamic> payload) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'sos_notification_saa_suraksha', 'Saa Suraksha',
      channelDescription: 'SOS Notification',
      importance: Importance.max,
      playSound: false,
      // sound: AndroidNotificationSoun,
      showProgress: true,
      enableVibration: true,
      priority: Priority.high,
      ticker: 'test ticker');

  var iOSChannelSpecifics = const IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, body, platformChannelSpecifics, payload: payload['uid']);
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          primarySwatch: Colors.red,
          buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromARGB(255, 243, 124, 124),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor, width: 1.5),
              borderRadius: BorderRadius.circular(50),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor, width: 1.5),
              borderRadius: BorderRadius.circular(50),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor, width: 1.5),
              borderRadius: BorderRadius.circular(50),
            ),
          )),
      home: const Splash(),
    );
  }
}

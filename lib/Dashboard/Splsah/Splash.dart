import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:womensafteyhackfair/Dashboard/Dashboard.dart';
import 'package:womensafteyhackfair/constants.dart';
import 'package:womensafteyhackfair/login_screen/login_screen.dart';

import '../../Services/fcm_service.dart';
import '../../create_user_screen/createUserScreen.dart';

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      handleBoot();
    });
  }

  handleBoot() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    FCMService fcmService = FCMService();
    String token = await fcmService.getToken();
    FirebaseAuth.instance.authStateChanges().first.then((user) async {
      if (user != null) {
        await users.doc(user.uid).update({'fcmToken': token});
        if (user.displayName == null || user.photoURL == null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateUserScreen()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFD8080),
        body: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Lottie.asset('assets/blossoms.json',
                    height: MediaQuery.of(context).size.width * 1.2)),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Image.asset(
                  "assets/logo.png",
                  height: 100,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180.0),
                child: Text(
                  appName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 140.0),
                child: Text(
                  "You deserve to be safe!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ));
  }
}

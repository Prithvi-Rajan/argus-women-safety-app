import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:womensafteyhackfair/Dashboard/Dashboard.dart';
import 'package:womensafteyhackfair/login_screen/login_screen.dart';

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

    Timer(Duration(seconds: 3), () {
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        if (user != null) {
          if (user.displayName == null || user.photoURL == null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CreateUserScreen()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          }
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFD8080),
        body: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Lottie.asset('assets/blossoms.json',
                    height: MediaQuery.of(context).size.width * 1.2)),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 80),
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
                  "ARGUS",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 140.0),
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

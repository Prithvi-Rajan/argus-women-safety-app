import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:womensafteyhackfair/Dashboard/Splsah/Splash.dart';
import 'package:womensafteyhackfair/firebase_options.dart';
import 'package:womensafteyhackfair/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterBackgroundService.initialize(onStart);
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: false,
  // );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Argus',
      theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          primarySwatch: Colors.red,
          buttonTheme: ButtonThemeData(
            buttonColor: const Color.fromARGB(255, 243, 124, 124),
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
      home: Splash(),
    );
  }

  Future<bool> isAppOpeningForFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = prefs.getBool("appOpenedBefore") ?? false;
    if (!result) {
      prefs.setBool("appOpenedBefore", true);
    }
    return result;
  }
}

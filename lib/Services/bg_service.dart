import 'dart:async';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart' as gla;
import 'package:womensafteyhackfair/Services/utility_service.dart';
import 'package:womensafteyhackfair/firebase_options.dart';

class BackgroundService {
  final service = FlutterBackgroundService();

  void stopService() {
    // final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  Future<void> initializeService() async {
    await checkPermission();
    // final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: (_) async {
          return true;
        },
      ),
    );
    await service.startService();
  }

  static void onStart(ServiceInstance service) async {
    Timer timer;

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    gla.GeolocatorAndroid.registerWith();

    if (service is AndroidServiceInstance) {
      service.setAsBackgroundService();
    }

    service.on('stopService').listen((event) {
      timer?.cancel();
      print('stopped');
      service.stopSelf();
    });

    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Background Service running",
          content: "Updated at ${parseTimeStamp(DateTime.now())}",
        );
        run();
      }
    });
  }

  static void run() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User _currentUser = FirebaseAuth.instance.currentUser;
    int batteryPercent =
        (await BatteryInfoPlugin().androidBatteryInfo).batteryLevel;

    String error = '';
    try {
      Position myLocation = await Geolocator.getCurrentPosition();
      var currentLocation = myLocation;
      final geo = Geoflutterfire();
      GeoFirePoint myLocationPoint = geo.point(
          latitude: myLocation.latitude, longitude: myLocation.longitude);
      await users.doc(_currentUser.uid).update({
        'batteryPercent': batteryPercent,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'geohash': myLocationPoint.data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
    }
  }
}

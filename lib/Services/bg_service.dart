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
import '../Services/utility_service.dart';
import '../firebase_options.dart';

class BackgroundService {
  final service = FlutterBackgroundService();

  void stopService() {
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

    // if (service is AndroidServiceInstance) {
    //   service.setAsBackgroundService();
    // }

    service.on('stopService').listen((event) async {
      timer?.cancel();
      await service.stopSelf();
      print('stopped');
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
    int batteryPercent =
        (await BatteryInfoPlugin().androidBatteryInfo).batteryLevel;

    String error = '';
    try {
      User _currentUser = FirebaseAuth.instance.currentUser;
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
        'alert': true
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

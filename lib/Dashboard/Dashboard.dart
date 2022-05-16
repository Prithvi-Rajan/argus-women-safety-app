import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:womensafteyhackfair/Dashboard/ContactScreens/phonebook_view.dart';
import 'package:womensafteyhackfair/Dashboard/Home.dart';
import 'package:womensafteyhackfair/Dashboard/ContactScreens/MyContacts.dart';
import 'package:womensafteyhackfair/Services/alert_service.dart';

import '../Services/bg_service.dart';
import '../Services/utility_service.dart';
import '../ViewLocation/view_location.dart';

class Dashboard extends StatefulWidget {
  final int pageIndex;
  const Dashboard({Key key, this.pageIndex = 0}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState(currentPage: pageIndex);
}

class _DashboardState extends State<Dashboard> {
  _DashboardState({this.currentPage = 0});

  List<Widget> screens = [const Home(), const MyContactsScreen()];
  bool alerted = false;
  int currentPage = 0;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool pinChanged = false;
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    super.initState();
    checkAlertSharedPreferences();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ViewLocation(uid: payload)));
  }

  SharedPreferences prefs;
  checkAlertSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        alerted = prefs.getBool("alerted") ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFE),
      floatingActionButton: currentPage == 1
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PhoneBook()));
              },
              child: Image.asset(
                "assets/add-contact.png",
                height: 60,
              ),
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFB9580),
              onPressed: () async {
                if (alerted) {
                  int pin = (prefs.getInt('pin') ?? -1111);
                  print('User $pin .');
                  if (pin == -1111) {
                    sendAlert(false);
                  } else {
                    showPinModelBottomSheet(pin);
                  }
                } else {
                  sendAlert(true);
                }
              },
              child: alerted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/alarm.png",
                          height: 24,
                        ),
                        Text("STOP")
                      ],
                    )
                  : Image.asset(
                      "assets/icons/alert.png",
                      height: 36,
                    ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    if (currentPage != 0) {
                      setState(() {
                        currentPage = 0;
                      });
                    }
                  },
                  child: Image.asset(
                    "assets/home.png",
                    height: 28,
                  )),
              InkWell(
                  onTap: () {
                    if (currentPage != 1) {
                      setState(() {
                        currentPage = 1;
                      });
                    }
                  },
                  child: Image.asset("assets/phone_red.png", height: 28)),
            ],
          ),
        ),
      ),
      body: SafeArea(child: screens[currentPage]),
    );
  }

  sendAlert(bool isAlert) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("alerted", isAlert);
      alerted = isAlert;
    });
    checkPermission();
    prefs.setBool("alerted", isAlert);
    List<String> numbers = prefs.getStringList("numbers") ?? [];
    LocationData myLocation;
    String error;
    String message = '';

    String displayName = FirebaseAuth.instance.currentUser.displayName;
    AlertService alertService = AlertService();

    try {
      if (numbers.isEmpty) {
        setState(() {
          prefs.setBool("alerted", false);
          alerted = false;
        });
        // BackgroundService bgService = BackgroundService();
        // bgService.initializeService();
        // alertService.sendAlert(message, "Click to view location");
        return Fluttertoast.showToast(
          msg: 'No Contacts Found!',
          backgroundColor: Colors.red,
        );
      } else {
        BackgroundService bgService = BackgroundService();
        if (isAlert) {
          message = "$displayName is in danger!";
        } else {
          // BackgroundService.stopService();
          // bgService.stopService();
          Fluttertoast.showToast(
              msg: "Contacts are being notified about false SOS.");
          message = "$displayName is Safe!";
        }
        // BackgroundService.initializeService();
        bgService.initializeService();
        alertService.sendAlert(message, "Click to view location");
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
      myLocation = null;

      prefs.setBool("alerted", false);

      setState(() {
        alerted = false;
      });
    }
  }

  showPinModelBottomSheet(int userPin) {
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                    Text(
                      "Please enter you PIN!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                  ],
                ),
                Image.asset("assets/pin.png"),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(20.0),
                  child: PinPut(
                    onSaved: (value) {
                      print(value);
                    },
                    fieldsCount: 4,
                    onSubmit: (String pin) =>
                        _showSnackBar(pin, context, userPin),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    selectedFieldDecoration: _pinPutDecoration,
                    followingFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showSnackBar(String pin, BuildContext context, int userPin) {
    if (userPin == int.parse(pin)) {
      Fluttertoast.showToast(
        msg: 'We are glad that you are safe',
      );
      sendAlert(false);
      _pinPutController.clear();
      _pinPutFocusNode.unfocus();
    } else {
      Fluttertoast.showToast(
        msg: 'Wrong Pin! Please try again',
      );
    }
  }
}

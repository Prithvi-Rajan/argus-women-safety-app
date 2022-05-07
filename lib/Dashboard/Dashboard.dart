import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/sms.dart' as sms_sender;
import 'package:womensafteyhackfair/Dashboard/ContactScreens/phonebook_view.dart';
import 'package:womensafteyhackfair/Dashboard/Home.dart';
import 'package:womensafteyhackfair/Dashboard/ContactScreens/MyContacts.dart';
import 'package:womensafteyhackfair/Services/alert_service.dart';

import '../Services/bg_service.dart';
import '../Services/unitility_service.dart';

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
    BackgroundService.initializeService();
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
                String displayName =
                    FirebaseAuth.instance.currentUser.displayName;
                AlertService alertService = AlertService();
                alertService.sendAlert(
                    "$displayName is in danger!", "Click to view location");
                if (alerted) {
                  int pin = (prefs.getInt('pin') ?? -1111);
                  print('User $pin .');
                  if (pin == -1111) {
                    sendAlertSMS(false);
                  } else {
                    showPinModelBottomSheet(pin);
                  }
                } else {
                  sendAlertSMS(true);
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
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    if (currentPage != 0)
                      setState(() {
                        currentPage = 0;
                      });
                  },
                  child: Image.asset(
                    "assets/home.png",
                    height: 28,
                  )),
              InkWell(
                  onTap: () {
                    if (currentPage != 1)
                      setState(() {
                        currentPage = 1;
                      });
                  },
                  child: Image.asset("assets/phone_red.png", height: 28)),
            ],
          ),
        ),
      ),
      body: SafeArea(child: screens[currentPage]),
    );
  }

  void sendSMS(String number, String msgText) {
    print(number);
    print(msgText);
    sms_sender.SmsMessage msg = new sms_sender.SmsMessage(number, msgText);
    final sms_sender.SmsSender sender = new sms_sender.SmsSender();
    msg.onStateChanged.listen((state) {
      if (state == sms_sender.SmsMessageState.Sending) {
        return Fluttertoast.showToast(
          msg: 'Sending Alert...',
          backgroundColor: Colors.blue,
        );
      } else if (state == sms_sender.SmsMessageState.Sent) {
        return Fluttertoast.showToast(
          msg: 'Alert Sent Successfully!',
          backgroundColor: Colors.green,
        );
      } else if (state == sms_sender.SmsMessageState.Fail) {
        return Fluttertoast.showToast(
          msg: 'Failure! Check your credits & Network Signals!',
          backgroundColor: Colors.red,
        );
      } else {
        return Fluttertoast.showToast(
          msg: 'Failed to send SMS. Try Again!',
          backgroundColor: Colors.red,
        );
      }
    });
    sender.sendSms(msg);
  }

  sendAlertSMS(bool isAlert) async {
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
    Location location = new Location();
    String link = '';
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;

      if (numbers.isEmpty) {
        setState(() {
          prefs.setBool("alerted", false);
          alerted = false;
        });
        return Fluttertoast.showToast(
          msg: 'No Contacts Found!',
          backgroundColor: Colors.red,
        );
      } else {
        //var coordinates =
        //    Coordinates(currentLocation.latitude, currentLocation.longitude);
        //var addresses =
        //    await Geocoder.local.findAddressesFromCoordinates(coordinates);
        // var first = addresses.first;
        String li =
            "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
        if (isAlert) {
          link = "Help Me! SOS \n$li";
        } else {
          Fluttertoast.showToast(
              msg: "Contacts are being notified about false SOS.");
          link = "I am safe, track me here\n$li";
        }

        for (int i = 0; i < numbers.length; i++) {
          sendSMS(numbers[i].split("***")[1], link);
        }
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
      sendAlertSMS(false);
      _pinPutController.clear();
      _pinPutFocusNode.unfocus();
    } else {
      Fluttertoast.showToast(
        msg: 'Wrong Pin! Please try again',
      );
    }
  }
}

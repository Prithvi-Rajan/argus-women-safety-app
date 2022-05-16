import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:womensafteyhackfair/Services/utility_service.dart';
import 'package:womensafteyhackfair/constants.dart';
import 'dart:async';
import '../theme.dart';

class ViewLocation extends StatefulWidget {
  final String uid;
  static const String routeName = "/viewLocation";
  const ViewLocation({Key key, this.uid}) : super(key: key);

  @override
  State<ViewLocation> createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  LatLng currentPosition;
  bool firstSnapshot = true;
  final Completer<GoogleMapController> _controller = Completer();
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 14.4746,
  );

  void updateCameraPosition(LatLng pos) async {
    _markers.add(Marker(
      markerId: const MarkerId('sos'),
      position: pos,
    ));

    print("Markers: ${_markers.length}");
    CameraPosition newPosition = CameraPosition(
      target: pos,
      zoom: 18,
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    // if (mounted) {
    //   setState(() {});
    // }
  }

  final Set<Marker> _markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(appName, style: const TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          backgroundColor: themeColor,
          child: const Icon(
            Icons.location_on,
          ),
          onPressed: () {
            updateCameraPosition(currentPosition);
          }),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  Map<String, dynamic> data = snapshot.data.data();
                  currentPosition = LatLng(data['latitude'], data['longitude']);
                  if (firstSnapshot) {
                    firstSnapshot = false;
                    updateCameraPosition(currentPosition);
                  }
                }

                return Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _kGooglePlex,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: _markers,
                        zoomControlsEnabled: false,
                      ),
                    ),
                    userModel(snapshot),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget userModel(AsyncSnapshot<dynamic> snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator.adaptive();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    String timeString;
    String batteryPercent;
    Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>;

    Timestamp timestamp = data['timestamp'];
    if (timestamp != null) {
      timeString = parseTimeStamp(timestamp.toDate());
    }
    batteryPercent = data['batteryPercent'] != null
        ? data['batteryPercent'].toString()
        : batteryPercent;
    String name = data['name'] ?? '';
    String phoneNumber = data['phoneNumber'] ?? '';

    return Container(
      // height: screenHeight * 0.3,
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          // color: Colors.white,
          color: themeColor.withAlpha(175),
          // border: Border(
          //   top: BorderSide(width: 1, color: Colors.grey),
          // ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5))),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              foregroundImage: NetworkImage(data['photoUrl']),
              backgroundColor: themeColor.withAlpha(100),
              radius: screenWidth * 0.15,
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              height: screenHeight * 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 24),
                            ),
                            Text(
                              phoneNumber,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w100),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            BatteryIndicator(
                              size: 18,
                              percentNumSize: 14.0,
                              ratio: 2.25,
                              colorful: true,
                              showPercentNum: true,
                              style: BatteryIndicatorStyle.skeumorphism,
                              batteryFromPhone: false,
                              batteryLevel: data['batteryPercent'],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Text("Updated at: $timeString"),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ]),
    );
  }
}

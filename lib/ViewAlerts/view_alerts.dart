import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../ViewLocation/view_location.dart';
import '../theme.dart';

class ViewAlerts extends StatefulWidget {
  static const String routeName = '/view_alerts';
  const ViewAlerts({Key key}) : super(key: key);

  @override
  State<ViewAlerts> createState() => _ViewAlertsState();
}

class _ViewAlertsState extends State<ViewAlerts> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _notificationStream =
      FirebaseFirestore.instance
          .collection('notifications')
          .where('to', arrayContains: FirebaseAuth.instance.currentUser.uid)
          .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: StreamBuilder(
          stream: _notificationStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data.docs[index].data();
                return Container(
                    padding: const EdgeInsets.all(8.0),
                    child: alertWidget(data['from'], data['sos']));
              },
            );
          }),
    );
  }

  Widget alertWidget(String from, bool isSos) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(from)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            );
          }
          var data = snapshot.data.data();
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                foregroundColor: themeColor.withOpacity(0.5),
                foregroundImage: NetworkImage(data['photoUrl']),
              ),
              title: Text(data['name']),
              subtitle: Text(data['phoneNumber']),
              trailing: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data['alert'] ? Colors.red : Colors.green,
                ),
              ),
              tileColor: isSos ? Colors.red.shade100 : Colors.green.shade100,
              onTap: () {
                if (data['alert']) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewLocation(uid: from),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(msg: 'SOS alert ended!');
                }
              },
            ),
          );
        });
  }
}

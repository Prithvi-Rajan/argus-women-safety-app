import 'package:flutter/material.dart';
import 'package:womensafteyhackfair/Dashboard/Settings/SettingsScreen.dart';
import 'package:womensafteyhackfair/ViewAlerts/view_alerts.dart';
import 'package:womensafteyhackfair/constants.dart';

class DashAppbar extends StatelessWidget {
  final Function getRandomInt;
  final int quoteIndex;
  const DashAppbar({Key key, this.getRandomInt, this.quoteIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        sweetSayings[quoteIndex][0],
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      subtitle: GestureDetector(
        onTap: () {
          getRandomInt(true);
        },
        child: Text(
          sweetSayings[quoteIndex][1],
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.06),
        ),
      ),
      trailing: SizedBox(
        width: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewAlerts()));
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.notification_important_outlined,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    "assets/settings.png",
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

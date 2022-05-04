import 'package:flutter/material.dart';
// import 'package:timelines/timelines.dart';
import 'package:womensafteyhackfair/Dashboard/Settings/AboutCard.dart';
import 'package:womensafteyhackfair/constants.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "About Us",
              style: TextStyle(color: Colors.black, fontSize: 26),
            ),
            SizedBox(
              width: 10,
            ),
            Image.asset(
              "assets/information.png",
              height: 26,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
      ),
      body: ListView(
        children: [
          AboutCard(
            asset: "logo",
            desc:
                """${appName} is a vigilant mobile application that enables the user to stay connected with the ones who care! It gives the user an option to share live location to concerned people through SOS alerts and enables the user to access emergency services. Be a witness of the unfortunate occurring incident and call for help. It is your personal companion.""",
            subtitle: "You Deserve to be safe!",
            title: appName,
            sizeFactor: 1.8,
          ),
         
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  indent: 10,
                  endIndent: 10,
                ),
              ),
              Text("2022 v1.01"),
              Expanded(
                child: Divider(
                  indent: 10,
                  endIndent: 10,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  showLicences(context) {
    showAboutDialog(
        context: context,
        applicationVersion: "1.0.0",
        applicationIcon: Image.asset(
          "assets/logo.png",
          height: 40,
        ),
        applicationName: appName,
        applicationLegalese:
            "GDSC CUI is providing with a solution to female’s problems, an entirely userfriendly app and a need of the hour, aiming to connect you to the ones who care for you!");
  }
}

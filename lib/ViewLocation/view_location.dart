import 'package:flutter/material.dart';

class ViewLocation extends StatefulWidget {
  final String uid;
  static const String routeName = "/viewLocation";
  const ViewLocation({Key key, this.uid}) : super(key: key);

  @override
  State<ViewLocation> createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  @override
  Widget build(BuildContext context) {
    final String uid = widget.uid;
    return Scaffold(
      body: Center(
        child: Text(uid ?? 'No uid'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({ Key? key }) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("this is view"),
    );
  }
}
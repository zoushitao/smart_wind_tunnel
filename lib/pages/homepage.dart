import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body: Center(
            child: Center(
                child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.transparent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ))));
  }
}

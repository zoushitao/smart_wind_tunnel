import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 10,
          child: ListView(
            children: [
              SizedBox(
                height: 400,
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MonitorWidget(),
                    )),
              ),
              SizedBox(
                height: 400,
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MonitorWidget(),
                    )),
              )
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

class MonitorWidget extends StatefulWidget {
  const MonitorWidget({Key? key}) : super(key: key);

  @override
  _MonitorWidgetState createState() => _MonitorWidgetState();
}

class _MonitorWidgetState extends State<MonitorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text("ok"));
  }
}

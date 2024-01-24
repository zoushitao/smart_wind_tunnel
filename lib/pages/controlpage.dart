import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
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
                      child: ModeSettingsWidget(),
                    )),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

//main content
class ModeSettingsWidget extends StatefulWidget {
  const ModeSettingsWidget({super.key});

  @override
  State<ModeSettingsWidget> createState() => _ModeSettingsWidgetState();
}

class _ModeSettingsWidgetState extends State<ModeSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 选项卡的数量
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save'),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // 处理返回按钮点击事件
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Even Mode',
                icon: Icon(Icons.tab),
              ),
              Tab(
                text: 'Tab 2',
                icon: Icon(Icons.tab),
              ),
              Tab(
                text: 'Tab 3',
                icon: Icon(Icons.tab),
              ),
              Tab(
                text: 'Tab 4',
                icon: Icon(Icons.tab),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 第一个选项卡的内容
            EvenModeView(),
            // 第二个选项卡的内容
            GustModeView(),
            // 第三个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 3 Content'),
              ),
            ),
            // 第四个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 4 Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EvenModeView extends StatefulWidget {
  const EvenModeView({Key? key}) : super(key: key);

  @override
  _EvenModeViewState createState() => _EvenModeViewState();
}

class _EvenModeViewState extends State<EvenModeView> {
  double _evenSliderValue = 0.0;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 10),
        const ListTile(
            //leading: Icon(Icons.pentagon),
            title: Text("Tips"),
            subtitle: Text("s is ")),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Value : "),
            Expanded(
                child: Slider(
              value: _evenSliderValue,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: 'Value: ${_evenSliderValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _evenSliderValue = newValue;
                  //do something else
                });
              },
            )),
          ],
        )
      ],
    );
  }
}

class GustModeView extends StatefulWidget {
  const GustModeView({Key? key}) : super(key: key);

  @override
  _GustModeViewState createState() => _GustModeViewState();
}

class _GustModeViewState extends State<GustModeView> {
  double _gustUpperValue = 0.0;
  double _gustLowerValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 10),
        const ListTile(
            leading: Icon(Icons.pentagon),
            title: Text("Tips"),
            subtitle: Text("s is ")),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Value : "),
            Expanded(
                child: Slider(
              value: _gustUpperValue,
              min: 0.0,
              max: 100.0,
              divisions: 5,
              label: 'Value: ${_gustUpperValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustUpperValue = newValue;
                  //Do something Here
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Value : "),
            Expanded(
                child: Slider(
              value: _gustLowerValue,
              min: 0.0,
              max: 100.0,
              divisions: 5,
              label: 'Value: ${_gustLowerValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustLowerValue = newValue;
                  //Do something Here
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }
}

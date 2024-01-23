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
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(flex: 8, child: ModeSettings()),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}

class ModeSettings extends StatefulWidget {
  const ModeSettings({super.key});

  @override
  State<ModeSettings> createState() => _ModeSettingsState();
}

class _ModeSettingsState extends State<ModeSettings> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 选项卡的数量
      child: Scaffold(
        appBar: AppBar(
          title: Text('TabBar Demo'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Tab 1',
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 第一个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 1 Content'),
              ),
            ),
            // 第二个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 2 Content'),
              ),
            ),
            // 第三个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 3 Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
//import providers
import '/providers/arduino_provider.dart';
import 'package:provider/provider.dart';

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
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(children: const [
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Right Arduino Device:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 200,
                child: ArduinoStatusCard(),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 400,
                child: ControlPad(),
              ),
            ]),
          ),
        ),
        const VerticalDivider(
          color: Colors.grey,
          thickness: 1,
          indent: 20,
          endIndent: 20,
          width: 10,
        ),
        // ignore: prefer_const_constructors
        Expanded(
          flex: 4,
          child: Padding(
              padding: EdgeInsets.fromLTRB(80, 20, 80, 0),
              child: MonitorWidget()),
        ),
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
  List<Widget> _cells = [];
  void _contructCells() {
    for (int i = 0; i < 1600; i++) {
      _cells.add(const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _contructCells();
    return _generateGridView();
  }

  GridView _generateGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 40, // 每行显示的列数
        crossAxisSpacing: 3.0, // 列之间的间距
        mainAxisSpacing: 3.0, // 行之间的间距
        childAspectRatio: 1.0, // 宽高比例为1:1
      ),
      //限制每个item的大小
      itemCount: _cells.length,
      physics: const NeverScrollableScrollPhysics(), // 关闭滚动功能
      itemBuilder: (BuildContext context, int index) {
        return _cells[index];
      },
    );
  }
}

class ArduinoStatusCard extends StatelessWidget {
  const ArduinoStatusCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 221, 220, 220),
              Color.fromARGB(255, 179, 178, 178)
            ],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.computer,
              color: Colors.black,
            ),
            title: Text(
              'Status',
              textAlign: TextAlign.left,
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            subtitle: Text('see arduino status',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black)),
            onTap: null,
          ),
          connectionSuccessListTile(),
        ],
      ),
    );
  }

  ListTile connectionSuccessListTile() {
    return const ListTile(
      leading: Icon(
        Icons.check,
        color: Color.fromARGB(255, 20, 145, 24),
      ),
      title: Text(
        'Connection',
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color.fromARGB(255, 20, 145, 24)),
      ),
      subtitle: Text('Success',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 20, 145, 24))),
      onTap: null,
    );
  }

  ListTile connectionFailListTile() {
    return const ListTile(
      leading: Icon(
        Icons.close,
        color: Color.fromARGB(255, 198, 21, 21),
      ),
      title: Text(
        'Connection',
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color.fromARGB(255, 198, 21, 21)),
      ),
      subtitle: Text('Not Connected',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 198, 21, 21))),
      onTap: null,
    );
  }
}

class ControlPad extends StatefulWidget {
  const ControlPad({
    super.key,
  });

  @override
  State<ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<ControlPad> {
  // Combo Box
  final List<Widget> _modeComboBox = <Widget>[
    const PredefinedModeSelection(),
    const Text("ok"),
    const Text("data")
  ];
  int? _selectedPattern = 0;

  final List<String> _patternList = ["Predefined", "Demonstration", "Script"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 224, 222, 225),
              Color.fromARGB(255, 192, 166, 192)
            ],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.padding,
              color: Colors.black,
            ),
            title: Text(
              'Control Panel',
              textAlign: TextAlign.left,
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            subtitle: Text(
                'Configure your mode here and press "launch" to start.',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black)),
            onTap: null,
          ),
          Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(
              _patternList.length,
              (int index) {
                return ChoiceChip(
                  label: Text(_patternList[index]),
                  selected: _selectedPattern == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPattern = selected ? index : null;
                    });
                  },
                );
              },
            ).toList(),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 200,
            child:
                _modeComboBox[_selectedPattern == null ? 0 : _selectedPattern!],
          ),
          const Divider(
            color: Colors.grey,
            height: 30,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          OutlinedButton.icon(
            onPressed: () {
              // 按钮按下时的处理逻辑
            },
            icon: const Icon(Icons.rocket), // 图标
            label: const Text('Luanch'), // 标签文本
          )
        ],
      ),
    );
  }
}

enum PredefinedModeEnum { even, gust, wave, sheer }

class PredefinedModeSelection extends StatefulWidget {
  const PredefinedModeSelection({Key? key}) : super(key: key);

  @override
  _PredefinedModeSelectionState createState() =>
      _PredefinedModeSelectionState();
}

class _PredefinedModeSelectionState extends State<PredefinedModeSelection> {
  PredefinedModeEnum? _character = PredefinedModeEnum.even;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Even Mode'),
          leading: Radio<PredefinedModeEnum>(
            value: PredefinedModeEnum.even,
            groupValue: _character,
            onChanged: (PredefinedModeEnum? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Gust Mode'),
          leading: Radio<PredefinedModeEnum>(
            value: PredefinedModeEnum.gust,
            groupValue: _character,
            onChanged: (PredefinedModeEnum? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Wave Mode'),
          leading: Radio<PredefinedModeEnum>(
            value: PredefinedModeEnum.wave,
            groupValue: _character,
            onChanged: (PredefinedModeEnum? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Sheer Mode'),
          leading: Radio<PredefinedModeEnum>(
            value: PredefinedModeEnum.sheer,
            groupValue: _character,
            onChanged: (PredefinedModeEnum? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

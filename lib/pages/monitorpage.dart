import 'dart:async';


import 'package:flutter/material.dart';
//import providers
import '../providers/arduino_provider.dart';
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
                  'Status View',
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
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 200,
                child: MonitorAppearance(),
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
          child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ColorBarIlustration(),
                  ),
                  Expanded(flex: 10, child: MonitorWidget()),
                ],
              )),
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

final List<Color> _blueColors = [
  Colors.blue.shade50,
  Colors.blue.shade100,
  Colors.blue.shade200,
  Colors.blue.shade300,
  Colors.blue.shade400,
  Colors.blue.shade500,
  Colors.blue.shade600,
  Colors.blue.shade700,
  Colors.blue.shade800,
  Colors.blue.shade900
];

final List<Color> _greenColors = [
  Colors.green.shade50,
  Colors.green.shade100,
  Colors.green.shade200,
  Colors.green.shade300,
  Colors.green.shade400,
  Colors.green.shade500,
  Colors.green.shade600,
  Colors.green.shade700,
  Colors.green.shade800,
  Colors.green.shade900,
];

final List<Color> _yellowColors = [
  Colors.yellow.shade50,
  Colors.yellow.shade100,
  Colors.yellow.shade200,
  Colors.yellow.shade300,
  Colors.yellow.shade400,
  Colors.yellow.shade500,
  Colors.yellow.shade600,
  Colors.yellow.shade700,
  Colors.yellow.shade800,
  Colors.yellow.shade900,
];

final List<Color> _purpleColors = [
  Colors.purple.shade50,
  Colors.purple.shade100,
  Colors.purple.shade200,
  Colors.purple.shade300,
  Colors.purple.shade400,
  Colors.purple.shade500,
  Colors.purple.shade600,
  Colors.purple.shade700,
  Colors.purple.shade800,
  Colors.purple.shade900,
];

final List<Color> _redColors = [
  Colors.red.shade50,
  Colors.red.shade100,
  Colors.red.shade200,
  Colors.red.shade300,
  Colors.red.shade400,
  Colors.red.shade500,
  Colors.red.shade600,
  Colors.red.shade700,
  Colors.red.shade800,
  Colors.red.shade900,
];

class _MonitorWidgetState extends State<MonitorWidget> {
  final Color baseColor = Colors.blue;

  Color pwmToColor(List<Color> baseColor, int val) {
    if (val < 0) {
      return Colors.white;
    } else {
      var temp = val.toDouble() / 4095.0 * baseColor.length;
      val = temp.toInt();
      try {
        return baseColor[val];
      } catch (err) {
        return baseColor.last;
      }
    }
  }

  final List<Color> blueGradient = [Colors.blue[100]!, Colors.pink[100]!];
  final List<Widget> _cells = [];

  void _contructCells(BuildContext context) {
    _cells.clear();
    //Construc cells according to provider
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    late List<Color> colorScheme;
    switch (arduinoModel.currentColorScheme) {
      case "blue":
        colorScheme = _blueColors;
      case "green":
        colorScheme = _greenColors;
      case "yellow":
        colorScheme = _yellowColors;
      case "purple":
        colorScheme = _purpleColors;
      case "red":
        colorScheme = _redColors;
    }
    var matrix = arduinoModel.virtualArduino.matrix;
    // 获取矩阵的行数和列数
    int numRows = matrix.length;
    int numCols = matrix[0].length;
    // 迭代遍历矩阵
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        Color cellColor = pwmToColor(colorScheme, matrix[i][j]);
        _cells.add(DecoratedBox(
          decoration: BoxDecoration(
            color: cellColor,
          ),
          child: null,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _contructCells(context);
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

    //render connection success interface
    ListTile connectionStatus = arduinoModel.isConnected
        ? connectionSuccessListTile()
        : connectionFailListTile();

    ListTile runningStatus = arduinoModel.isRunning
        ? runningListTile(context)
        : notRunningListTile(context);

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
          connectionStatus,
          runningStatus
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

  ListTile runningListTile(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    String pattern = arduinoModel.currentPattern;
    String mode = arduinoModel.currentPredefinedMode;
    late String prompt;
    if (pattern == "predefined") {
      prompt = "$pattern : $mode";
    } else {
      prompt = pattern;
    }

    return ListTile(
      leading: const Icon(
        Icons.wind_power,
        color: Colors.green,
      ),
      title: const Text(
        'Running',
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.green),
      ),
      subtitle: Text(prompt,
          style: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.green)),
      onTap: null,
    );
  }

  ListTile notRunningListTile(BuildContext context) {
    return const ListTile(
      leading: Icon(
        Icons.pause,
        color: Color.fromARGB(255, 219, 143, 29),
      ),
      title: Text(
        'Not Running',
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color.fromARGB(255, 219, 143, 29)),
      ),
      subtitle: Text('Paused',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 219, 143, 29))),
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
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    _selectedPattern = _patternList.indexOf(arduinoModel.currentPattern);
    print(arduinoModel.currentPattern);
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
              Icons.gif_box_sharp,
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
                      _selectedPattern = selected ? index : index;
                      //update pattern

                      arduinoModel
                          .updatePattern(_patternList[_selectedPattern!]);
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
              try {
                arduinoModel.launch();
              } catch (e) {
                _showLaunchErrorDialog(context, e as String);
              }
            },
            icon: const Icon(Icons.rocket), // 图标
            label: const Text('Luanch'), // 标签文本
          )
        ],
      ),
    );
  }

  void _showLaunchErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('ok...let me fix that'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
  static const List<String> _predifinedModeList = [
    "even",
    "gust",
    "sheer",
    'wave'
  ];

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);

    switch (arduinoModel.currentPredefinedMode) {
      case "even":
        _character = PredefinedModeEnum.even;
      case "gust":
        _character = PredefinedModeEnum.gust;
      case "sheer":
        _character = PredefinedModeEnum.sheer;
      case "wave":
        _character = PredefinedModeEnum.wave;
    }

    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Even Mode'),
          leading: Radio<PredefinedModeEnum>(
            value: PredefinedModeEnum.even,
            groupValue: _character,
            onChanged: (PredefinedModeEnum? value) {
              setState(() {
                switch (value) {
                  case null:
                    ;
                  case PredefinedModeEnum.even:
                    arduinoModel.updatePredifinedMode('even');
                  case PredefinedModeEnum.gust:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('gust');
                  case PredefinedModeEnum.wave:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('wave');
                  case PredefinedModeEnum.sheer:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('sheer');
                }
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
                switch (value) {
                  case null:
                    ;
                  case PredefinedModeEnum.even:
                    arduinoModel.updatePredifinedMode('even');
                  case PredefinedModeEnum.gust:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('gust');
                  case PredefinedModeEnum.wave:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('wave');
                  case PredefinedModeEnum.sheer:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('sheer');
                }
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
                switch (value) {
                  case null:
                    ;
                  case PredefinedModeEnum.even:
                    arduinoModel.updatePredifinedMode('even');
                  case PredefinedModeEnum.gust:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('gust');
                  case PredefinedModeEnum.wave:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('wave');
                  case PredefinedModeEnum.sheer:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('sheer');
                }
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
                switch (value) {
                  case null:
                    ;
                  case PredefinedModeEnum.even:
                    arduinoModel.updatePredifinedMode('even');
                  case PredefinedModeEnum.gust:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('gust');
                  case PredefinedModeEnum.wave:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('wave');
                  case PredefinedModeEnum.sheer:
                    // TODO: Handle this case.
                    arduinoModel.updatePredifinedMode('sheer');
                }
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class MonitorAppearance extends StatefulWidget {
  const MonitorAppearance({Key? key}) : super(key: key);

  @override
  _MonitorAppearanceState createState() => _MonitorAppearanceState();
}

class _MonitorAppearanceState extends State<MonitorAppearance> {
  late List<String> _colorList = [];
  String? _selectedColor;
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    _colorList = arduinoModel.colorList;
    _selectedColor = arduinoModel.currentColorScheme;
    late List<Color> colorScheme;
    switch (arduinoModel.currentColorScheme) {
      case "blue":
        colorScheme = _blueColors;
      case "green":
        colorScheme = _greenColors;
      case "yellow":
        colorScheme = _yellowColors;
      case "purple":
        colorScheme = _purpleColors;
      case "red":
        colorScheme = _redColors;
    }
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme[1], colorScheme[4]],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.looks,
              color: Colors.black,
            ),
            title: Text(
              'Appearance Settings',
              textAlign: TextAlign.left,
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            subtitle: Text(
                'change the color and the size of the demonstration in the right',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black)),
            onTap: null,
          ),
          const SizedBox(height: 20),
          DropdownMenu<String>(
            initialSelection: _colorList.first,
            label: const Text('Color Theme'),
            leadingIcon: const Icon(Icons.color_lens),
            requestFocusOnTap: true,
            onSelected: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                _selectedColor = value ?? _colorList.first;
                arduinoModel.setColorScheme(value ?? _colorList.first);
              });
            },
            dropdownMenuEntries:
                _colorList.map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(
                  value: value,
                  label: value,
                  leadingIcon: const Icon(Icons.color_lens));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ColorBarIlustration extends StatefulWidget {
  const ColorBarIlustration({Key? key}) : super(key: key);

  @override
  _ColorBarIlustrationState createState() => _ColorBarIlustrationState();
}

class _ColorBarIlustrationState extends State<ColorBarIlustration> {
  @override
  Widget build(BuildContext context) {
    List<Widget> colorBarList = [];
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    late List<Color> colorScheme;
    switch (arduinoModel.currentColorScheme) {
      case "blue":
        colorScheme = _blueColors;
      case "green":
        colorScheme = _greenColors;
      case "yellow":
        colorScheme = _yellowColors;
      case "purple":
        colorScheme = _purpleColors;
      case "red":
        colorScheme = _redColors;
    }
    int i = 0;
    int step = 100 % colorScheme.length;
    for (var color in colorScheme) {
      Row row = Row(
        children: [
          Container(width: 20, child: Text("$i")),
          const SizedBox(width: 8),
          Container(
            height: 16,
            width: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
              ),
              child: null,
            ),
          )
        ],
      );
      colorBarList.add(row);
      i += 10;
    }

    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {
            _showFullscreenDialog(context);
          },
        ),
        const SizedBox(
          height: 50,
        ),
        const Text("PWM(%)"),
        const SizedBox(
          height: 10,
        ),
        ...colorBarList
      ],
    );
  }

  void _showFullscreenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 640, width: 600, child: MonitorWidget()),
                ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
      //fullscreenDialog: true,
    );
  }
}

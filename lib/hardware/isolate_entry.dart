import 'dart:isolate';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hardware_interface.dart';
import 'dart:convert';
//childIsolate main

//Gloabls

final HardwareInterface _realArduino = HardwareInterface();

Map? _config;
String? _currentMode;

//ports
late SendPort _sendPort;

//main
Future<void> childIsolateEntry(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  _sendPort = sendPort; // 向主 Isolate 发送子 Isolate 的接收端口
  receivePort.listen((message) {
    //Process instructions received

    try {
      print(message);
      _handleInstruction(message);
    } catch (e) {
      print(e);
    }
  });

  //Runners
  GustModeRunner gustModeRunner = GustModeRunner();

  int i = 0;
  while (true) {
    //check before run

    //do it
    await Future.delayed(const Duration(milliseconds: 1000), () {
      //_sendPort.send("hello from isolate $i");
    });

    i++;
    print("ok $i:$_currentMode");
    switch (_currentMode) {
      case null:
        continue;
      case 'gust':
        try {
          gustModeRunner.run();
        } catch (e) {
          print(e);
        }
    }
  }
}

Future<bool> _loop(int count) async {
  bool clearCount = false;
  await Future.delayed(const Duration(seconds: 1), () {
    //print('Isolate is crazy $count');
  });

  //loop
  return clearCount;
}

void _handleInstruction(String message) {
  late Map jsonMap;
  try {
    jsonMap = jsonDecode(message);
    // 处理转换成功的情况
  } catch (e) {
    // 处理转换失败的情况
    print('Error: $e');
  }
  if (!jsonMap.containsKey("instruction")) {
    //error because $key "instruction" is not contained
    print("eror");
    return;
  }
  switch (jsonMap['instruction']) {
    case 'connect':
      _connect(jsonMap);
    case 'disconnect':
      _disconnect(jsonMap);
    case 'configUpdate':
      _updateConfig(jsonMap);
    case 'launch':
      _launch(jsonMap);
  }
}

void _connect(Map message) {
  //handle error here
  if (message['leftPort'] == message['rightPort']) {
    print("isolate:error when connecting");
    return;
  }
  try {
    _realArduino.connect(
        leftDevice: message['leftPort'], rightDevice: message['rightPort']);
  } catch (e) {
    print(e);
  }
}

void _disconnect(Map message) {
  _realArduino.disconnect();
  print("disconeccted");
}

void _updateConfig(Map message) {
  _config = message['config'];
  Map? gustConfig = _config?['gust'];

  //update gust mode configure
  GustModeRunner gustModeRunner = GustModeRunner();
  print("update config : $gustConfig");
  gustModeRunner.init(
      upperLimit: gustConfig!['upperLimit'],
      lowerLimit: gustConfig['lowerLimit'],
      periodMs: gustConfig['period']);

  //update wave mode configure
}

void _launch(Map message) {
  print("launched");
  String mode = message['mode'];
  _currentMode = mode;
}

void _setAll(int val) {
  Map instruction = {'instruction': 'setAll', 'value': val};
  _realArduino.setAll(val);
  _sendPort.send(json.encode(instruction));
}

void _setRow(int val, int row) {
  if (val >= 4095 || val <= 0) {
    return;
  }

  if (row > 39 || row < 0) {
    return;
  }
  Map instruction = {'instruction': 'setRow', 'value': val, 'rowID': row};
  _sendPort.send(json.encode(instruction));
}

void _setCol(int val, int col) {
  if (val >= 4095 || val <= 0) {
    return;
  }

  if (col > 39 || col < 0) {
    return;
  }
  Map instruction = {'instruction': 'setCol', 'value': val, 'colID': col};
  _sendPort.send(json.encode(instruction));
}

//SingleExamplemode
class GustModeRunner {
  static final GustModeRunner _singleton = GustModeRunner._internal();

  factory GustModeRunner() {
    return _singleton;
  }

  GustModeRunner._internal();

  static double step = 0.0, xval = 0.0;
  static double lower = 0, upper = 4095;
  static int delay_ms = 100;
  static bool _initialized = false;

  
  void init(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {
    step = 2.0 * math.pi / (periodMs.toDouble() / delay_ms.toDouble());
    lower = lowerLimit.toDouble();
    upper = upperLimit.toDouble();
    _initialized = true;
    print("init gust");
  }

  void run() {
    xval += step;
    double value =
        math.sin(xval) * (upper - lower) / 2.0 + (upper + lower) / 2.0;
    _setAll(value.toInt());
    Future.delayed(Duration(milliseconds: delay_ms), () {
      print('延迟操作完成');
    });
    print("Run value:$value");
  }
}

class WaveModeRunner {
  static final WaveModeRunner _singleton = WaveModeRunner._internal();

  factory WaveModeRunner() {
    return _singleton;
  }

  WaveModeRunner._internal();
  int rowSettingDelay = 10; //unit:milliseond

  List<int> waveList = <int>[];
  void init(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {}
}

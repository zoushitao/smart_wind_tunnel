import 'dart:isolate';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hardware_interface.dart';
import 'dart:convert';
import 'dart:developer';
//childIsolate main

//Gloabls

final HardwareInterface _realArduino = HardwareInterface();
GustModeRunner gustModeRunner = GustModeRunner();
WaveModeRunner waveModeRunner = WaveModeRunner();
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
      print("IN ISOLATE: $message");
      _handleInstruction(message);
    } catch (e) {
      log(e as String);
    }
  });

  //Runners

  //initialization

  while (true) {
    switch (_currentMode) {
      case null:
        await Future.delayed(Duration(milliseconds: 1000), () {
          print('ISOLATE:idle now');
        });
        continue;
      case 'gust':
        try {
          await gustModeRunner.run();
        } catch (e) {
          print(e);
        }
      case 'wave':
        try {
          await waveModeRunner.run();
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
    print('Error in _handleInstruction : $e');
  }
  if (!jsonMap.containsKey("instruction")) {
    //error because $key "instruction" is not contained
    print("eror");
    return;
  }
  print(jsonMap);
  switch (jsonMap['instruction']) {
    case 'connect':
      _connect(jsonMap);
    case 'disconnect':
      _disconnect(jsonMap);
    case 'configUpdate':
      _updateConfig(jsonMap);
    case 'launch':
      _launch(jsonMap);
    case 'stop':
      _stop(jsonMap);
  }
}

void _stop(Map message) {
  _setAll(0);
  _currentMode = null;
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
  _currentMode = 'idle';
  _realArduino.disconnect();
  print("disconeccted");
}

void _updateConfig(Map message) {
  _config = message['config'];

  //update gust mode configure
  Map? gustModeConfig = _config?['gust'];

  gustModeRunner.init(
      upperLimit: gustModeConfig!['upperLimit'],
      lowerLimit: gustModeConfig['lowerLimit'],
      periodMs: gustModeConfig['period']);
  //update wave mode configure
  Map? waveModeConfig = _config?['wave'];

  waveModeRunner.init(
      lowerLimit: waveModeConfig!['lowerLimit'],
      upperLimit: waveModeConfig!['upperLimit'],
      periodMs: waveModeConfig['period'],
      waveLength: waveModeConfig['waveLength'],
      orientation: waveModeConfig['orientation']);
  print("update called,wave config : $waveModeConfig");
}

void _launch(Map message) {
  String mode = message['mode'];
  print("launched,mode:$mode");
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
  _realArduino.setRow(row, val);

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
  _realArduino.setCol(col, val);
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
  static const int delay_ms = 200;
  static bool _initialized = false;

  void init(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {
    step = 2.0 * math.pi / (periodMs.toDouble() / delay_ms.toDouble());
    lower = lowerLimit.toDouble();
    upper = upperLimit.toDouble();
    _initialized = true;
  }

  Future<void> run() async {
    xval += step;
    double value =
        math.sin(xval) * (upper - lower) / 2.0 + (upper + lower) / 2.0;
    _setAll(value.toInt());
    await Future.delayed(Duration(milliseconds: delay_ms), () {
      print('gust is running');
    });
    //print("Run value:$value");
  }
}

class WaveModeRunner {
  static final WaveModeRunner _singleton = WaveModeRunner._internal();

  factory WaveModeRunner() {
    return _singleton;
  }

  WaveModeRunner._internal();
  static const int rowSettingDelay = 10; //unit:milliseond
  static String direction = 'row';
  // ignore: non_constant_identifier_names
  static double space_step = 0.0, time_step = 0.0, upper = 4095.0, lower = 0.0;
  static bool _isInitialized = false;
  static int time_count = 0;

  void init(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs,
      required int waveLength,
      required String orientation}) {
    if (orientation != 'row' && orientation != 'column') {
      print("fail to init wave,orientation:$orientation");

      return;
    }
    lower = lowerLimit.toDouble();
    upper = upperLimit.toDouble();
    time_step =
        2 * math.pi / (periodMs.toDouble() / (rowSettingDelay.toDouble() * 40));
    space_step = 2 * math.pi / (waveLength.toDouble());

    _isInitialized = true;

    print("init ok");
  }

  Future<void> run() async {
    if (!_isInitialized) {
      await Future.delayed(Duration(milliseconds: 2000), () {
        print("wave not init");
        print("upper:$upper,lower:$lower");
      });
      //print("wave not init");
      return;
    }
    time_count += 1;
    if (direction == 'row') {
      for (int i = 0; i < 40; i++) {
        double val = (upper - lower) *
                math.sin(space_step * i + time_step * time_count.toDouble()) /
                2 +
            (upper + lower) / 2;
        _setRow(val.toInt(), i);
        await Future.delayed(Duration(milliseconds: rowSettingDelay), () {
          //print("row mode");
        });
      }
      return;
    }
    if (direction == 'column') {
      for (int i = 0; i < 40; i++) {
        double val = (upper - lower) *
                math.sin(space_step * i + time_step * time_count.toDouble()) /
                2 +
            (upper + lower) / 2;
        _setCol(val.toInt(), i);
        await Future.delayed(Duration(milliseconds: rowSettingDelay), () {
          //print("column mode");
        });
      }
      return;
    }
  }
}

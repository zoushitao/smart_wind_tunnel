import 'dart:isolate';
import 'real_arduino_interface.dart';
import 'dart:convert';
//childIsolate main

//Gloabls

final RealArduinoInterface _realArduino = RealArduinoInterface();

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

    _handleInstruction(message);
  });

  //Runners
  GustModeRunner gustModeRunner = GustModeRunner();

  int i = 0;
  while (true) {
    //check before run

    //do it
    await Future.delayed(const Duration(seconds: 1), () {
      //_sendPort.send("hello from isolate $i");
    });

    i++;

    switch (_currentMode) {
      case null:
        continue;
      case 'gust':
        gustModeRunner.run();
    }
  }
}

Future<bool> _loop(int count) async {
  bool clearCount = false;
  await Future.delayed(const Duration(seconds: 1), () {
    print('Isolate is crazy $count');
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

  GustModeRunner gustModeRunner = GustModeRunner();
  gustModeRunner.init(
      upperLimit: _config!['upperLimit'],
      lowerLimit: _config!['lowerLimit'],
      periodMs: _config!['period']);

  print("config updated");
  print(_config.toString());
}

void _launch(Map message) {
  String mode = message['mode'];
  _currentMode = mode;
}

void _setAll(int val) {
  Map instruction = {'instruction': 'setAll', 'value': val};
  _sendPort.send(json.encode(instruction));
}

//SingleExamplemode

class GustModeRunner {
  static final GustModeRunner _singleton = GustModeRunner._internal();

  factory GustModeRunner() {
    return _singleton;
  }

  GustModeRunner._internal();

  late int increment;
  late int value;
  late int lower, upper;

  int delay = 100;
  void init(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {
    int steps = periodMs ~/ delay;
    increment = (upperLimit - lowerLimit) ~/ steps;
    value = lowerLimit;
    lower = lowerLimit;
    upper = upperLimit;
  }

  void run() {
    value += increment;
    if (value > 4095 || value > upper) {
      value = upper;
    }
    _setAll(value);
  }
}

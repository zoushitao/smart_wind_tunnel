import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:isolate';
import '../hardware/arduino.dart';
import 'dart:convert';
import 'dart:convert';
//import arduino hardware serial port interface
import '../hardware/real_arduino_interface.dart';

// 用来储存和管理风扇的状态
class VirtualArduinoState {
  late List<List<int>> _matrix;
  //getter
  List<List<int>> get matrix => _matrix;

  VirtualArduinoState() {
    int numRows = 40;
    int numCols = 40;

    _matrix = List.generate(
      numRows,
      (row) => List<int>.filled(numCols, 0),
    );
  }

  void setAll(int val) {
    // 获取矩阵的行数和列数
    int numRows = _matrix.length;
    int numCols = _matrix[0].length;
    // 迭代遍历矩阵
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        _matrix[i][j] = val;
      }
    }
  }
}

class SmartWindProvider extends ChangeNotifier {
  //virtual arduino 用来管理虚拟风扇的数据
  final VirtualArduinoState _virtualArduino = VirtualArduinoState();
  VirtualArduinoState get virtualArduino => _virtualArduino;

  //arduino硬件管理
  final RealArduinoInterface _realArduino = RealArduinoInterface();

  //constants
  static const MAX_VAL = 4095;

  //settings 保存predefined mode的设置
  final Map evenMode = {'value': 0};
  final Map gustMode = {'lowerLimit': 0, 'upperLimit': MAX_VAL, 'period': 30};

  //Connection
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  //Running or paused
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  //Color Scheme
  

  //Mode
  static const List<String> _patternList = [
    "Predefined",
    "Demonstration",
    "Script"
  ];
  static const List<String> _predifinedModeList = [
    "even",
    "gust",
    "sheer",
    'wave'
  ];
  String currentPattern = _patternList[0];
  String currentPredefinedMode = _predifinedModeList[0];

  //serialport
  late List<String> _availablePorts = [];
  List<String> get availablePorts => _availablePorts;
  //记得稍后修改
  String? leftPort, rightPort;

  int _counter = 0;

  int get counter => _counter;
  

  void setLeftSerialPort(String portName) {
    leftPort = portName;
    print("_leftPort:$leftPort");
  }

  void setRightSerialPort(String portName) {
    rightPort = portName;
    print("_rightPort:$rightPort");
  }

  Map acquireDeviceDetail(String portName) {
    //稍后修改
    return _realArduino.acquireDeviceDetail(portName);
  }

  void testSt() {
    _counter++;
    notifyListeners();
  }

  SmartWindProvider() {
    // 初始化函数
    _startChildIsolate();
    print("initializing");

    refreshSerialList();
    print(_availablePorts);
    notifyListeners();
  }

  void refreshSerialList() async {
    try {
      //fake list here
      _availablePorts = _realArduino.availablePorts;
    } catch (err) {
      print('串口错误：$err');
    }
    notifyListeners();
  }

  //connect to serial port and start isolate
  void connect() {
    if (leftPort == null || rightPort == null) {
      print("null");
      print("_leftPort:$leftPort");
      print("_rightPort:$rightPort");
      return;
      //error handling here
    }
    if (leftPort == rightPort) {
      return;
    }
    var instruciton = {
      'instruction': 'connect',
      'leftPort': leftPort,
      'rightPort': rightPort
    };
    var instructionJsonString = jsonEncode(instruciton);
    _commands.send(instructionJsonString);
    //_realArduino.echoTest(leftDevice: _leftPort!, rightDevice: _rightPort!);
    _isConnected = true;
    notifyListeners();
  }

  void disconnect() {
    var instruciton = {
      'instruction': 'disconnect',
    };
    var instructionJsonString = jsonEncode(instruciton);
    _commands.send(instructionJsonString);

    _isConnected = false;
    notifyListeners();
  }

  //Isolate
  late Isolate _childIsolate;
  late SendPort _commands;
  late ReceivePort _responses;
  Future<void> _startChildIsolate() async {
    _responses = ReceivePort();

    _childIsolate = await Isolate.spawn(childIsolateEntry, _responses.sendPort);

    _responses.listen((message) {
      if (message is SendPort) {
        _commands = message;
      } else if (message is String) {
        //handle message from isolate
        handleMessageFromisolate(message);
      } else {
        throw "fucking message is not string";
      }
    });

    // 处理消息来自isolate
  }

  void handleMessageFromisolate(String message) {
    // print(message);
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
      case 'setAll':
        _setAll(jsonMap);
    }
  }

  void _setAll(Map jsonMap) {
    int val = jsonMap['value'];

    _virtualArduino.setAll(val);
    notifyListeners();
  }

  void setEvenMode(int val) {
    evenMode['value'] = val;
    notifyListeners();
  }

  void setGustMode(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {
    gustMode['lowerLimit'] = lowerLimit;
    gustMode['upperLimit'] = upperLimit;
    gustMode['period'] = periodMs;
  }

  void launch() {
    if (!_isConnected) {
      throw "Error : Not Connected";
    }
    if (currentPattern != "Predefined") {
      throw "It's still under development ... choose another one";
    }
    //upload config
    Map config = {'even': evenMode, 'gust': gustMode};
    Map instruction = {'instruction': 'configUpdate', 'config': config};
    String instructionJsonString = json.encode(instruction);
    _commands.send(instructionJsonString);
    //lauch actually
    instruction = {'instruction': 'launch', 'mode': currentPredefinedMode};
    instructionJsonString = json.encode(instruction);
    _commands.send(instructionJsonString);
    _isRunning = true;
    notifyListeners();
  }

  void unlaunch() {
    _isRunning = false;
    notifyListeners();
  }

  void updatePatter(String pattern) {
    if (!_patternList.contains(pattern)) {
      //error handle
      return;
    }
    currentPattern = pattern;

    notifyListeners();
  }

  void updatePredifinedMode(String mode) {
    if (!_predifinedModeList.contains(mode)) {
      //error handle

      return;
    }

    currentPredefinedMode = mode;
  }

  
}

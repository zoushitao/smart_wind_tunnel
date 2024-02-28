import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:isolate';
import '../hardware/arduino.dart';
import 'dart:convert';

//import arduino hardware serial port interface
import '../hardware/real_arduino_interface.dart';

enum SmartWindStatus { paused, running }

enum SmartWindRunningPatterns { predifined, demonstration, script }

enum SmartWindPredefinedMode { even, gust, wave, sheer }

// 用来储存和管理风扇的状态
class VirtualArduinoState {
  late List<List<int>> _matrix;
  //getter
  List<List<int>> get matrix => _matrix;
  SmartWindStatus currentStatus = SmartWindStatus.paused;
  late SmartWindRunningPatterns currentPattern =
      SmartWindRunningPatterns.predifined;
  late SmartWindPredefinedMode currentPredefinedMode =
      SmartWindPredefinedMode.even;

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
  //getters 用来获取虚拟风扇的状态
  SmartWindStatus get currentStatus => _virtualArduino.currentStatus;
  SmartWindRunningPatterns get currentPatterns =>
      _virtualArduino.currentPattern;
  SmartWindPredefinedMode get currentPredefinedMode =>
      _virtualArduino.currentPredefinedMode;

  //arduino硬件管理
  final RealArduinoInterface _realArduino = RealArduinoInterface();

  //constants
  static const MAX_VAL = 4095;

  //settings 保存predefined mode的设置
  final Map evenMpde = {'value': 0};
  final Map gustMode = {'lowerLimit': 0, 'upperLimit': MAX_VAL, 'period': 10};

  //Connection
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  //serialport
  late List<String> _availablePorts = [];
  List<String> get availablePorts => _availablePorts;
  //记得稍后修改
  String? _leftPort, _rightPort;

  int _counter = 0;

  int get counter => _counter;

  void setLeftSerialPort(String portName) {
    _leftPort = portName;
    print("_leftPort:$_leftPort");
  }

  void setRightSerialPort(String portName) {
    _rightPort = portName;
    print("_rightPort:$_rightPort");
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
    if (_leftPort == null || _rightPort == null) {
      print("null");
      print("_leftPort:$_leftPort");
      print("_rightPort:$_rightPort");
      return;
      //error handling here
    }
    if (_leftPort == _rightPort) {
      return;
    }
    var instruciton = {
      'instruction': 'connect',
      'leftPort': _leftPort,
      'rightPort': _rightPort
    };
    var instructionJsonString = jsonEncode(instruciton);
    _childSendPort.send(instructionJsonString);
    //_realArduino.echoTest(leftDevice: _leftPort!, rightDevice: _rightPort!);
    _isConnected = true;
    notifyListeners();
  }

  void disconnect() {
    var instruciton = {
      'instruction': 'disconnect',
    };
    var instructionJsonString = jsonEncode(instruciton);
    _childSendPort.send(instructionJsonString);

    _isConnected = false;
    notifyListeners();
  }

  //Isolate
  late Isolate _childIsolate;
  late SendPort _childSendPort;
  late ReceivePort _childReceivePort;
  Future<void> _startChildIsolate() async {
    _childReceivePort = ReceivePort();
    _childIsolate =
        await Isolate.spawn(childIsolateEntry, _childReceivePort.sendPort);

    _childSendPort = await _childReceivePort.first; // 获取子 Isolate 的发送端口
    //_childSendPort.send('Hello from main Isolate!'); // 向子 Isolate 发送消息
  }

  void setEvenMode(int val) {
    evenMpde['value'] = val;
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
}

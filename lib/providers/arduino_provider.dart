import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:isolate';

//import arduino hardware serial port interface
import 'real_arduino_interface.dart';

enum SmartWindStatus { paused, running }

enum SmartWindRunningPatterns { predifined, demonstration, script }

enum SmartWindPredefinedMode { even, gust, wave, sheer }

// 用来储存和管理风扇的状态
class VirtualArduinoState {
  late List<List<int>> fanSpeedMatrix;
  SmartWindStatus currentStatus = SmartWindStatus.paused;
  late SmartWindRunningPatterns currentPattern =
      SmartWindRunningPatterns.predifined;
  late SmartWindPredefinedMode currentPredefinedMode =
      SmartWindPredefinedMode.even;
}

class SmartWindProvider extends ChangeNotifier {
  //virtual arduino 用来管理虚拟风扇的数据
  VirtualArduinoState _virtualArduino = VirtualArduinoState();
  //getters 用来获取虚拟风扇的状态
  SmartWindStatus get currentStatus => _virtualArduino.currentStatus;
  SmartWindRunningPatterns get currentPatterns =>
      _virtualArduino.currentPattern;
  SmartWindPredefinedMode get currentPredefinedMode =>
      _virtualArduino.currentPredefinedMode;

  //arduino硬件管理
  RealArduinoInterface _realArduino = RealArduinoInterface();

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
    return _realArduino.acquireDeviceDetail(portName);
  }

  void testSt() {
    _counter++;
    notifyListeners();
  }

  void start() {
    notifyListeners();
  }

  SmartWindProvider() {
    // 初始化函数

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

  //打开串口链接Arduino
  void connect() {
    if (_leftPort == null || _rightPort == null) {
      print("null");
      print("_leftPort:$_leftPort");
      print("_rightPort:$_rightPort");
      return;
    }
    _realArduino.echoTest(leftDevice: _leftPort!, rightDevice: _rightPort!);
    _isConnected = true;
    notifyListeners();
  }

  void disconnect() {
    // .....
    _isConnected = false;
    notifyListeners();
  }

  Future<void> startIsolate() async {
    final isolate = await Isolate.spawn(printMessage, 'Hello from Isolate!');
    await Future.delayed(Duration(seconds: 10));
    // 终止 Isolate
    isolate.kill(priority: Isolate.immediate);
  }
}

void printMessage(String message) {
  // 每隔1秒打印一条消息
  Timer.periodic(const Duration(milliseconds: 200), (timer) {
    print(message);
  });
}

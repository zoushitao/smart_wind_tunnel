import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:async';
import 'dart:isolate';

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

  //Connection
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  //serialport
  late List<String> _availablePorts = [];
  List<String> get availablePorts => _availablePorts;
  

  int _counter = 0;

  int get counter => _counter;

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
    _availablePorts = SerialPort.availablePorts;
    notifyListeners();
  }

  //打开串口链接Arduino
  void connectSerial(){
    
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

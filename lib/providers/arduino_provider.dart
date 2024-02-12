import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:async';
import 'dart:isolate';

enum ArduinoSmartWindStatus {
  uninitialized,
  unconnected,
  ready,
  modeEven,
  modeGust
}

class SmartWindProvider extends ChangeNotifier {
  //fan model
  late List<List<int>> fanSpeedMatrix;
  ArduinoSmartWindStatus status = ArduinoSmartWindStatus.uninitialized;
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

class SmartWindSerialInterface {}

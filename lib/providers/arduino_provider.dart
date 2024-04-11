import 'package:flutter/foundation.dart';
import 'package:smart_wind_tunnel/providers/virtual_hardware_state.dart';
import 'dart:async';
import 'dart:isolate';
import '../hardware/isolate_entry.dart';
import 'dart:convert';

//import arduino hardware serial port interface
import '../hardware/hardware_interface.dart';

class SmartWindProvider extends ChangeNotifier {
  //virtual arduino 用来管理虚拟风扇的数据
  final VirtualHardwareState _virtualArduino = VirtualHardwareState();
  VirtualHardwareState get virtualArduino => _virtualArduino;

  //arduino硬件管理
  final HardwareInterface _realArduino = HardwareInterface();

  //constants
  static const MAX_VAL = 4095;

  //settings 保存predefined mode的设置
  final Map evenModeConfig = {'value': 0};
  final Map gustModeConfig = {
    'lowerLimit': 0,
    'upperLimit': MAX_VAL,
    'period': 10000
  };
  final Map waveModeConfig = {
    'lowerLimit': 0,
    'upperLimit': MAX_VAL,
    'waveLength': 20,
    'period': 10000,
    'orientation': 'row'
  };

  //Connection
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  //Running or paused
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  //Color Scheme
  static const List<String> _colorList = [
    "blue",
    "green",
    "yellow",
    "purple",
    "red"
  ];
  List<String> get colorList => _colorList;
  String _currentColorScheme = _colorList.first;
  String get currentColorScheme => _currentColorScheme;

  void setColorScheme(String color) {
    if (!_colorList.contains(color)) {
      return;
    } else {
      _currentColorScheme = color;
    }
    notifyListeners();
  }

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
    refreshSerialList();
    notifyListeners();
  }

  void refreshSerialList() async {
    try {
      //fake list here
      _availablePorts = _realArduino.availablePorts;
    } catch (err) {
      print('串口错误：$err');
    }
    leftPort = _availablePorts[0];
    rightPort = _availablePorts[0];
    notifyListeners();
  }

  //connect to serial port and start isolate
  void connect() {
    if (leftPort == null || rightPort == null) {
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
      case 'setRow':
        _setRow(jsonMap);
      case 'setCol':
        _setCol(jsonMap);
    }
  }

  void _setRow(Map jsonMap) {
    if (!jsonMap.containsKey('rowID')) {
      print('error');
    }
    int val = jsonMap['value'];
    int row = jsonMap['rowID'];
    _virtualArduino.setRow(val, row);
    notifyListeners();
  }

  void _setCol(Map jsonMap) {
    if (!jsonMap.containsKey('colID')) {
      print('error');
    }
    int val = jsonMap['value'];
    int col = jsonMap['colID'];
    _virtualArduino.setCol(val, col);
    notifyListeners();
  }

  void _setAll(Map jsonMap) {
    int val = jsonMap['value'];

    _virtualArduino.setAll(val);
    notifyListeners();
  }

  void setEvenMode(int val) {
    evenModeConfig['value'] = val;
    notifyListeners();
  }

  void setGustMode(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs}) {
    gustModeConfig['lowerLimit'] = lowerLimit;
    gustModeConfig['upperLimit'] = upperLimit;
    gustModeConfig['period'] = periodMs;
  }

  void setWaveMode(
      {required int lowerLimit,
      required int upperLimit,
      required int periodMs,
      required int waveLength,
      required String orientation}) {
    waveModeConfig['lowerLimit'] = lowerLimit;
    waveModeConfig['upperLimit'] = upperLimit;
    waveModeConfig['period'] = periodMs;
    waveModeConfig['waveLength'] = waveLength;
    waveModeConfig['orientation'] = orientation;
    print(waveModeConfig);
  }

  void launch() {
    if (!_isConnected) {
      throw "Error : Not Connected";
    }
    if (currentPattern != "Predefined") {
      throw "It's still under development ... choose another one";
    }
    //upload config
    Map config = {
      'even': evenModeConfig,
      'gust': gustModeConfig,
      'wave': waveModeConfig
    };
    Map instruction = {'instruction': 'configUpdate', 'config': config};
    String instructionJsonString = json.encode(instruction);
    _commands.send(instructionJsonString);
    //lauch actually
    instruction = {'instruction': 'launch', 'mode': currentPredefinedMode};
    instructionJsonString = json.encode(instruction);
    _commands.send(instructionJsonString);
    print(instructionJsonString);

    _isRunning = true;
    notifyListeners();
  }

  void unlaunch() {
    _isRunning = false;
    notifyListeners();
  }

  void updatePattern(String pattern) {
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

  int _selectedPageIndex = 0;
  int get selectedPageIndex => _selectedPageIndex;

  set selectedPageIndex(int val) {
    _selectedPageIndex = val;
    // 在 setter 中可以执行其他逻辑操作
    // 比如触发界面重新构建
    // 或者进行数据验证等
    notifyListeners();
  }

  void stop() {
    //do something to stop the fans
  }
}

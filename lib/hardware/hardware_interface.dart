import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:convert';
import 'dart:typed_data';

class HardwareInterface {
  late SerialPort _leftPort;
  late SerialPort _rightPort;
  //readers
  SerialPortReader? _leftReader;
  SerialPortReader? _rightReader;
  //acquire serial port lists
  List<String> get availablePorts => SerialPort.availablePorts;
  //acquire detail of usb device
  Map acquireDeviceDetail(String portName) {
    final SerialPort port = SerialPort(portName);
    return {
      'Description': port.description,
      'Transport': port.transport,
      'USB Bus': port.busNumber,
      'USB Device': port.deviceNumber,
      'Vendor ID': port.vendorId,
      'Product ID': port.productId,
      'Manufacturer': port.manufacturer,
      'Product Name': port.productName,
      'Serial Number': port.serialNumber,
      'MAC Address': port.macAddress
    };
  }

  Future<void> connect(
      {required String leftDevice, required String rightDevice}) async {
    try {
      _rightPort = SerialPort(rightDevice);
      _leftPort = SerialPort(leftDevice);
      //set baud rate
      //要进行完整的配置更新
      final SerialPortConfig leftCfg = SerialPortConfig();
      leftCfg.baudRate = 115200;
      leftCfg.bits = 8;
      leftCfg.parity = -1;
      leftCfg.stopBits = 1;
      leftCfg.setFlowControl(-1);

      _leftPort.config = leftCfg;

      //
      final SerialPortConfig rightCfg = SerialPortConfig();
      rightCfg.baudRate = 115200;
      rightCfg.bits = 8;
      rightCfg.parity = -1;
      rightCfg.stopBits = 1;
      rightCfg.setFlowControl(-1);
      _rightPort.config = rightCfg;
    } catch (err) {
      print('波特率设置时发生错误：$err');
      return;
    }

    //open serial port
    try {
      _leftPort.openReadWrite();
      _rightPort.openReadWrite();
      _leftReader = SerialPortReader(_leftPort);
      _rightReader = SerialPortReader(_rightPort);

      //left port reader
      int leftBufferIndex = 0;
      Stream<Uint8List> leftUpcomingData = _leftReader!.stream.map((data) {
        return data;
      });
      List<int> leftBuffer = [];
      leftUpcomingData.listen((data) {
        leftBuffer.addAll(data);
        leftBufferIndex += data.length;

        if (leftBufferIndex >= 1) {
          String strBuffer = String.fromCharCodes(leftBuffer);
          print('Left Buffer: $strBuffer');
          leftBufferIndex = 0;
          leftBuffer = [];
          _available = true;
        }
      });

      //right port reader
      int rightBufferIndex = 0;
      Stream<Uint8List> rightUpcomingData = _rightReader!.stream.map((data) {
        return data;
      });
      List<int> rightBuffer = [];
      rightUpcomingData.listen((data) {
        rightBuffer.addAll(data);
        rightBufferIndex += data.length;

        if (rightBufferIndex >= 1) {
          String strBuffer = String.fromCharCodes(rightBuffer);
          print('Right Buffer: $strBuffer');
          rightBufferIndex = 0;
          rightBuffer = [];
          _available = true;
        }
      });
    } catch (err) {
      print('串口错误：$err');
      _leftPort.close();
      _rightPort.close();
    }
  }

  Future<void> disconnect() async {
    //close serial port
    try {
      _leftPort.close();
      _rightPort.close();
      _leftReader?.close();
      _rightReader?.close();
    } catch (e) {
      print('e');
    }
  }

  Future<void> setAll(int val) async {
    if (!(_leftPort.isOpen && _rightPort.isOpen)) {
      print("error when setting all because connection failed");
      return;
    }

    // 将字符串转换为 ASCII 码的 Uint8List 列表

    try {
      String str = 'a:$val';
      print(str);
      List<int> asciiList = [];
      asciiList.addAll(str.codeUnits);
      asciiList.add(10); //添加换行符
      Uint8List bytes = Uint8List.fromList(asciiList);
      //print(bytes);

      _leftPort.write(bytes);

      _rightPort.write(bytes);
    } catch (e) {
      print(e);
    }
    _available = false;
  }

  Future<void> setRow(int row, int val) async {
    if (!(_leftPort.isOpen && _rightPort.isOpen)) {
      print("error when setting all because connection failed");
      return;
    }

    // 将字符串转换为 ASCII 码的 Uint8List 列表

    try {
      String str = 'r:$row,$val';
      List<int> asciiList = [];
      asciiList.addAll(str.codeUnits);
      asciiList.add(10); //添加换行符
      Uint8List bytes = Uint8List.fromList(asciiList);
      //print(bytes);
      _leftPort.write(bytes);
      _rightPort.write(bytes);
    } catch (e) {
      print(e);
    }

    _available = false;
  }

  Future<void> setCol(int col, int val) async {
    if (!(_leftPort.isOpen && _rightPort.isOpen)) {
      print("error when setting all because connection failed");
      return;
    }

    // 将字符串转换为 ASCII 码的 Uint8List 列表

    try {
      //print(bytes);
      if (col < 20) {
        String str = 'r:$col,$val';
        List<int> asciiList = [];
        asciiList.addAll(str.codeUnits);
        asciiList.add(10); //添加换行符
        Uint8List bytes = Uint8List.fromList(asciiList);
        _leftPort.write(bytes);
      } else {
        String str = 'r:${col - 20},$val';
        List<int> asciiList = [];
        asciiList.addAll(str.codeUnits);
        asciiList.add(10); //添加换行符
        Uint8List bytes = Uint8List.fromList(asciiList);
        _rightPort.write(bytes);
      }
    } catch (e) {
      print(e);
    }
    _available = false;
  }

  bool _available = true;

  Future<void> waitUntilAvailable() async {
    while (!_available) {}
    return;
  }
}

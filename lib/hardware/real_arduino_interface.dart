import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:convert';
import 'dart:typed_data';

class RealArduinoInterface {
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
    print("left device : $leftDevice");
    print("right device : $rightDevice");
    print(SerialPort.availablePorts);

    _rightPort = SerialPort(rightDevice);
    _leftPort = SerialPort(leftDevice);

    try {
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
      //_rightPort.config = config;
      print("ok before catch");
      _leftPort.openReadWrite();
      _rightPort.openReadWrite();
      _leftReader = SerialPortReader(_leftPort);
      _rightReader = SerialPortReader(_rightPort);

      int leftBufferIndex = 0;

      Stream<Uint8List> leftUpcomingData = _leftReader!.stream.map((data) {
        return data;
      });
      List<int> buffer = [];
      leftUpcomingData.listen((data) {
        buffer.addAll(data);
        leftBufferIndex += data.length;
        print('Raw data: $data');

        if (leftBufferIndex >= 5) {
          String strBuffer = String.fromCharCodes(buffer);
          print('Buffer: $strBuffer');
          leftBufferIndex = 0;
          buffer = [];
        }
      });
    } catch (err) {
      print('串口错误：$err');
      // _leftPort.close();
    }

    try {
      _leftReader?.stream.listen((event) {
        String data = String.fromCharCodes(event);
        print("From left port event : $data");
      });
      _rightReader?.stream.listen((event) {
        String data = String.fromCharCodes(event);
        print("From right port event : $data");
      });
    } catch (e) {
      print("listen error:$e");
    }
  }

  Future<void> disconnect() async {
    //close serial port
    _leftPort.close();
    _rightPort.close();
    _leftReader?.close();
    _rightReader?.close();
  }

  Future<void> setAll(int val) async {
    if (!(_leftPort.isOpen && _rightPort.isOpen)) {
      print("error when setting all");
      return;
    }

    // 将字符串转换为 ASCII 码的 Uint8List 列表

    try {
      String str = 'a:$val';
      List<int> asciiList = [];
      asciiList.addAll(str.codeUnits);
      asciiList.add(10); //添加换行符
      Uint8List bytes = Uint8List.fromList(asciiList);
      print(bytes);

      _leftPort.write(bytes);

      _rightPort.write(bytes);
    } catch (e) {
      print(e);
    }
  }
}

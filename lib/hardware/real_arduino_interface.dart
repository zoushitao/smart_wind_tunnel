import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:convert';
import 'dart:typed_data';

class RealArduinoInterface {
  late SerialPort _leftPort;
  late SerialPort _rightPort;
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

    //_rightPort = SerialPort(rightDevice);
    _leftPort = SerialPort("/dev/cu.usbmodem143201");
    try {
      //set baud rate
      //要进行完整的配置更新
      final SerialPortConfig cfg = SerialPortConfig();
      cfg.baudRate = 115200;
      cfg.bits = 8;
      cfg.parity = -1;
      cfg.stopBits = 1;
      cfg.rts = 0;
      cfg.cts = 0;
      cfg.dtr = 0;
      cfg.dsr = 0;
      cfg.xonXoff = 0;

      _leftPort.config = cfg;
    } catch (err) {
      print('波特率设置时发生错误：$err');
      return;
    }

    //open serial port
    try {
      //_rightPort.config = config;
      print("ok before catch");
      _leftPort.openReadWrite();
      // 在这里进行写操作
      // ...
      //编码转化
      String str = 'Hello, World!';

      // 将字符串转换为 ASCII 码的 Uint8List 列表
      Uint8List bytes = Uint8List.fromList(str.codeUnits);
      print(_leftPort.write(bytes));
    } catch (err) {
      print('串口错误：$err');
      // _leftPort.close();
    }
  }
}

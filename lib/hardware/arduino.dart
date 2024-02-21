import 'dart:isolate';
import 'real_arduino_interface.dart';
import 'dart:convert';
//childIsolate main

//Gloabls
final RealArduinoInterface _realArduino = RealArduinoInterface();

Future<void> childIsolateEntry(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); // 向主 Isolate 发送子 Isolate 的接收端口

  receivePort.listen((message) {
    //Process instructions received
    print('@Isolate : Received message from main: $message');
    handleInstruction(message);
  });
  int i = 0;
  while (true) {
    i++;
    await Future.delayed(const Duration(seconds: 10), () {
      print('Isolate is running $i');
      print('@Isolate : isolate is running');
    });
  }
}

void handleInstruction(String message) {
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
      connect(jsonMap);
  }
}

void connect(Map message) {
  print("connecting");
}

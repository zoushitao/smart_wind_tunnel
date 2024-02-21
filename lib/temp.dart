import 'dart:ffi';
import 'dart:isolate';

void isolateEntryPoint(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); // 向主线程发送接收端口

  receivePort.listen((message) {
    // 在此处处理接收到的消息
    print('Received message in isolate: $message');
  });

  while (true) {
    Future.delayed(Duration(seconds: 1), null);
    print("Hello from Isolate");
  }
}

void main() async {
  ReceivePort receivePort = ReceivePort();
  Isolate isolate =
      await Isolate.spawn(isolateEntryPoint, receivePort.sendPort);

  SendPort sendPort = await receivePort.first;
  sendPort.send('Hello from main thread!');

  receivePort.listen((message) {
    // 在此处处理从隔离区接收到的消息
    print('Received message in main thread: $message');
  });
}

void printMessage() {
  print("Message"); // 打印消息

  // 延迟1秒后递归调用打印函数
}

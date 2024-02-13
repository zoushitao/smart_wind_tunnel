// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import 'dart:ui';
//import providers
import '/providers/arduino_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: Container()),
        Expanded(
          flex: 10,
          child: ListView(
            children: const [
              SizedBox(height: 20),
              SizedBox(height: 300, child: WelcomeCard()),
              SizedBox(height: 20),
              Text(
                'Serial Connection to Arduino',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 300, child: SerialCard()),
              SizedBox(height: 25),
              SerialConnectionButton(),
              Divider(
                color: Colors.grey,
                height: 20,
                thickness: 1,
                indent: 20,
                endIndent: 0,
              ),
              SizedBox(height: 25),
              TipsWidget(),
              SizedBox(height: 45),
            ],
          ),
        ),
        Expanded(flex: 2, child: Container())
      ],
    );
  }
}

class SerialConnectionButton extends StatelessWidget {
  const SerialConnectionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return Row(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text("Refresh "),
              onPressed: () {
                arduinoModel.refreshSerialList();
              },
            ),
            const SizedBox(width: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.connecting_airports, size: 20),
              label: const Text("Connect "),
              onPressed: () {
                arduinoModel.connect();
              },
            ),
          ],
        ),
        const Expanded(child: SizedBox()),
        ElevatedButton.icon(
          icon: const Icon(Icons.list, size: 20),
          label: const Text("Details"),
          onPressed: () {},
        ),
      ],
    );
  }
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF846AFF),
              Color(0xFF755EE8),
              Colors.purpleAccent,
              Colors.amber,
            ],
          ),
          borderRadius: BorderRadius.circular(
              16)), // Adds a gradient background and rounded corners to the container
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 2,
            child: Image(image: AssetImage('assets/images/arduino.png')),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Hello',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Don\'t know how to start?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Click the button below to watch the quick guide',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("fuck "),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SerialCard extends StatefulWidget {
  const SerialCard({Key? key}) : super(key: key);

  @override
  _SerialCardState createState() => _SerialCardState();
}

class _SerialCardState extends State<SerialCard> {
  //Serial Port String
  late List<String> _serialPortList;
  final List<String> _baudRateList = <String>['115200', '9600'];

  late String _rightSelectedDevice;

  late String _leftSelectedDevice;

  //States
  late SmartWindProvider _arduinoModel;

  @override
  void initState() {
    super.initState();
    // 设置初始状态
    _leftSelectedDevice = "not ok ";
    _rightSelectedDevice = "not ok";
  }

  //
  @override
  Widget build(BuildContext context) {
    _arduinoModel = Provider.of<SmartWindProvider>(context);

    //一些初始化操作
    _serialPortList = _arduinoModel.availablePorts;
    _arduinoModel.setLeftSerialPort(_leftSelectedDevice);
    _arduinoModel.setRightSerialPort(_rightSelectedDevice);

    return Row(
      children: [
        Expanded(flex: 20, child: LeftSerialPort(context)),
        const SizedBox(width: 20),
        Expanded(flex: 20, child: RightSerialPort(context)),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Container RightSerialPort(BuildContext context) {
    String? manufacturer =
        _arduinoModel.acquireDeviceDetail(_rightSelectedDevice)["Manufacturer"];
    manufacturer ??= "Null";
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 221, 220, 220),
              Color.fromARGB(255, 179, 178, 178)
            ],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.usb,
                color: Colors.black,
              ),
              trailing: IconButton(
                  onPressed: () {
                    // 按钮点击事件
                    _showDialog(context, _rightSelectedDevice);
                  },
                  icon: const Icon(Icons.info)),
              title: const Text(
                'Right Arduino Device:',
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: const Text(
                  'Select a device name from the list and set the baud rate.',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black)),
              onTap: null,
            ),
            const Text(
              'Device:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownMenu<String>(
              initialSelection: _serialPortList.first,
              label: const Text('Device Name'),
              leadingIcon: const Icon(Icons.device_hub),
              requestFocusOnTap: true,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  if (value != null) {
                    _rightSelectedDevice = value!;
                  }
                });
              },
              dropdownMenuEntries: _serialPortList
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(Icons.factory),
              title: const Text(
                "Manufacture",
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(manufacturer,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  Container LeftSerialPort(BuildContext context) {
    String? manufacturer =
        _arduinoModel.acquireDeviceDetail(_leftSelectedDevice)["Manufacturer"];
    manufacturer ??= "Null";
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 179, 178, 178),
              Color.fromARGB(255, 221, 220, 220),
            ],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.usb,
                color: Colors.black,
              ),
              trailing: IconButton(
                  onPressed: () {
                    // 按钮点击事件
                    _showDialog(context, _leftSelectedDevice);
                  },
                  icon: const Icon(Icons.info)),
              title: const Text(
                'Left Arduino Device:',
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: const Text(
                  'Select a device name from the list and set the baud rate.',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black)),
              onTap: null,
            ),
            const Text(
              'Device:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownMenu<String>(
              initialSelection: _serialPortList.first,
              label: const Text('Device Name'),
              leadingIcon: const Icon(Icons.device_hub),
              requestFocusOnTap: true,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  if (value != null) {
                    _leftSelectedDevice = value!;
                  }
                });
              },
              dropdownMenuEntries: _serialPortList
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(Icons.factory),
              title: const Text(
                "Manufacture",
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(manufacturer,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String portName) {
    var info = _arduinoModel.acquireDeviceDetail(portName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(info.toString()),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }
}

class AllSerialDevices extends StatefulWidget {
  const AllSerialDevices({Key? key}) : super(key: key);

  @override
  _AllSerialDevicesState createState() => _AllSerialDevicesState();
}

class _AllSerialDevicesState extends State<AllSerialDevices> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TipsWidget extends StatelessWidget {
  const TipsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/purple_backgounrd.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.lightbulb,
              color: Colors.white,
            ),
            title: Text(
              'Right Arduino Device:',
              textAlign: TextAlign.left,
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
            ),
            subtitle: Text(
                'Select a device name from the list and set the baud rate.',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white)),
            onTap: null,
          ),
        ],
      ),
    );
  }
}

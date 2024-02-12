import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import providers
import '/providers/arduino_provider.dart';

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
              SizedBox(height: 300, child: SerialConnection()),
            ],
          ),
        ),
        Expanded(flex: 2, child: Container())
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

class SerialConnection extends StatefulWidget {
  const SerialConnection({Key? key}) : super(key: key);

  @override
  _SerialConnectionState createState() => _SerialConnectionState();
}

class _SerialConnectionState extends State<SerialConnection> {
  //Serial Port String
  late List<String> serialPortList;

  late String _dropdownValue;
  //States
  String _rightSelectedPort = '';
  String _leftSelectedPort = '';
  String _selectedOption = '';
  //
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    //一些初始化操作
    serialPortList = ["ok", "next"];
    _dropdownValue = serialPortList.first;
    return Container(
        child: Row(
      children: [
        Expanded(flex: 20, child: LeftSerialPort()),
        const SizedBox(width: 20),
        Expanded(flex: 20, child: RightSerialPort()),
      ],
    ));
  }

  Container RightSerialPort() {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2ECC71), Color.fromARGB(255, 20, 122, 63)],
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.usb_sharp),
              title: Text(
                'Right Arduino Device:',
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                  'Select a device name from the list and set the baud rate.'),
              trailing: Icon(Icons.arrow_forward),
              onTap: null,
            ),
            const Text(
              'Device:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              width: 10,
            ),
            DropdownMenu<String>(
              initialSelection: serialPortList.first,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  _dropdownValue = value!;
                });
              },
              dropdownMenuEntries:
                  serialPortList.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Container LeftSerialPort() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          'Rounded Rectangle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

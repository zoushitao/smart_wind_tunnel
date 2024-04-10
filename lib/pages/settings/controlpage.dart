import 'package:flutter/material.dart';
import '../../providers/smart_wind_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:smart_wind_tunnel/pages/settings/charts.dart';
import 'wave_mode_view.dart';
import 'gust_mode_view.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 10,
          child: ListView(
            children: [
              SizedBox(
                height: 600,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: const ModeSettingsWidget(),
                    )),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

//main content
class ModeSettingsWidget extends StatefulWidget {
  const ModeSettingsWidget({super.key});

  @override
  State<ModeSettingsWidget> createState() => _ModeSettingsWidgetState();
}

class _ModeSettingsWidgetState extends State<ModeSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 选项卡的数量
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Even Mode',
                icon: Icon(Icons.wind_power),
              ),
              Tab(
                text: 'Gust Mode',
                icon: Icon(
                  Icons.wind_power,
                ),
              ),
              Tab(
                text: 'Sheer Mode',
                icon: Icon(Icons.wind_power),
              ),
              Tab(
                text: 'Wave Mode',
                icon: Icon(Icons.wind_power),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // The first tab
            EvenModeView(),
            // The second tab
            GustModeView(),
            // The third tab
            SheerModeView(),
            // The fourth tab
            WaveModeView()
          ],
        ),
      ),
    );
  }
}

class EvenModeView extends StatefulWidget {
  const EvenModeView({Key? key}) : super(key: key);

  @override
  _EvenModeViewState createState() => _EvenModeViewState();
}

class _EvenModeViewState extends State<EvenModeView> {
  @override
  void initState() {
    super.initState();
    _evenSliderValue = 0.0;
  }

  double _evenSliderValue = 0.0;
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    int val = arduinoModel.evenModeConfig['value'];

    _evenSliderValue = val.toDouble();
    return ListView(
      children: <Widget>[
        const SizedBox(height: 10),
        const ListTile(
            //leading: Icon(Icons.pentagon),
            title: Text("Tips"),
            subtitle: Text(
              "Configure will be automatically saved ",
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Value : "),
            Expanded(
                child: Slider(
              value: _evenSliderValue,
              min: 0,
              max: 4095,
              divisions: 4095,
              label: 'Value: ${_evenSliderValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _evenSliderValue = newValue;
                  //do something else
                  arduinoModel.setEvenMode(newValue.toInt());
                });
              },
            )),
          ],
        )
      ],
    );
  }
}

class SheerModeView extends StatefulWidget {
  const SheerModeView({Key? key}) : super(key: key);

  @override
  _SheerModeViewState createState() => _SheerModeViewState();
}

class _SheerModeViewState extends State<SheerModeView> {
  @override
  void initState() {
    super.initState();
    _evenSliderValue = 0.0;
  }

  double _evenSliderValue = 0.0;
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    int val = arduinoModel.evenModeConfig['value'];

    _evenSliderValue = val.toDouble();
    return ListView(
      children: <Widget>[
        const SizedBox(height: 10),
        const ListTile(
            //leading: Icon(Icons.pentagon),
            title: Text("Tips"),
            subtitle: Text(
              "Configure will be automatically saved ",
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Value : "),
            Expanded(
                child: Slider(
              value: _evenSliderValue,
              min: 0,
              max: 4095,
              divisions: 4095,
              label: 'Value: ${_evenSliderValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _evenSliderValue = newValue;
                  //do something else
                  arduinoModel.setEvenMode(newValue.toInt());
                });
              },
            )),
          ],
        )
      ],
    );
  }
}

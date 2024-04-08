import 'package:flutter/material.dart';
import '/providers/arduino_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:smart_wind_tunnel/pages/settings/charts.dart';

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

class GustModeView extends StatefulWidget {
  const GustModeView({Key? key}) : super(key: key);

  @override
  _GustModeViewState createState() => _GustModeViewState();
}

class _GustModeViewState extends State<GustModeView> {
  double _gustUpperSlider = 0.0;
  double _gustLowerSlider = 0.0;
  double _gustPeriodSpinBox = 0.0;

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    late int lower, upper, period;
    try {
      lower = arduinoModel.gustModeCongig['lowerLimit'];
      upper = arduinoModel.gustModeCongig['upperLimit'];
      period = arduinoModel.gustModeCongig['period']; //unit : MS
      //print(arduinoModel.gustMode);
    } catch (e) {
      //
    }
    _gustUpperSlider = upper.toDouble();
    _gustLowerSlider = lower.toDouble();
    _gustPeriodSpinBox = period.toDouble() / 1000; //convert Ms to S

    return Row(
      children: [
        Expanded(flex: 2, child: _gustSettingPad(arduinoModel)),
        const SizedBox(
          width: 10,
        ),
        const VerticalDivider(
          color: Colors.grey,
          width: 1,
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(flex: 1, child: SineLinechart())
      ],
    );
  }

  ListView _gustSettingPad(SmartWindProvider arduinoModel) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 10),
        const ListTile(
            leading: Icon(Icons.pentagon),
            title: Text("Tips"),
            subtitle: Text("s is ")),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Upper Limit : "),
            Expanded(
                child: Slider(
              value: _gustUpperSlider,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Upper Limit: ${_gustUpperSlider.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustUpperSlider = newValue;
                  //Do something Here
                  double periodS = _gustPeriodSpinBox * 1000;
                  int periodMs = periodS.toInt();
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerSlider.toInt(),
                      upperLimit: _gustUpperSlider.toInt(),
                      periodMs: periodMs);
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Lower Limit :  : "),
            Expanded(
                child: Slider(
              value: _gustLowerSlider,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Lower Limit: ${_gustLowerSlider.toInt()}',
              secondaryTrackValue: _gustUpperSlider,
              onChanged: (newValue) {
                setState(() {
                  _gustLowerSlider = newValue;
                  //Do something Here
                  double periodS = _gustPeriodSpinBox * 1000;
                  int periodMs = periodS.toInt();
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerSlider.toInt(),
                      upperLimit: _gustUpperSlider.toInt(),
                      periodMs: periodMs);
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Period(second): "),
            const SizedBox(width: 30),
            Expanded(
              child: SpinBox(
                min: 1,
                max: 60,
                value: _gustPeriodSpinBox,
                decimals: 1,
                step: 0.1,
                acceleration: 1,
                decoration: const InputDecoration(labelText: 'second'),
                onChanged: (value) {
                  if (value > 60.0 || value < 1.0) {
                    return;
                  }
                  _gustPeriodSpinBox = value;
                  //Do something Here
                  double periodS = _gustPeriodSpinBox * 1000;
                  int periodMs = periodS.toInt();
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerSlider.toInt(),
                      upperLimit: _gustUpperSlider.toInt(),
                      periodMs: periodMs);
                },
              ),
            ),
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

class WaveModeView extends StatefulWidget {
  const WaveModeView({Key? key}) : super(key: key);

  @override
  _WaveModeViewState createState() => _WaveModeViewState();
}

class _WaveModeViewState extends State<WaveModeView> {
  double _waveUpperSlider = 0.0;
  double _waveLowerSlider = 0.0;
  double _waveLengthSlider = 0.0;
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
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
              value: _waveUpperSlider,
              min: 0,
              max: 4095,
              divisions: 4095,
              label: 'Value: ${_waveUpperSlider.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _waveUpperSlider = newValue;
                  //do something else
                  //arduinoModel.setEvenMode(newValue.toInt());
                });
              },
            )),
          ],
        )
      ],
    );
    ;
  }
}

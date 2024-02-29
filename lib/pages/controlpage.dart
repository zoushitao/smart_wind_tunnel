import 'package:flutter/material.dart';
import '/providers/arduino_provider.dart';
import 'package:provider/provider.dart';

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
                text: 'Tab 3',
                icon: Icon(Icons.tab),
              ),
              Tab(
                text: 'Tab 4',
                icon: Icon(Icons.tab),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 第一个选项卡的内容
            const EvenModeView(),
            // 第二个选项卡的内容
            const GustModeView(),
            // 第三个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 3 Content'),
              ),
            ),
            // 第四个选项卡的内容
            Container(
              child: Center(
                child: Text('Tab 4 Content'),
              ),
            ),
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
    int val = arduinoModel.evenMode['value'];

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
  double _gustUpperValue = 0.0;
  double _gustLowerValue = 0.0;
  double _gustPeriodValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    late int lower, upper, period;
    try {
      lower = arduinoModel.gustMode['lowerLimit'];
      upper = arduinoModel.gustMode['upperLimit'];
      period = arduinoModel.gustMode['period'];
      //print(arduinoModel.gustMode);
    } catch (e) {
      //
    }
    _gustUpperValue = upper.toDouble();
    _gustLowerValue = lower.toDouble();
    _gustPeriodValue = period.toDouble();

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
              value: _gustUpperValue,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Upper Limit: ${_gustUpperValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustUpperValue = newValue;
                  //Do something Here
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerValue.toInt(),
                      upperLimit: _gustUpperValue.toInt(),
                      periodMs: _gustPeriodValue.toInt());
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
              value: _gustLowerValue,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Lower Limit: ${_gustLowerValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustLowerValue = newValue;
                  //Do something Here
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerValue.toInt(),
                      upperLimit: _gustUpperValue.toInt(),
                      periodMs: _gustPeriodValue.toInt());
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Period : "),
            Expanded(
                child: Slider(
              value: _gustPeriodValue,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: 'Period(ms): ${_gustPeriodValue.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _gustPeriodValue = newValue;
                  arduinoModel.setGustMode(
                      lowerLimit: _gustLowerValue.toInt(),
                      upperLimit: _gustUpperValue.toInt(),
                      periodMs: _gustPeriodValue.toInt());
                  //Do something Here
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../providers/arduino_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:smart_wind_tunnel/pages/settings/charts.dart';

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
      lower = arduinoModel.gustModeConfig['lowerLimit'];
      upper = arduinoModel.gustModeConfig['upperLimit'];
      period = arduinoModel.gustModeConfig['period']; //unit : MS
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
                  if (newValue <= _gustLowerSlider) {
                    return;
                  }
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
                  //lower can't be greater than upper
                  if (newValue >= _gustUpperSlider) {
                    return;
                  }
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
            const Text("Period: "),
            const SizedBox(width: 30),
            Expanded(
              child: SpinBox(
                min: 1,
                max: 60,
                value: _gustPeriodSpinBox,
                decimals: 1,
                step: 0.1,
                acceleration: 1,
                decoration: const InputDecoration(labelText: 'second(s)'),
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

import 'package:flutter/material.dart';
import '../../providers/arduino_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:smart_wind_tunnel/pages/settings/charts.dart';

class WaveModeView extends StatefulWidget {
  const WaveModeView({Key? key}) : super(key: key);

  @override
  _WaveModeViewState createState() => _WaveModeViewState();
}

class _WaveModeViewState extends State<WaveModeView> {
  double _waveUpperSlider = 0.0;
  double _waveLowerSlider = 0.0;
  int _waveLengthSlider = 10;
  double _wavePeriodSpinBox = 6.0;
  bool _waveOrientationSwitch = true;
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return _waveSettingPad(arduinoModel);
  }

  ListView _waveSettingPad(SmartWindProvider arduinoModel) {
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
              value: _waveUpperSlider,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Upper Limit: ${_waveUpperSlider.toInt()}',
              onChanged: (newValue) {
                setState(() {
                  _waveUpperSlider = newValue;
                  //Do something Here
                  double periodS = _wavePeriodSpinBox * 1000;
                  int periodMs = periodS.toInt();
                  arduinoModel.setWaveMode(
                      lowerLimit: _waveLowerSlider.toInt(),
                      upperLimit: _waveUpperSlider.toInt(),
                      periodMs: periodMs,
                      waveLength: _waveLengthSlider);
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
              value: _waveLowerSlider,
              min: 0.0,
              max: 4095.0,
              divisions: 4095,
              label: 'Lower Limit: ${_waveLowerSlider.toInt()}',
              secondaryTrackValue: _waveUpperSlider,
              onChanged: (newValue) {
                setState(() {
                  //lower can't be greater than upper
                  if (newValue >= _waveUpperSlider) {
                    return;
                  }
                  _waveLowerSlider = newValue;
                  //Do something Here
                  double periodS = _wavePeriodSpinBox * 1000;
                  int periodMs = periodS.toInt();
                  arduinoModel.setWaveMode(
                      lowerLimit: _waveLowerSlider.toInt(),
                      upperLimit: _waveUpperSlider.toInt(),
                      periodMs: periodMs,
                      waveLength: _waveLengthSlider);
                });
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
        const SizedBox(height: 40),
        _PeriodRow(arduinoModel),
        const SizedBox(height: 40),
        _waveLengthRow(arduinoModel),
        const SizedBox(height: 40),
        _orientationRow()
      ],
    );
  }

  Row _PeriodRow(SmartWindProvider arduinoModel) {
    return Row(
        children: [
          const SizedBox(width: 10),
          const Text("Period: "),
          const SizedBox(width: 30),
          Expanded(
            child: SpinBox(
              min: 1,
              max: 60,
              value: _waveLengthSlider.toDouble(),
              decimals: 1,
              step: 0.1,
              acceleration: 1,
              decoration: const InputDecoration(labelText: 'second(s)'),
              onChanged: (value) {
                if (value > 60.0 || value < 1.0) {
                  return;
                }
                _waveLengthSlider = value.toInt();
                //Do something Here
                double periodS = _wavePeriodSpinBox * 1000;
                int periodMs = periodS.toInt();
                arduinoModel.setWaveMode(
                    lowerLimit: _waveLowerSlider.toInt(),
                    upperLimit: _waveUpperSlider.toInt(),
                    periodMs: periodMs,
                    waveLength: _waveLengthSlider);
              },
            ),
          ),
        ],
      );
  }

  Row _waveLengthRow(SmartWindProvider arduinoModel) {
    return Row(
        children: [
          const SizedBox(width: 10),
          const Text("Wave Length (in row or column): "),
          const SizedBox(width: 30),
          Expanded(
            child: SpinBox(
              min: 4,
              max: 40,
              value: _wavePeriodSpinBox,
              decimals: 0,
              step: 1,
              acceleration: 0,
              decoration: const InputDecoration(labelText: 'row(s)'),
              onChanged: (value) {
                if (value > 40.0 || value < 4.0) {
                  return;
                }
                _wavePeriodSpinBox = value;
                //Do something Here
                double periodS = _wavePeriodSpinBox * 1000;
                int periodMs = periodS.toInt();
                arduinoModel.setWaveMode(
                    lowerLimit: _waveLowerSlider.toInt(),
                    upperLimit: _waveUpperSlider.toInt(),
                    periodMs: periodMs,
                    waveLength: _waveLengthSlider);
              },
            ),
          ),
        ],
      );
  }

  Row _orientationRow() {
    return Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          const Text("Orientation: "),
          const SizedBox(width: 20),
          Switch(
              value: _waveOrientationSwitch,
              activeColor: Colors.blueAccent,
              onChanged: (bool value) {
                setState(() {
                  _waveOrientationSwitch = value;
                });
              }),
          const SizedBox(width: 30),
          Icon(
            _waveOrientationSwitch ? Icons.arrow_downward : Icons.fork_right,
            color: Colors.blueAccent,
          ),
          Text(_waveOrientationSwitch ? "Up to Down" : "Left to Right")
        ],
      );
  }
}

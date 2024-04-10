import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import '../../providers/smart_wind_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SineLinechart extends StatefulWidget {
  const SineLinechart({super.key});

  final Color sinColor = Colors.blue;
  final Color cosColor = Colors.red;

  @override
  State<SineLinechart> createState() => _SineLinechartState();
}

class _SineLinechartState extends State<SineLinechart> {
  final limitCount = 300;

  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;
  double time = 0.0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      while (cosPoints.length > limitCount) {
        cosPoints.removeAt(0);
      }
      setState(() {
        cosPoints.add(FlSpot(xValue, math.cos(xValue)));
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    double PeriodMS = arduinoModel.gustModeConfig['period'].toDouble();
    step = 2 * math.pi / (PeriodMS / 40); //40 is the timer speed
    double timeS = xValue / step / 40 * math.pi / 2;
    double cosVal = 0.0;
    try {
      cosVal = cosPoints.last.y * (4095 / 2) + 4095 / 2;
    } catch (e) {
      print(e);
    }

    return cosPoints.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'time: ${timeS.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'cos: ${cosVal.toStringAsFixed(1)}',
                style: TextStyle(
                  color: widget.cosColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: LineChart(
                    LineChartData(
                      minY: -1,
                      maxY: 1,
                      minX: cosPoints.first.x,
                      maxX: cosPoints.last.x,
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        cosLine(cosPoints),
                      ],
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : Container();
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [widget.cosColor.withOpacity(0), widget.cosColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import '../../providers/arduino_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

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

class waveChart extends StatefulWidget {
  const waveChart();

  @override
  State<waveChart> createState() => _waveChartState();
}

class _waveChartState extends State<waveChart> {
  final limitCount = 300;

  final cosPoints = <FlSpot>[];

  double ref = 0;
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
        cosPoints.add(FlSpot(ref, math.cos(ref)));
      });
      ref += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final arduinoModel = Provider.of<SmartWindProvider>(context);

    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: newbarGroups(context),
        gridData: const FlGridData(show: true),
        alignment: BarChartAlignment.spaceAround,
        maxY: 4095,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              //rod.toY.round().toString(),
              '',
              const TextStyle(
                color: AppColors.contentColorCyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.contentColorBlue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    value += 1.0;
    String text;
    text = "${value.toInt()}";
    text = '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade400,
          Colors.blue.shade500,
          Colors.blue.shade600,
          Colors.blue.shade700,
          Colors.blue.shade800,
          Colors.blue.shade900
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> newbarGroups(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    double upper = arduinoModel.waveModeConfig['upperLimit'].toDouble();
    double lower = arduinoModel.waveModeConfig['lowerLimit'].toDouble();
    double waveLength = arduinoModel.waveModeConfig['waveLength'].toDouble();
    double step_space = 2 * math.pi / (waveLength);

    List<int> numbers = List.generate(40, (index) {
      double val =
          (upper - lower) * math.sin(index.toDouble() * step_space + ref) / 2 +
              (upper + lower) / 2;

      return val.toInt();
    });
    List<BarChartGroupData> data = <BarChartGroupData>[];

    for (int item in numbers) {
      data.add(
        BarChartGroupData(
          x: numbers.indexOf(item),
          barRods: [
            BarChartRodData(
              toY: item.toDouble(),
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return data;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1.6,
      child: waveChart(),
    );
  }
}

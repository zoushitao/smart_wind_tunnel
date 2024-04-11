import 'package:flutter/material.dart';
import '../../providers/arduino_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:smart_wind_tunnel/pages/settings/charts.dart';
import 'dart:ui';

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
    return Row(
      children: [
        Expanded(flex: 1, child: ReorderableExample()),
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
        Expanded(flex: 2, child: tempListView(arduinoModel))
      ],
    );
    ;
  }

  ListView tempListView(SmartWindProvider arduinoModel) {
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
        ),
      ],
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  final List<int> _items = List<int>.generate(50, (int index) => index);

  final List<ListTile> listTileItems = <ListTile>[];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.secondary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.secondary.withOpacity(0.15);
    final Color draggableItemColor = colorScheme.secondary;

    final arduinoModel = Provider.of<SmartWindProvider>(context);

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: draggableItemColor,
            shadowColor: draggableItemColor,
            child: child,
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      proxyDecorator: proxyDecorator,
      children: acquireListItems(arduinoModel, oddItemColor, evenItemColor),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
    );
  }

  List<ListTile> acquireListItems(
      SmartWindProvider arduinoModel, Color oddItemColor, Color evenItemColor) {
    return <ListTile>[
      for (int index = 0; index < _items.length; index += 1)
        ListTile(
          key: Key('$index'),
          leading: IconButton(
            icon: Icon(Icons.remove), // 图标
            onPressed: () {
              // 处理按钮点击事件
              print('Button clicked');
            },
          ),
          tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
          title: Text('Item ${_items[index]}'),
          //onTap: () {},
        ),
    ];
  }

  void generateListItems(SmartWindProvider arduinoModel) {}
}

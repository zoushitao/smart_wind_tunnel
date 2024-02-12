import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 10,
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 18,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MonitorWidget(),
                    )),
              ),
              SizedBox(
                height: 400,
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: null,
                    )),
              )
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

class MonitorWidget extends StatefulWidget {
  const MonitorWidget({Key? key}) : super(key: key);

  @override
  _MonitorWidgetState createState() => _MonitorWidgetState();
}

class _MonitorWidgetState extends State<MonitorWidget> {
  List<Widget> _cells = [];
  void _contructCells() {
    for (int i = 0; i < 1600; i++) {
      _cells.add(const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _contructCells();
    return _generateGridView();
  }

  GridView _generateGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 40, // 每行显示的列数
        crossAxisSpacing: 3.0, // 列之间的间距
        mainAxisSpacing: 3.0, // 行之间的间距
        childAspectRatio: 1.0, // 宽高比例为1:1
      ),
      //限制每个item的大小
      itemCount: _cells.length,
      physics: const NeverScrollableScrollPhysics(), // 关闭滚动功能
      itemBuilder: (BuildContext context, int index) {
        return _cells[index];
      },
    );
  }
}

import 'package:flutter/material.dart';

//import pages
import './pages/homepage.dart';
import 'pages/monitorpage.dart';
import 'pages/controlpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //禁用debug横幅
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        useMaterial3: true,
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;
  var _widgetList = <Widget>[HomePage(), ViewPage(), ControlPage()];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: appBar(context),
        bottomNavigationBar: Container(
            width: double.infinity, // 将宽度设置为无限大
            height: 25, // 将高度设置为无限大
            color: Theme.of(context).primaryColor),
        body: Row(
          children: [
            SafeArea(child: NavigationBar(constraints)),
            const Divider(
              color: Colors.black,
              thickness: 2.0,
              height: 900,
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _widgetList[selectedIndex],
              ),
            ),
          ],
        ),
      );
    });
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Smart Wind',
            style: TextStyle(
              color: Colors.white, // 设置文本颜色为蓝色
            )),
        centerTitle: true, //居中标题

        //右侧按钮
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.info),
            onPressed: () {
              // 右侧按钮1点击事件
              _showInfoDialog(context);
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // 右侧按钮2点击事件
            },
          ),
        ],
        //左侧按钮
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            // 点击左侧按钮的事件
          },
        ));
  }

  // ignore: non_constant_identifier_names
  Container NavigationBar(BoxConstraints constraints) {
    return Container(
      child: NavigationRail(
        extended: constraints.maxWidth >= 600, // ← Here.
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.monitor),
            label: Text('Monitor'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.keyboard),
            label: Text('Control'),
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }

  //相关信息对话框
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dialog Title'),
          content: const Text('This is the content of the dialog.'),
          actions: [
            TextButton(
              onPressed: () {
                // 在这里处理对话框的操作
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

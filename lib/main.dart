import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import providers
import 'providers/arduino_provider.dart';
//import pages
import './pages/homepage.dart';
import 'pages/monitorpage.dart';
import 'pages/controlpage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SmartWindProvider>(
          create: (context) => SmartWindProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
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
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
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
  final _widgetList = <Widget>[HomePage(), ViewPage(), ControlPage()];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: appBar(context),
        bottomNavigationBar: BottomBar(),
        floatingActionButton: MainFloatingButton(),
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
                color: const Color.fromARGB(255, 233, 232, 232),
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
        //backgroundColor: Theme.of(context).primaryColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF846AFF),
            Color(0xFF755EE8),
            Colors.purpleAccent,
            Colors.amber,
          ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
        ),
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

class MainFloatingButton extends StatelessWidget {
  const MainFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // 在这里添加你的按钮点击事件处理
        Provider.of<SmartWindProvider>(context, listen: false).startIsolate();
      },
      child: Icon(Icons.pause),
      backgroundColor: Colors.green,
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 将宽度设置为无限大
      height: 30, //将高度设置
      color: Colors.black, //颜色用来展示状态
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // 按钮点击事件
                  // 在这里执行您想要的操作
                },
              )),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Hello World',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }
}

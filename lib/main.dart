import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import providers
import 'providers/arduino_provider.dart';

// third party lib
import 'package:window_manager/window_manager.dart';
import 'package:sidebarx/sidebarx.dart';
//import pages
import './pages/homepage.dart';
import 'pages/monitorpage.dart';
import 'pages/settings/controlpage.dart';
import 'dart:async';
import 'package:flutter/services.dart';

Future<void> main() async {
  await initWindow();
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

Future<void> initWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1400, 800),
    size: Size(1400, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //gobal dynamic refreshing

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

final _controller = SidebarXController(selectedIndex: 0, extended: true);
final _key = GlobalKey<ScaffoldState>();

class _MainAppState extends State<MainApp> {
  int selectedIndex = 0;
  final _widgetList = <Widget>[
    const HomePage(),
    const ViewPage(),
    const ControlPage()
  ];
  @override
  Widget build(BuildContext context) {
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: appBar(context),
        bottomNavigationBar: BottomBar(),
        floatingActionButton: MainFloatingButton(),
        body: Row(
          children: [
            SafeArea(child: SmartWindSidebarX(controller: _controller)),
            const Divider(
              color: Colors.black,
              thickness: 2.0,
              height: 900,
            ),
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 233, 232, 232),
                child: _widgetList[arduinoModel.selectedPageIndex],
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
            print("controller.selectedIndex:${_controller.selectedIndex}");
          },
        ),
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            _showExitDialog(context);
          },
        ),
      ],
      //左侧按钮
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quit'),
          content: const Text('Your fans will be turned off when you leave'),
          actions: [
            TextButton(
              onPressed: () {
                // 在这里处理对话框的操作
                quitApp(context); // 关闭对话框
              },
              child: const Text('I said QUIT!!',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                // 在这里处理对话框的操作
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('I am not leaving'),
            ),
          ],
        );
      },
    );
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
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return FloatingActionButton(
      onPressed: () {
        // 在这里添加你的按钮点击事件处理
        if (arduinoModel.isRunning) {
          arduinoModel.stop();
        } else {
          arduinoModel.launch();
        }
      },
      backgroundColor: arduinoModel.isRunning ? Colors.yellow : Colors.green,
      child: arduinoModel.isRunning
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
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
    var arduinoModel = Provider.of<SmartWindProvider>(context);

    final Color buttomBarColor =
        arduinoModel.isConnected ? Colors.green : Colors.redAccent;
    return Container(
      width: double.infinity, // 将宽度设置为无限大
      height: 30, //将高度设置
      color: buttomBarColor, //颜色用来展示状态
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: arduinoModel.isConnected
                  ? connectedRow(context)
                  : disconnectedRow(context)),
          const Expanded(
            flex: 2,
            child: BottomSheetButton(),
          ),
        ],
      ),
    );
  }

  Row connectedRow(BuildContext context) {
    var arduinoModel = Provider.of<SmartWindProvider>(context);

    String info =
        "Connected,left:$arduinoModel.leftPort,right:$arduinoModel.rightPort";
    return Row(children: [
      const SizedBox(
        width: 20,
      ),
      Icon(Icons.check, color: Colors.white),
      Text(
        info,
        style: TextStyle(color: Colors.white),
      )
    ] // 设置文本颜色为蓝色)],

        );
  }

  Row disconnectedRow(BuildContext context) {
    return const Row(children: [
      SizedBox(
        width: 20,
      ),
      Icon(Icons.close, color: Colors.white),
      Text(
        "Disonnected",
        style: TextStyle(color: Colors.white),
      )
    ] // 设置文本颜色为蓝色)],
        );
  }
}

class BottomSheetButton extends StatelessWidget {
  const BottomSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        child: const Row(
          children: [
            Icon(
              Icons.upload,
              color: Colors.white,
            ),
            Text(
              'More Information',
              style: TextStyle(
                color: Colors.white, // 设置文本颜色为蓝色
              ),
            ),
          ],
        ),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 600,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ArduinoStatusCard(),
                      SizedBox(height: 10),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SmartWindSidebarX extends StatefulWidget {
  SmartWindSidebarX({
    super.key,
    required SidebarXController controller,
  }) : _controller = controller;

  final SidebarXController _controller;

  //configure
  static const primaryColor = Color(0xFF685BFF);
  static const canvasColor = Color(0xFF2E2E48);
  static const scaffoldBackgroundColor = Color(0xFF464667);
  static const accentCanvasColor = Color(0xFF3E3E61);
  static const white = Colors.white;

  @override
  State<SmartWindSidebarX> createState() => _SmartWindSidebarXState();
}

class _SmartWindSidebarXState extends State<SmartWindSidebarX> {
  var actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);

  var divider =
      Divider(color: SmartWindSidebarX.white.withOpacity(0.3), height: 2);

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color.fromARGB(255, 180, 181, 182);
    final arduinoModel = Provider.of<SmartWindProvider>(context);
    return SidebarX(
      controller: widget._controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: themeColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: themeColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: themeColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(colors: [
            Color.fromARGB(255, 102, 101, 101),
            Color.fromARGB(255, 102, 101, 101),
          ]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: themeColor,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/arduino.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            arduinoModel.selectedPageIndex = 0;
          },
        ),
        SidebarXItem(
          icon: Icons.wind_power,
          label: 'Control Panel',
          onTap: () {
            arduinoModel.selectedPageIndex = 1;
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            arduinoModel.selectedPageIndex = 2;
          },
        ),
      ],
    );
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'People';
      case 3:
        return 'Favorites';
      case 4:
        return 'Custom iconWidget';
      case 5:
        return 'Profile';
      case 6:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}

void quitApp(BuildContext context) {
  //final arduinoModel = Provider.of<SmartWindProvider>(context);
  //arduinoModel.stop();
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

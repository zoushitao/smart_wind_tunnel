import 'package:flutter/material.dart';

//import pages
import './pages/homepage.dart';
import 'pages/viewpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
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
  var _widgetList = <Widget>[HomePage(), ViewPage()];
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: Row(
          children: [
            SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green], // 渐变色数组
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // ← Here.
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
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
}

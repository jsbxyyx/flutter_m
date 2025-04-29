import 'package:flutter/material.dart';
import './pages/main.dart';
import './pages/splash.dart';
import './init.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MainNavigatorWidget();
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}

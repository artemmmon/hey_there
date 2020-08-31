import 'package:flutter/material.dart';
import 'package:web_test_task/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hey there',
      home: HomePage(),
    );
  }
}

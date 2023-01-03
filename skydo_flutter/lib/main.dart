import 'package:flutter/material.dart';
import 'package:skydo_flutter/LoginPage.dart';
import 'package:skydo_flutter/RegisterPage.dart';
import 'package:skydo_flutter/todos/single_todo.dart';
import 'package:skydo_flutter/todos/todo_list.dart';

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
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,

      // ),
      // Dark theme
      theme: ThemeData.dark(),

      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/': (context) => TodoListPaage(),
        TodoListPaage.routeName: (context) => TodoListPaage(),
        LoginPage.routeName: (context) => const LoginPage(),
        SingleTodoPage.routeName: (context) => SingleTodoPage(),
        RegisterPage.routeName: (context) => RegisterPage(),
      },
    );
  }
}

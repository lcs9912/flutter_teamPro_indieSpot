import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'baseBar.dart';
import 'login.dart';
import 'join.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Join(), // Join() 페이지로 이동합니다.
                  ),
                );
              },
              child: Text('회원가입'),
            )
        ),
        bottomNavigationBar: MyBottomBar(),
      ),
    );

  }
}
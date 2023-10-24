import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> imgList = [
    '../busking/bus_sample1.jpg',
    '../busking/bus_sample2.jpg',
    '../busking/bus_sample3.jpg',
    '../busking/bus_sample4.jpg',
    '../busking/bus_sample5.jpg',
    '../busking/bus_sample6.jpg',
  ];

  List<String> titleList = [
    '샘플1',
    '샘플2',
    '샘플3',
    '샘플4',
    '샘플5',
    '샘플6',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: imgList.length,
            itemBuilder: (context, index){
              var img = imgList[index];
              var title = titleList[index];
              return Column(
                children: [
                  Image.asset(img,fit: BoxFit.cover,),
                  Text(title)
                 ]
              );
            }
          ),
      )
    );
  }
}

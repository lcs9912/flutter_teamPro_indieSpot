import 'package:flutter/material.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class PointDetailed extends StatefulWidget {
  const PointDetailed({super.key});

  @override
  State<PointDetailed> createState() => _PointDetailedState();
}

class _PointDetailedState extends State<PointDetailed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.person),color: Colors.black54),
            Builder(
                builder: (context) {
                  return IconButton(
                      onPressed: (){
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu),color: Colors.black54);
                }
            ),
          ],
          elevation: 1,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, // 뒤로가기 아이콘
              color: Colors.black54, // 원하는 색상으로 변경
            ),
            onPressed: () {
              // 뒤로가기 버튼을 눌렀을 때 수행할 작업
              Navigator.of(context).pop(); // 이 코드는 화면을 닫는 예제입니다
            },
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            '포인트',
            style: TextStyle(color: Colors.black),)
      ),
      body: ListView(
        children: [

        ],
      ),
    );
  }
}

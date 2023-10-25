import 'package:flutter/material.dart';
import 'concertDetails.dart'; // concertDetails.dart 파일을 import합니다.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(), // 메인 페이지는 MainPage() 위젯입니다.
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConcertDetails(), // concertDetails.dart로 이동합니다.
              ),
            );
          },
          child: Text('공연 상세 페이지로 이동'),
        ),
      ),
    );
  }
}

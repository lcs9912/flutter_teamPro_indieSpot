import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfff0da), // 배경을 반투명하게 하고 하얀색으로 설정
      body: Center(
        child: SpinKitPouringHourGlass(
          color: Color(0xFFff964f), // 스피너의 색상 설정
          size: 100.0, // 스피너의 크기 설정
        ),
      ),
    );
  }

}

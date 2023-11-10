import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.7), // 배경을 반투명하게 하고 하얀색으로 설정
      body: Center(
        child: SpinKitWave(
          color: Color(0xFF233067), // 스피너의 색상 설정
          size: 50.0, // 스피너의 크기 설정
        ),
      ),
    );
  }

}

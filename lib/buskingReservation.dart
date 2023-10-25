import 'package:flutter/material.dart';
import 'package:indie_spot/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BuskingReservation());
}

class BuskingReservation extends StatefulWidget {
  Fi_image

  @override
  State<BuskingReservation> createState() => _BuskingReservationState();
}

class _BuskingReservationState extends State<BuskingReservation> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            '버스킹 일정 등록',
            style: TextStyle(color: Colors.black),)
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Text('공연 프로필 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 10,),
            _imageAdd()
          ],
        ),
      ),
    );
  }
  
  Container _imageAdd(){
    return Container(
      height: 200,
      color: Color(0xffEEEEEE),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          height: 180,
          width: 180,
          child: _imageBox(),
        ),
      ),
    );
  }

  Widget _imageBox(){
    return Icon(Icons.camera_alt, color: Colors.grey);
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:indie_spot/artistList.dart';
import 'package:indie_spot/lsjMain.dart';
import 'donationList.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'buskingReservation.dart';

class ProprietorAdd extends StatefulWidget {
  const ProprietorAdd({super.key});

  @override
  State<ProprietorAdd> createState() => _ProprietorAddState();
}

class _ProprietorAddState extends State<ProprietorAdd> {
  File? _selectedImage;




  // 이미지
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // 이미지 미리보기
  Widget? _buildSelectedImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_selectedImage != null) {
      // 이미지를 미리보기로 보여줄 수 있음
      return Align(
        alignment: Alignment.topRight,
          
          child: Image.file(_selectedImage!, height: 450, width: screenWidth * 0.5,fit: BoxFit.fill,)
      );

    }
    return null; // 이미지가 없을 경우// null을 반환
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            '상업공간 등록',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("사업자 정보",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                Text("사업자증록증 사진 첨부"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft, // 사진 선택 이미지 왼쪽 위로 고정시키기
                  child: OutlinedButton(
                    onPressed: _pickImage,
                    child: Image.asset(
                      'assets/bus_sample1.jpg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                SizedBox(height: 14),
                _buildSelectedImage() ??
                    Container(
                        child: Container(
                          width: 100,
                          height: 100,
                        )
                    ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

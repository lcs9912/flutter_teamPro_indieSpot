import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test extends StatefulWidget {
  const Test({Key? key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Future<String> getImagePath() async {
    try {
      String imagePath = '';

      // Firestore에서 데이터 가져오기
      DocumentSnapshot<Map<String, dynamic>> imageSnapshot =
      await FirebaseFirestore.instance
          .collection('userList')
          .doc('userId') // 사용자의 ID를 지정해야 합니다.
          .collection('image')
          .doc('documentId') // 이미지 문서의 고유한 ID를 지정해야 합니다.
          .get();

      // 'path' 필드의 값을 가져오기
      String? path = imageSnapshot.data()?['path']; // Nullable한 String으로 선언

      if (imageSnapshot.exists && path != null) {
        // 이미지 경로가 유효한 경우에만 설정
        imagePath = path.toString();
      }

      return imagePath;
    } catch (e) {
      print('Error fetching image path: $e');
      return ''; // 에러 발생 시 빈 문자열을 반환합니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getImagePath(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 데이터를 아직 가져오는 중입니다.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String imagePath = snapshot.data!;
          if (imagePath.isNotEmpty) {
            return Image.network(imagePath); // 네트워크에서 이미지를 가져와서 출력합니다.
          } else {
            return Text('이미지가 없습니다.');
          }
        }
      },
    );
  }
}

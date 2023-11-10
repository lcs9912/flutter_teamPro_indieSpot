import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';

class ContactUs extends StatefulWidget {


  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late String _userId; // 수정: _userId를 late 변수로 변경

  TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserModel>(context, listen: false).userId ?? "";
    print('dddd$_userId');
  }


  String selectedCategory = '문의 유형 선택';
  List<String> categories = ['문의 유형 선택', '기술 지원', '결제 관련', '기타 문의'];
  TextEditingController inquiryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(_userId);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // 뒤로가기 아이콘의 색상을 검정색으로 지정합니다.
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '문의하기',
          style: TextStyle(
            color: Colors.white, // 텍스트 색상을 검정색으로 지정합니다.
          ),
        ),
        backgroundColor: Color(0xFF233067), // 배경색을 흰색으로 지정합니다.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: inquiryController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '문의 내용을 작성해주세요...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String userId = _userId;

                FirebaseFirestore firestore = FirebaseFirestore.instance;
                CollectionReference userListRef = firestore.collection('userList');

                await userListRef
                    .doc(userId)
                    .collection('inquiry')
                    .add({
                  'cDateTime': DateTime.now(),
                  'category': selectedCategory,
                  'content': inquiryController.text,
                  'rDateTime': null,
                  'reply': null,
                })
                    .then((value) {
                  print("문의 등록 성공!");
                })
                    .catchError((error) {
                  print("문의 등록 실패: $error");
                });
              },
              child: Text('문의 내용 전송'),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indie_spot/profile.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({Key? key}) : super(key: key);

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _introductionController = TextEditingController();

  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider
        .of<UserModel>(context, listen: false)
        .userId;
    if (_userId != null) {
      _userIdController.text = _userId!;
    }

    // Firestore에서 이메일 값을 가져오는 함수 호출
    getEmailFromFirestore();

  }

  Future<void> showLoginDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 터치해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 필요'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그인 후 이용해주세요.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
  void updateFirestore() async {
    try {
      // Firestore에서 'userList' 컬렉션의 문서를 가져옵니다.
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId); // 아이디를 사용하여 문서를 가져옵니다.

      // 업데이트할 데이터를 Map 형태로 만듭니다.
      Map<String, dynamic> updatedData = {};

      // 이메일 값이 비어 있지 않다면 업데이트합니다.
      if (_userIdController.text.isNotEmpty) {
        updatedData['email'] = _userIdController.text;
      }

      if (_introductionController.text.isNotEmpty) {
        updatedData['introduction'] = _introductionController.text;
      }


      // 생일 값이 비어 있지 않다면 업데이트합니다.
      if (_birthdayController.text.isNotEmpty) {
        updatedData['birthday'] = _userIdController.text;
      }

      // 비밀번호 값이 비어 있지 않다면 업데이트합니다.
      if (_passwordController.text.isNotEmpty) {
        updatedData['pwd'] = _passwordController.text;
      }

      // 닉네임 값이 비어 있지 않다면 업데이트합니다.
      if (_nicknameController.text.isNotEmpty) {
        updatedData['nick'] = _nicknameController.text;
      }

      // 업데이트할 데이터가 있을 때만 Firestore에 업데이트를 수행합니다.
      if (updatedData.isNotEmpty) {
        await documentReference.update(updatedData);

        // 업데이트가 성공하면 사용자에게 알림을 띄워줍니다.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('수정 완료'),
              content: Text('정보가 업데이트되었습니다.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 업데이트 중 에러가 발생하면 처리할 내용을 여기에 추가하세요.
      print('문서 업데이트 중 오류 발생: $e');
    }
  }



  Future<void> getEmailFromFirestore() async {
    try {
      // Firestore에서 'userList' 컬렉션의 문서를 가져옵니다.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('userList')
          .doc(_userId) // 아이디를 사용하여 문서를 가져옵니다.
          .get();

      // 문서가 존재하면
      if (documentSnapshot.exists) {
        // 이메일 값을 가져옵니다.
        String email = documentSnapshot.data()!['email'];

        // 가져온 이메일 값을 사용하거나 출력합니다.
        print('Email: $email');

        // 만약 화면에 표시하려면 setState()를 사용하여 상태를 갱신하세요.
        setState(() {
          _userIdController.text = email;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching email: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // Align children to the start (left)
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align children to the start (left)
        children: [
          SizedBox(height: 30),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // This will navigate back
                },
              ),
              Text("기본정보 수정",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            ],
          ),
          SizedBox(height: 30),
          Text("이메일", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20),
          TextField(
            controller: _userIdController,
            decoration: InputDecoration(
              labelText: '이메일',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text("비밀번호", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: 30),
          Text("닉네임", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20),
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: '닉네임',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Text("생일", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20),
          TextField(
            controller: _birthdayController,
            keyboardType: TextInputType.number, // 숫자 키패드를 띄웁니다.
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 숫자만 허용합니다.
            ],
            decoration: InputDecoration(
              labelText: 'YYYY-MM-DD',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          SizedBox(height: 30),
          Text("자기소개", style: TextStyle(fontSize: 16),),
          SizedBox(height: 20),
          TextField(
            controller: _introductionController,
            decoration: InputDecoration(
              labelText: '소개',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    nicknameController: _nicknameController,
                    introductionController: _introductionController,
                    userId: _userId,
                  ),
                ),
              );
            },
            child: Text('프로필 페이지로 이동'),
          ),

          SizedBox(height: 30),
          Center(
            child: Container(
              width: 200, //




            ),
          ),
          Center(
            child: Container(
              width: 200, //


              child: ElevatedButton(


                onPressed: () {
                  // 버튼이 눌렸을 때 수행될 동작을 여기에 추가하세요.
                  updateFirestore();
                },
                child: Text(
                  '저장',
                  style: TextStyle(fontSize: 20), // Adjust the font size
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16), // Adjust the vertical padding
                  primary: Color(0xFF392F31), // Set the button color here
                ),
              ),


            ),
          ),







        ],
      ),
      )
    );
  }
}
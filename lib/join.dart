import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Join extends StatefulWidget {
  const Join({super.key});

  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {
  String _selectedGender = '남자';

  bool _isNameEmpty = true;
  bool _isPhoneEmpty = true;
  bool _isBirthdayEmpty = true;
  bool _isPwdEmpty = true;
  bool _isPwd2Empty = true;
  bool _isEmailEmpty = true;
  bool _isNickEmpty = true;
  bool _isGenderEmpty = true;
  bool _isAgreedToTerms = false;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  String termsAndConditions = ''' ''';

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _pwd2 = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nick = TextEditingController();



  void _checkNickname() async {
    // 닉네임이 비어있는지 확인
    if (_nick.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임을 입력해주세요.')),
      );
      return;
    }

    // Firestore에서 중복 닉네임 체크
    final checkNickname = await _fs.collection('userList')
        .where('nickname', isEqualTo: _nick.text).get();
    if (checkNickname.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 사용 중인 닉네임 입니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용 가능한 닉네임입니다.')),
      );
    }
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이용약관'),
          content: SingleChildScrollView(
            child: Text(termsAndConditions),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text(
                '닫기',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white, // 텍스트 색상
                backgroundColor: Color(0xFF392F31),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 패딩 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼의 모서리를 둥글게 만듭니다.
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _register() async {
    // 필수 정보가 비어 있는지 확인
    if (_email.text.isEmpty ||
        _pwd.text.isEmpty ||
        _pwd2.text.isEmpty ||
        _name.text.isEmpty ||
        _nick.text.isEmpty ||
        _birthday.text.isEmpty ||
        _phone.text.isEmpty ||
        _selectedGender.isEmpty ||
        !_isAgreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필수 정보를 입력해주세요.')),
      );
      return;
    }

    // 비밀번호 확인
    if (_pwd.text != _pwd2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패스워드가 다릅니다')),
      );
      return;
    }

    // Firestore에서 중복 아이디 체크
    final checkId = await _fs.collection('userList')
        .where('email', isEqualTo: _email.text).get();
    if (checkId.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 존재함')),
      );
      return;
    }

    try {
      // 가입 처리
      await _fs.collection('userList').add({
        'gender': _selectedGender,
        'name': _name.text,
        'phone': _phone.text,
        'birthday': _birthday.text,
        'pwd': _pwd.text,
        'email': _email.text,
        'nick': _nick.text,
      });

      // 가입 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입되었음!!')),
      );

      // 입력값 초기화
      _birthday.clear();
      _phone.clear();
      _name.clear();
      _pwd.clear();
      _pwd2.clear();
      _email.clear();
      _nick.clear();
      _selectedGender = '남자';
      _isAgreedToTerms = false;

    } catch (e) {
      // 에러 발생 시 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "이메일",
              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _email,
              onChanged: (value) {
                setState(() {
                  _isEmailEmpty = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Text(
              "※보안정책으로 인하여 gmail은 이메일찾기가 불가능합니다.",
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(height: 40),
            Text(
              "비밀번호",
              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pwd,
              onChanged: (value) {
                setState(() {
                  _isPwdEmpty = value.isEmpty;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "비밀번호 확인",
              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pwd2,
              onChanged: (value) {
                setState(() {
                  _isPwd2Empty = value.isEmpty;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "이름",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _name,
              onChanged: (value) {
                setState(() {
                  _isNameEmpty = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: '이름',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "닉네임",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _checkNickname,

                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF392F31), // 색상 변경
                  ),
                  child: Text('중복 확인'),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nick,
              onChanged: (value) {
                setState(() {
                  _isNickEmpty = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: '닉네임',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "생일",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _birthday,
              onChanged: (value) {
                setState(() {
                  _isBirthdayEmpty = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: '생일 (YYYY-MM-DD)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),

            // 성별 입력 필드


            SizedBox(height: 40),

            // 전화번호 입력 필드
            Text(
              "전화번호",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phone,
              onChanged: (value) {
                setState(() {
                  _isPhoneEmpty = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: '전화번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "성별",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio(
                  value: '남자',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                Text('남자'),
                Radio(
                  value: '여자',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                Text('여자'),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Checkbox(
                  value: _isAgreedToTerms ?? false, // null이면 기본값으로 false를 사용합니다.
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreedToTerms = value ?? false; // null이면 기본값으로 false를 사용합니다.
                    });
                  },
                ),
                Text('이용약관에 동의합니다.  '),
                GestureDetector(
                  onTap: () {
                    _showTermsAndConditionsDialog(context);
                  },
                  child: Text(
                    '보기.',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(height: 16),


            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF392F31), // 392F31 색상
                ),
                child: Text('가입'),
              ),
            ),
          ],
        ),
      ],
      ),
      ),
    );

  }
}
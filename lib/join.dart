import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Join extends StatefulWidget {
  const Join({super.key});

  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _id = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _pwd2 = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  void _register() async {
    if (_pwd.text != _pwd2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패스워드 다르자너')),
      );
      return;
    }

    // Firestore에서 중복 아이디 체크
    final checkId = await _fs.collection('userList')
        .where('id', isEqualTo: _id.text).get();
    if(checkId.docs.isNotEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미 존재함')),);
    }
    try {
      await _fs.collection('userList').add({
        'id': _id.text,
        'pwd': _pwd.text,
        'email': _email.text,
        'phone': _phone.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입되었음!!')),
      );

      _id.clear();
      _pwd.clear();
      _pwd2.clear();
      _email.clear();
      _phone.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _id,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _pwd,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            TextField(
              controller: _pwd2,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
            ),
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _phone,
              decoration: InputDecoration(labelText: '전화번호'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: Text('가입'),
            ),
          ],
        ),
      ),
    );
  }
}

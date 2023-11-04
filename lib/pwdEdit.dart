import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/login.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PwdEdit extends StatefulWidget {
  const PwdEdit({super.key});

  @override
  State<PwdEdit> createState() => _PwdEditState();
}

class _PwdEditState extends State<PwdEdit> {

  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스를 가져옵니다.
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            "비밀번호 변경",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Text(
                "설정한 이메일/전화번호로 찾기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 30),
              Container(
                child: TextField(
                  controller: _email,
                  decoration: InputDecoration(labelText: '이메일'),
                ),
                width: 300,
              ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: '전화번호'),
                ),
                width: 300,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                  onPressed: _pwdEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(240, 240, 240, 1),
                    side: BorderSide(color: Color.fromRGBO(240, 240, 240, 1)),
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 18),
                    elevation: 0
                  ),
                  child: Text(
                      "비밀번호 변경",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    )
                  ),
              )
            ],
          ),
        )
      ),
    );
  }

  void _pwdEdit() async {
    String email = _email.text;
    String phone = _phone.text;

    final userDocs = await _fs.collection('userList')
        .where('email', isEqualTo: email)
        .where('phone', isEqualTo: phone).get();

    if(userDocs.docs.isNotEmpty) {
      String newPwd = await _showPwdDialog();

      const uniqueKey = 'Indie_spot'; // 비밀번호 추가 암호화를 위해 유니크 키 추가
      final bytes = utf8.encode(newPwd + uniqueKey); // 비밀번호와 유니크 키를 바이트로 변환
      final hash = sha512.convert(bytes); // 비밀번호를 sha512을 통해 해시 코드로 변환
      String pwd =  hash.toString();

      if(newPwd.isNotEmpty) {
        await _fs.collection('userList')
            .doc(userDocs.docs.first.id)
            .update({'pwd': pwd});

        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("비밀번호가 변경되었습니다."))
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }

    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일과 전화번호를 다시 확인해주세요.'))
      );
    }
  }
  Future<String> _showPwdDialog() async {
    String newPwd = '';

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("비밀번호 변경"),
            content: TextField(
              onChanged: (value){
                newPwd = value;
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: '새로운 비밀번호를 입력',
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(newPwd);
                  },
                  child: Text('확인')
              )
            ],
          );
        }
    );
    if (newPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("새로운 비밀번호를 입력해주세요."))
      );
    }
    return newPwd;
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:indie_spot/pwdEind.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';

import 'join.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      ChangeNotifierProvider(
        create: (context) => UserModel(),
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로그인',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스를 가져옵니다.
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                '../assets/indiespot.jpg',
                width: 300,
              ),
              Container(
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(labelText: '이메일'),
                  ),
                width: 300
              ),
              SizedBox(height: 20),
              Container(
                child:  TextField(
                  controller: _pwd,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '비밀번호'),
                ),
                width: 300,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(240, 240, 240, 1),
                  side: BorderSide(color: Color.fromRGBO(240, 240, 240, 1)),
                  padding: EdgeInsets.symmetric(horizontal: 90, vertical: 18)
                ),
                child: Text(
                    '회원 로그인',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    ),),
              ),
              SizedBox(height: 60),
              // ElevatedButton(
              //   onPressed: (){
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => Join(),
              //       ),
              //     );
              //   },
              //   child: Text('회원가입'),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PwdEdit()
                          )
                      );
                    },
                    child: Text(
                      "비밀번호 찾기",
                      style: TextStyle(
                      color: Colors.black
                      ),
                    ),
                  ),
                  SizedBox(width: 150),
                  InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Join()
                          )
                      );
                    },
                    child: Text(
                      "가입하기",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    String email = _email.text;
    String password = _pwd.text;

    final userDocs = await _fs.collection('userList')
        .where('email', isEqualTo: email)
        .where('pwd', isEqualTo: password).get();

    if (userDocs.docs.isNotEmpty) {
      Provider.of<UserModel>(context, listen: false).login(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('성공적으로 로그인되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디나 패스워드를 다시 확인해주세요.')),
      );
    }
  }
}
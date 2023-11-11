import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indie_spot/baseBar.dart';
import 'package:indie_spot/loading.dart';
import 'package:indie_spot/main.dart';
import 'package:indie_spot/pwdEdit.dart';
import 'package:provider/provider.dart';
import 'package:indie_spot/userModel.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:get/get.dart';

import 'join.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//       ChangeNotifierProvider (
//         create: (context) => UserModel(),
//         child: MyApp(),
//       )
//   );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '로그인',
//       home: LoginPage(),
//     );
//   }
// }

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        backgroundColor: Color(0xFF233067),
        elevation: 1,
        title: Text(
            '로그인',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
              );
            },
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Image.asset(
                'assets/indiespot.png',
                width: 300,
                height: 100,
              ),
              SizedBox(height: 20),
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
                    backgroundColor: Color(0xFF233067),
                  side: BorderSide(color: Color.fromRGBO(240, 240, 240, 1)),
                  padding: EdgeInsets.symmetric(horizontal: 90, vertical: 18),
                  elevation: 0.2
                ),
                child: Text(
                    '회원 로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    ),),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Get.to(
                        PwdEdit(),
                        transition: Transition.noTransition
                      );
                    },
                    child: Text(
                      "비밀번호 변경",
                      style: TextStyle(
                      color: Colors.black,
                        fontSize: 15
                      ),
                    ),
                  ),
                  SizedBox(width: 150),
                  InkWell(
                    onTap: (){
                      Get.to(
                        Join(),
                        transition: Transition.noTransition
                      );
                    },
                    child: Text(
                      "가입하기",
                      style: TextStyle(
                        color: Colors.black,
                          fontSize: 14,
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
    FocusScope.of(context).unfocus();
    String email = _email.text;
    const uniqueKey = 'Indie_spot';
    final bytes = utf8.encode(_pwd.text + uniqueKey);
    final hash = sha512.convert(bytes);
    String password = hash.toString();

    if (email.isEmpty || _pwd.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일과 비밀번호를 입력하세요'),
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LoadingWidget();
        },
        barrierDismissible: false,
      );

      final userDocs = await _fs
          .collection('userList')
          .where('email', isEqualTo: email)
          .where('pwd', isEqualTo: password)
          .get();

      if (userDocs.docs.isNotEmpty) {
        var data = userDocs.docs.first.data();
        if (data['banYn'] == 'Y') {
          if (context.mounted) {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '정지된 계정입니다 \n사유 : ${data['banReason']}',
                ),
              ),
            );
          }
        } else {
          final userId = userDocs.docs[0].id;
          String? artistId;
          String? status;
          String? admin = userDocs.docs[0].data()['admin'];
          CollectionReference artistCollectionRef = _fs.collection('artist');

          QuerySnapshot artistDocs = await artistCollectionRef.get();

          for (QueryDocumentSnapshot artistDoc in artistDocs.docs) {
            CollectionReference teamMembersRef =
            artistDoc.reference.collection('team_members');

            // 각 teamMembers 쿼리를 병렬로 처리하기 위해 Future.wait 사용

            // userId를 사용하여 특정 문서 내에서 검색
            final teamMemberSnapshot = await teamMembersRef
                .where('userId', isEqualTo: userId)
                .get(); // Using get here to fetch the document

            if (teamMemberSnapshot.docs.isNotEmpty) {
              artistId = artistDoc.id;
              status = teamMemberSnapshot.docs.first.get('status');
              break;
            }
          }

          if (context.mounted) {
            if (artistId != null) {
              // 아티스트 로그인
              Provider.of<UserModel>(context, listen: false)
                  .loginArtist(userId, artistId, status!, admin);
            } else {
              // 일반 사용자 로그인
              Provider.of<UserModel>(context, listen: false).login(userId, admin);
            }

            Get.off(
              MyApp(),
              transition: Transition.noTransition,
            );
          }
        }
      } else {
        if (context.mounted) {
          Get.back();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '이메일과 패스워드를 다시 확인해주세요.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      // 에러가 발생할 경우 로그 출력
      print('Error in login: $e');
      if (context.mounted) {
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인 중 오류가 발생했습니다.',
            ),
          ),
        );
      }
    }
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.7), // 배경을 반투명하게 하고 하얀색으로 설정
      body: Center(
        child: CircularProgressIndicator(), // 로딩 표시 방법을 원하는 대로 수정 가능
      ),
    );
  }
}
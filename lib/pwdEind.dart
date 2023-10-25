import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PwdEdit extends StatefulWidget {
  const PwdEdit({super.key});

  @override
  State<PwdEdit> createState() => _PwdEditState();
}

class _PwdEditState extends State<PwdEdit> {

  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스를 가져옵니다.
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("비밀번호 찾기"),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(),
            TextField(),
            TextField(),

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:indie_spot/userModel.dart';
import 'package:provider/provider.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({Key? key}) : super(key: key);

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();

  String? _userId; // _userId를 정의합니다.

  @override
  void initState() {
    super.initState();

    // provider로부터 가져온 userId를 _userIdController에 설정
    _userId = Provider.of<UserModel>(context, listen: false).userId;
    _userIdController.text = _userId!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _userIdController,
          decoration: InputDecoration(
            labelText: '아이디',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),

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

        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }
}
